type 'a msgf = (('a, Format.formatter, unit, unit) format4 -> 'a) -> unit
type metadata = (string * Yojson.Safe.t) list
type 'a t = Level.t * string option * metadata * 'a msgf

type _ Effect.t +=
  | Emit : 'a t -> unit Effect.t
      (** [Emit] emits log object. Logs can be injected to handle the effect. *)

(** [log level msgf] sends [msgf] message object with level [level]

    log `Debug @@ fun m -> m "hello, %s" "world" *)
let emit level msgf loc info = Effect.perform @@ Emit (level, loc, info, msgf)

let emg ?(metadata = []) ?__LOC__ msgf = emit `Emergency msgf __LOC__ metadata
let alert ?(metadata = []) ?__LOC__ msgf = emit `Alert msgf __LOC__ metadata
let crit ?(metadata = []) ?__LOC__ msgf = emit `Critical msgf __LOC__ metadata
let err ?(metadata = []) ?__LOC__ msgf = emit `Error msgf __LOC__ metadata
let warn ?(metadata = []) ?__LOC__ msgf = emit `Warning msgf __LOC__ metadata
let notice ?(metadata = []) ?__LOC__ msgf = emit `Notice msgf __LOC__ metadata
let info ?(metadata = []) ?__LOC__ msgf = emit `Info msgf __LOC__ metadata
let debug ?(metadata = []) ?__LOC__ msgf = emit `Debug msgf __LOC__ metadata

let make_emit_handler f msgh =
  let open Effect.Deep in
  let effc : type a. a Effect.t -> ((a, 'r) continuation -> 'r) option = function
    | Emit (level, loc, json, msgf) ->
      Some
        (fun k ->
          let now = Time.now' () in
          msgf @@ Format.kasprintf (msgh now level loc json);
          Effect.Deep.continue k ())
    | _ -> None
  in
  try_with f () { effc }
;;
