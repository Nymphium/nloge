let () =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  (* Nloge.(run ~sw ~outputs:[ env#stdout ] ~level:`Debug ~format:Format.plain) *)
  Nloge.run ~sw ~outputs:[ env#stdout ] ~level:`Debug
  @@ fun () ->
  let index i = "index", `Int i in
  for i = 1 to 200 do
    let metadata = [ index i ] in
    Nloge.info ~metadata ~__LOC__ (fun m -> m "a");
    Nloge.debug ~metadata (fun m -> m "hello, %d" i)
  done
;;
