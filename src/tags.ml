type 'a k =
  { name : string
  ; pp : Fmt.t -> 'a -> unit
  }

module M = Hmap.Make (struct
  type 'a t = 'a k
end)

include M

let string ?(pp = fun fmt -> Format.fprintf fmt "%s") name = Key.create { name; pp }
let int ?(pp = fun fmt -> Format.fprintf fmt "%d") name = Key.create { name; pp }
let float ?(pp = fun fmt -> Format.fprintf fmt "%f") name = Key.create { name; pp }
let pp_key key = (Key.info key).pp

(* let pp *)
(* : type a. *)
(* delim:string *)
(* -> surround:string * string *)
(* -> fmtf: *)
(* (((Fmt.t -> a -> unit) -> a -> unit, 'b, 'c, unit, unit, unit) format6 *)
(* -> ( string -> (Fmt.t -> a -> unit) -> a -> unit *)
(* , 'b *)
(* , 'c *)
(* , unit *)
(* , unit *)
(* , unit ) *)
(* format6) *)
(* -> (* ((a, Fmt.t, unit, unit) format4 -> (string -> a, Fmt.t, unit, unit) format4) *) *)
(* Format.formatter *)
(* -> M.t *)
(* -> unit *)
(* = *)
(* fun ~delim ~surround:(lhs, rhs) ~fmtf fmt t -> *)
(* Format.fprintf fmt "%s" lhs; *)
(* let r = *)
(* M.fold *)
(* (fun (B (k : $B_'a key, e)) acc -> *)
(* let k' = Key.info k in *)
(* lazy (Format.fprintf fmt (fmtf "%a") k'.name k'.pp e) :: acc) *)
(* t *)
(* [] *)
(* in *)
(* let len = List.length r in *)
(* List.iteri *)
(* (fun i t -> *)
(* Lazy.force t; *)
(* if i <> len - 1 then Format.fprintf fmt "%s" delim) *)
(* r; *)
(* Format.fprintf fmt "%s" rhs *)
(* ;; *)
