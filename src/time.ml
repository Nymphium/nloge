type _ Effect.t += Now : float Effect.t

let now' () = Effect.perform Now

let run (clock : 'a Eio.Time.clock) f =
  try f () with
  | effect Now, k ->
    let c = Eio.Time.now clock in
    Effect.Deep.continue k c
;;
