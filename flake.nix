{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    opam-repository = { url = "github:ocaml/opam-repository"; flake = false; };

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
  outputs = { self, flake-utils, opam-nix, nixpkgs, opam-repository, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        src = ./.;
        localNames =
          with builtins;
          filter
            (f: !isNull f)
            (map (f:
              let f' = match "(.*)\.opam$" f; in
              if isNull f' then null else elemAt f' 0)
              (attrNames (readDir ./.)));

        localPackagesQuery =
          with builtins; listToAttrs (map (p: {
            name = p;
            value = "*";
          }) localNames);

        devPackagesQuery = {
          ocaml-lsp-server = "*";
          utop = "*";
          dune-release = "*";
          ocamlformat = pkgs.callPackage ./nix/ocamlformat.nix { ocamlformat = ./.ocamlformat; };
        };

        query = devPackagesQuery // localPackagesQuery // {
            ocaml-system = "*";
          };

        overlay = final: prev:
          builtins.mapAttrs (p: _:
          prev.${p}.overrideAttrs (_: {
            doNixSupport = false;
          })) localPackagesQuery;

        scope =
          let scp = on.buildOpamProject' {
              inherit pkgs;
              resolveArgs = { with-test = true; with-doc = true; };
            } src query;
          in scp.overrideScope' overlay;

        devPackages = builtins.attrValues
          (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope);
      in {
        legacyPackages = scope;

        devShells.default =
          pkgs.mkShell {
            inputsFrom = builtins.map (p: scope.${p} ) localNames;
            buildInputs = devPackages;
          };
      });
}
