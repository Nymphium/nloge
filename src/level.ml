(** [t] represents syslog-style levels *)
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

(** [Get] refers to the current logging level. *)
type _ Effect.t += Get : t Effect.t

let get_level () = Effect.perform Get

(** [parse]s upper, lower, and initial capital letter cases.

    {[parse "DEBUG" = parse "debug" = parse "Debug" = Some `Debug]} *)
let parse : string -> t option = function
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

(** [pp] prints level with upper capital

    {[pp Format.std_formatter `Debug (* -> DEBUG *)]} *)
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
