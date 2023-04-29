open Eio
open Effect.Deep

let keeper ~(level : Level.t) f =
  let effc (type a) (eff : a Effect.t) : ((a, 'r) continuation -> 'r) option =
    match eff with
    | Level.Get -> Some (fun k -> continue k level)
    | _ -> None
  in
  try_with f () { effc }
;;

let run ~sw ~output ~(level : Level.t) f =
  let effc (type a) (eff : a Effect.t) : ((a, 'r) continuation -> 'r) option =
    match eff with
    | Logging.Log (level', msgf) ->
      Some
        (fun k ->
          let () =
            if Level.compare level level' >= 0
            then Fiber.fork ~sw @@ fun () -> msgf (fun msg -> Flow.copy_string msg output)
          in
          continue k ())
    | _ -> None
  in
  try_with f () { effc }
;;
