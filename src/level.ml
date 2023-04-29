(* following syslog *)
type t =
  [ `Emergency
  | `Alert
  | `Critical
  | `Error
  | `Warning
  | `Notice
  | `Info
  | `Debug
  ]
[@@deriving eq, ord]

type _ Effect.t += Get : t Effect.t

let get_level () = Effect.perform Get
