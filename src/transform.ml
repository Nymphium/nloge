open Effect.Deep

let insert_info message log_level loc l =
  l
  |> Option.(map (fun loc -> List.cons ("loc", `String loc)) loc |> value ~default:Fun.id)
  |> List.cons ("message", `String message)
  |> List.cons ("log_level", `String (Level.show log_level))
;;

module F (M : sig
  type _ Effect.t += Write : string * Level.t -> unit Effect.t
end) =
struct
  let json f =
    let effc : type a. a Effect.t -> ((a, 'r) continuation -> 'r) option = function
      | Emit.Emit (level, msgf, loc, json) ->
        Some
          (fun k ->
            msgf
            @@ Format.kasprintf
            @@ fun msg ->
            let str = Yojson.Safe.to_string @@ `Assoc (insert_info msg level loc json) in
            Effect.perform @@ M.Write (str, level);
            continue k ())
      | _ -> None
    in
    try_with f () { effc }
  ;;
end
