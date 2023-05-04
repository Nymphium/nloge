open struct
  module Time_ = Time
end

open Eio
open Effect.Deep

type _ Effect.t +=
  | Write : string * Level.t -> unit Effect.t
  | GetTime : #Time.clock Effect.t

let write level msg = Effect.perform @@ Write (msg, level)

module Trans = struct
  let optional label v f =
    Option.(map (fun v -> List.cons (label, f v)) v |> value ~default:Fun.id)
  ;;

  let insert_info now log_level loc message metadata =
    metadata
    |> optional "label" loc (fun s -> `String s)
    |> optional "message" message (fun s -> `String s)
    |> optional "log_level" (Option.map Level.show log_level) (fun s -> `String s)
    |> optional
         "timestamp"
         Option.(
           bind now Ptime.of_float_s
           |> map (Ptime.to_rfc3339 ?tz_offset_s:(Ptime_clock.current_tz_offset_s ())))
         (fun s -> `String s)
  ;;

  let json f =
    Emit.make_emit_handler f (fun now level loc json msg ->
      write level
      @@ Yojson.Safe.to_string
      @@ `Assoc (insert_info (Some now) (Some level) loc (Some msg) json))
  ;;
end

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
