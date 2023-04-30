open Eio
open Effect.Deep

let formatter msgf level km =
  msgf (fun ?(tags = Tags.empty) fmt ->
    ignore tags;
    Format.kasprintf km ("[%a]" ^^ fmt) Level.pp level)
;;

let run ~sw ~output ~(level : Level.t) f =
  let effc : type a. a Effect.t -> ((a, 'r) continuation -> 'r) option = function
    | Level.Get -> Some (fun k -> continue k level)
    | Logging.Log (level', msgf) ->
      Some
        (fun k ->
          let () =
            if Level.compare level level' >= 0
            then
              Fiber.fork ~sw
              @@ fun () -> formatter msgf level' @@ Fun.flip Flow.copy_string output
          in
          continue k ())
    | _ -> None
  in
  try_with f () { effc }
;;
