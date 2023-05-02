type 'a kasprintf =
  is_last:bool -> level:Level.t -> message:string -> tags:Tags.t -> (string -> 'a) -> 'a

let json ~level ~message ~tags k =
  let k0 s = Format.kasprintf k "{%s" s in
  let k', _ =
    let tags' =
      Tags.key "log_level" level ~pp:Level.pp :: Tags.string "message" message :: tags
    in
    let len = List.length tags' in
    ListLabels.fold_left tags' ~init:(k0, 0) ~f:(fun (k, idx) (name, Tags.(V (v, pp))) ->
      let idx' = idx + 1 in
      let delim = if idx' = len then "" else "," in
      (fun s -> Format.kasprintf k {|"%s":%a%s%s|} name pp v delim s), idx')
  in
  Format.kasprintf k' "}"
;;

let plain ~level ~message ~tags k =
  let k0 s = Format.kasprintf k "%s" s in
  let k', _ =
    let tags' =
      Tags.key "log_level" level ~pp:Level.pp :: Tags.string "message" message :: tags
    in
    let len = List.length tags' in
    ListLabels.fold_left tags' ~init:(k0, 0) ~f:(fun (k, idx) (name, Tags.(V (v, pp))) ->
      let idx' = idx + 1 in
      let delim = if idx' = len then "" else " " in
      (fun s -> Format.kasprintf k "%s=%a%s%s" name pp v delim s), idx')
  in
  k' ""
;;
