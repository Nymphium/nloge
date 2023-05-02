let () =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  (* Nloge.(run ~sw ~outputs:[ env#stdout ] ~level:`Debug ~format:Format.plain) *)
  Nloge.run ~sw ~outputs:[ env#stdout ] ~level:`Debug
  @@ fun () ->
  let index = Nloge.Tags.int "index" in
  for i = 1 to 2000 do
    let tags =
      [ index i
      ; Nloge.Tags.string "hoge" "value"
      ; Nloge.Tags.(
          key
            "namea"
            (V ("a", Fun.flip Format.fprintf "%s"))
            ~pp:(fun fmt (V (v, pp)) -> Format.fprintf fmt "%a" pp v))
      ]
    in
    Nloge.info (fun m -> m "a");
    Nloge.debug (fun m ->
      if i mod 10 = 0 then Eio.Time.sleep env#clock 0.3;
      m ~tags "hello, %d" i)
  done
;;
