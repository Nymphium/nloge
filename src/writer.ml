(** {1:writer Writing logs}
    Nloge writes logs, given by {!Emit} effect, to {!type-"Eio.Flow.sink"}
*)

open struct
  module Time_ = Time
end

open Eio
open Effect.Deep

type _ Effect.t += Write : string * Level.t -> unit Effect.t

let write level msg = Effect.perform @@ Write (msg, level)

module Trans = struct
  let optional label v f =
    Option.(map (fun v -> List.cons (label, f v)) v |> value ~default:Fun.id)
  ;;

  let insert_info now log_level loc message metadata =
    metadata
    |> List.cons ("message", `String message)
    |> List.cons ("log_level", `String (Level.show log_level))
    |> optional "label" loc (fun s -> `String s)
    |> optional
         "timestamp"
         Option.(
           now
           |> Ptime.of_float_s
           |> map @@ Ptime.to_rfc3339 ?tz_offset_s:(Ptime_clock.current_tz_offset_s ()))
         (fun s -> `String s)
  ;;

  let json f =
    Emit.make_emit_handler f (fun now level loc json msg ->
      write level @@ Yojson.Safe.to_string @@ `Assoc (insert_info now level loc msg json))
  ;;
end

(** [run] is the handler to write logs to given outputs.
  @param clock {!type-"Eio.Time.clock"} clock objet
  @param sw {!type-"Eio.Switch.t"} switch object to write output asynchronously
  @param outputs {!type-"Eio.Flow.sink list"} the targets to write logs
  @param level {!type-"Level.t option"}
 *)
let run ~clock ~sw ~outputs ~(level : Level.t) ?(trans = Trans.json) f =
  let effc : type a. a Effect.t -> ((a, 'r) continuation -> 'r) option = function
    | Write (str, level') ->
      Some
        (fun k ->
          let () =
            if Level.compare level level' >= 0
            then
              Fiber.fork ~sw
              @@ fun () -> List.iter (Flow.copy_string (str ^ "\n")) outputs
          in
          continue k ())
    | _ -> None
  in
  try_with (fun () -> Time_.run clock @@ fun () -> trans f) () { effc }
;;
