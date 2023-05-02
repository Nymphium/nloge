open Eio
open Effect.Deep

module M = struct
  type _ Effect.t += Write : string * Level.t -> unit Effect.t
end

include M
module T = Transform.F (M)

let run ~sw ~outputs ~(level : Level.t) ?(trans = T.json) f =
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
  try_with (fun () -> trans f) () { effc }
;;
