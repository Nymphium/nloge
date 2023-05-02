n log e
===

Nloge, no-blocking logger with [eio](https://github.com/ocaml-multicore/eio)

Logger emits JSON -{`Emit`} -> converts JSON to string -{`Write`}-> "log"s the string

# Usage
```ocaml
let () =
  Eio_main.run @@ fun env ->
  Eio.Switch.run @@ fun sw ->
  Nloge.run ~sw ~outputs:[ env#stdout ] ~level:`Debug @@ fun () ->
  let index i = "index", `Int i in
  for i = 1 to 2000 do
    let metadata = [ index i ] in
    Nloge.info ~metadata (fun m -> m "a");
    Nloge.debug ~metadata (fun m -> m "hello, %d" i)
  done
;;
```

See [hello](/examples/hello.ml)

# custom writere
See [custom writer](/examples/custom_transformer.ml)
