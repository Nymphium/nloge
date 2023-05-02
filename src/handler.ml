open Eio
open Effect.Deep

let formatting kasprintf msgf level km =
  msgf
  @@ fun ?(tags = []) fmtf ->
  Fun.flip Format.kasprintf fmtf @@ fun message -> kasprintf ~level ~message ~tags km
;;

let run ~sw ~outputs ~(level : Level.t) ?(format = Format_.json) f =
  let effc : type a. a Effect.t -> ((a, 'r) continuation -> 'r) option = function
    | Logging.Log (level', msgf) ->
      Some
        (fun k ->
          let () =
            if Level.compare level level' >= 0
            then
              Fiber.fork ~sw
              @@ fun () ->
              formatting format msgf level'
              @@ fun m -> List.iter (Flow.copy_string (m ^ "\n")) outputs
          in
          continue k ())
    | _ -> None
  in
  try_with f () { effc }
;;
