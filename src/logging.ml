type _ msgf = (string -> unit) -> unit
type 'a t = Level.t * 'a msgf
type _ Effect.t += Log : 'a t -> unit Effect.t

let send level msgf = Effect.perform @@ Log (level, msgf)
let debug msgf = send `Debug msgf
let info msgf = send `Info msgf
