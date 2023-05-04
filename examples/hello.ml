(* By default nloge logs with JSON format
   {"log_level":"DEBUG","message":"hello","label":"File \"examples/hello.ml\", line 9, characters 5-12","now_posix":1683056241.957986} *)
let () =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  Nloge.run ~clock:env#clock ~sw ~outputs:[ env#stdout ] ~level:`Debug
  @@ fun () ->
  Nloge.debug
    ~__LOC__
    ~metadata:[ "now_posix", `Float (Eio.Time.now env#clock) ]
    (fun m -> m "hello")
;;
