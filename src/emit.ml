(** {1:emit Emitting log}

  Nloge "emit"s logs to {!section-"writer"} by "perform"ing {!Emit}.
  *)

type 'a msgf = (('a, Format.formatter, unit, unit) format4 -> 'a) -> unit
type metadata = (string * Yojson.Safe.t) list
type 'a t = Level.t * string option * metadata * 'a msgf

(** [Emit] is aimed to emit log objects. {!section-"writer"} can be injected to handle the effect. *)
type _ Effect.t += Emit : 'a t -> unit Effect.t

type 'a logger = ?metadata:metadata -> ?__LOC__:string -> 'a msgf -> unit

(** {2 Log functions} *)

(** [emit level ?metadata ?loc msgf] sends [msgf] message object with level [level].
    [metadata] and [loc] can be sent optionally.

    {@ocaml[
    # emit `Debug @@ fun m -> m "hello, %s" "world";;
    hello, world
    - : unit = ()
    ]}

 And the following [emg], [alert], etc. are wrapper for [emit] with correspondng [level].

    {@ocaml[
    # debug ~metadata:["Key", `String "Val" ] ~__LOC__ @@ fun m -> m "the answer: %d" 42;;
    ]}

    *)
let emit level msgf loc info = Effect.perform @@ Emit (level, loc, info, msgf)

let emg : 'a logger =
  fun ?(metadata = []) ?__LOC__ msgf -> emit `Emergency msgf __LOC__ metadata
;;

let alert : 'a logger =
  fun ?(metadata = []) ?__LOC__ msgf -> emit `Alert msgf __LOC__ metadata
;;

let crit : 'a logger =
  fun ?(metadata = []) ?__LOC__ msgf -> emit `Critical msgf __LOC__ metadata
;;

let err : 'a logger =
  fun ?(metadata = []) ?__LOC__ msgf -> emit `Error msgf __LOC__ metadata
;;

let warn : 'a logger =
  fun ?(metadata = []) ?__LOC__ msgf -> emit `Warning msgf __LOC__ metadata
;;

let notice : 'a logger =
  fun ?(metadata = []) ?__LOC__ msgf -> emit `Notice msgf __LOC__ metadata
;;

let info : 'a logger =
  fun ?(metadata = []) ?__LOC__ msgf -> emit `Info msgf __LOC__ metadata
;;

let debug : 'a logger =
  fun ?(metadata = []) ?__LOC__ msgf -> emit `Debug msgf __LOC__ metadata
;;

(** {2 Utilities} *)

(** [make_emit_handler] is a utility to build a handler for {!Emit}.
    {[
      let plain_transformer f =
        Nloge.make_emit_handler f
        @@ fun now level loc metadata msg ->
        let json = Nloge.Trans.insert_info now level loc msg metadata in
        let len = List.length json in
        let k0 = Format.kasprintf (Nloge.write level) "%a:\n%s" Nloge.Level.pp level in
        let k, _ =
          ListLabels.fold_left json ~init:(k0, 0) ~f:(fun (k, idx) (label, v) ->
            let idx' = idx + 1 in
            let comma = if idx' = len then "" else "\n" in
            ( Format.kasprintf
                k
                "\t%-10s = %a%s%s"
                label
                (Yojson.Safe.pretty_print ~std:true)
                v
                comma
            , idx' ))
        in
        k "\n"
      ;;
]}
 *)
let make_emit_handler f msgh =
  try f () with
  | effect Emit (level, loc, json, msgf), k ->
    let now = Time.now' () in
    msgf @@ Format.kasprintf (msgh now level loc json);
    Effect.Deep.continue k ()
;;
