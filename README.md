n log e
===

Nloge, no-blocking logger with [eio](https://github.com/ocaml-multicore/eio)

Logger emits JSON -{`Emit`} -> converts JSON to string -{`Write`}-> "log"s the string

# Usage

See [hello](/examples/hello.ml)

```ocaml
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
```

By default nloge logs with JSON format:

```
$ dune exec --display=quiet examples/hello.exe
{"log_level":"DEBUG","message":"hello","label":"File \"examples/hello.ml\", line 9, characters 5-12","now_posix":1683056241.957986}
```


# custom writere
See [custom writer](/examples/custom_transformer.ml)

# LICENSE
MIT
