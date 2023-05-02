(** Use [Nloge.make_emit_handler] to create custom transformer  *)
let plain_transformer f =
  Nloge.make_emit_handler f
  @@ fun level loc metadata msg ->
  let json = Nloge.Trans.insert_info None loc (Some msg) metadata in
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

let () =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  Nloge.run ~sw ~outputs:[ env#stdout ] ~level:`Debug ~trans:plain_transformer
  @@ fun () ->
  let index i = "index", `Int i in
  for i = 1 to 200 do
    let metadata = [ index i ] in
    Nloge.info ~metadata ~__LOC__ (fun m -> m "a");
    Nloge.debug ~metadata (fun m -> m "hello, %d" i)
  done
;;
