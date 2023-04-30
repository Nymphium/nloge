let () =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  Nloge.run ~sw ~output:env#stdout ~level:`Debug
  @@ fun () ->
  let key = Nloge.Tags.int "index" in
  for i = 1 to 20 do
    let tags = Nloge.Tags.(empty |> add key i) in
    Nloge.debug (fun m -> m ~tags "hello, %d\n" i)
  done
;;
