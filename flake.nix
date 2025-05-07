{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        opam-repository.follows = "opam-repository";
      };
    };
  };
  outputs =
    {
      flake-utils,
      opam-nix,
      nixpkgs,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        src = ./.;
        localNames =
          with builtins;
          filter (f: !isNull f) (
            map (
              f:
              let
                f' = match "(.*)\.opam$" f;
              in
              if isNull f' then null else elemAt f' 0
            ) (attrNames (readDir ./.))
          );

        localPackagesQuery =
          with builtins;
          listToAttrs (
            map (p: {
              name = p;
              value = "*";
            }) localNames
          );

        devPackagesQuery = {
          ocaml-lsp-server = "*";
          utop = "*";
          ocamlformat = "*";
        };

        query =
          devPackagesQuery
          // localPackagesQuery
          // {
            ocaml-base-compiler = "*";
          };

        overlay =
          final: prev:
          {
            utop = prev.utop.overrideAttrs {
              # Fix for "unpacker produced multiple directories"
              # See: https://stackoverflow.com/a/77161896
              sourceRoot = ".";
            };
            conf-libffi = prev.conf-libffi.overrideAttrs (
              oa:
              pkgs.lib.info oa {
                opam__depexts = oa.opam__depexts ++ [
                  "pkg-config"
                ];
              }
            );
          }
          // builtins.mapAttrs (
            p: _:
            prev.${p}.overrideAttrs (_: {
              doNixSupport = false;
            })
          ) localPackagesQuery;

        scope =
          let
            scp = on.buildOpamProject' {
              inherit pkgs;
              resolveArgs = {
                with-test = true;
                with-doc = true;
              };
            } src query;
          in
          scp.overrideScope overlay;

        devPackages = builtins.attrValues (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope);

        formatter = pkgs.nixfmt-rfc-style;
      in
      {
        legacyPackages = scope;

        devShells.default = pkgs.mkShellNoCC {
          inputsFrom = builtins.map (p: scope.${p}) localNames;
          packages = devPackages ++ [
            pkgs.nil
            formatter
          ];
        };

        inherit formatter;
      }
    );
}
