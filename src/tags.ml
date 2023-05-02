type ve = V : ('a * (Format.formatter -> 'a -> unit)) -> ve
type v = string * ve
type t = v list
type 'a key = ?pp:Format.formatter -> 'a -> unit -> string -> 'a -> v

let string name v = name, V (v, Fun.flip Format.fprintf {|"%s"|})
let int name v = name, V (v, Fun.flip Format.fprintf "%d")
let float name v = name, V (v, Fun.flip Format.fprintf "%d")
let key ~pp name v = name, V (v, pp)
