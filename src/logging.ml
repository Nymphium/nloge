type 'a msgf = (?tags:Tags.t-> ('a, Fmt.t,unit, unit) format4 -> 'a) -> unit
type 'm t = Level.t * 'm msgf

type _ Effect.t +=
  (** [Log] emits log object. Logs can be injected to handle the effect. *)
  Log : 'a t -> unit Effect.t

(** [log level msgf] sends [msgf] message object with level [level]

     log `Debug @@ fun m -> m "hello, %s" "world" *)
let log level msgf = Effect.perform @@ Log (level, msgf)

let emg msgf = log `Emergency msgf
let alert msgf = log `Alert msgf
let crit msgf = log `Critical msgf
let err msgf = log `Error msgf
let warn msgf = log `Warning msgf
let notice msgf = log `Notice msgf
let info msgf = log `Info msgf
let debug msgf = log `Debug msgf

