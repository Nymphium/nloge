let () =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  Nloge.run ~sw ~outputs:[ env#stdout ] ~level:`Debug
  @@ fun () ->
  Nloge.debug
    ~__LOC__
    ~metadata:[ "now_posix", `Float (Eio.Time.now env#clock) ]
    (fun m -> m "hello")
;;
