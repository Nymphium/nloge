let () =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  Nloge.Handler.run ~sw ~output:env#stdout ~level:`Debug
  @@ fun () ->
  Nloge.Logging.debug (fun m -> m "hello");
  Nloge.Logging.info (fun m -> m "world")
;;
