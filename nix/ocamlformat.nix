{ lib, ocamlformat }:
let
  ocamlformat_config = lib.strings.splitString "\n" (builtins.readFile ocamlformat);
  re = builtins.match "version\s*=\s*(.*)\s*$";
  version_line = lib.lists.findFirst
    (l: builtins.isList (re l))
    (throw "no version specified in .ocamlformat")
    ocamlformat_config;
in
builtins.elemAt (re version_line) 0
