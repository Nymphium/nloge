type _ Effect.t += Get : Eio.Time.clock Effect.t

let get () = Effect.perform Get
let now' () = Eio.Time.now @@ get ()

let run (clock : #Eio.Time.clock) f =
  let open Effect.Deep in
  let effc : type a. a Effect.t -> ((a, 'r) continuation -> 'r) option = function
    | Get -> Some (fun k -> continue k clock)
    | _ -> None
  in
  try_with f () { effc }
;;
