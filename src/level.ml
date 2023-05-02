(** syslog level *)
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

type _ Effect.t += Get : t Effect.t (** [Get] refers current logging level. *)

let get_level () = Effect.perform Get

let parse = function
  | "Emergency" | "EMERGENCY" | "emergency" -> Some `Emergency
  | "Alert" | "ALERT" | "alert" -> Some `Alert
  | "Critical" | "CRITICAL" | "critical" -> Some `Critical
  | "Error" | "ERROR" | "error" -> Some `Error
  | "Warning" | "WARNING" | "warning" -> Some `Warning
  | "Notice" | "NOTICE" | "notice" -> Some `Notice
  | "Info" | "INFO" | "info" -> Some `Info
  | "Debug" | "DEBUG" | "debug" -> Some `Debug
  | _ -> None
;;

let pp fmt (t : t) =
  Format.fprintf fmt
  @@
  match t with
  | `Emergency -> "EMERGENCY"
  | `Alert -> "ALERT"
  | `Critical -> "CRITICAL"
  | `Error -> "ERROR"
  | `Warning -> "WARNING"
  | `Notice -> "NOTICE"
  | `Info -> "INFO"
  | `Debug -> "DEBUG"
;;

let show t =
  let b = Buffer.create 16 in
  let fmt = Format.formatter_of_buffer b in
  Fun.protect ~finally:(fun () -> Format.pp_print_flush fmt ()) (fun () -> pp fmt t);
  Fun.protect ~finally:(fun () -> Buffer.clear b) (fun () -> Buffer.contents b)
;;
