{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/24.05";
    flake-utils.url = "github:numtide/flake-utils";
    diagonal-b6.url = "github:silky/diagonal-b6/add-nix";
  };
  outputs =
    { self
    , nixpkgs
    , flake-utils
    , diagonal-b6
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      pyEnv = pkgs.python3.withPackages (ps: with ps; [
        jupyter
        diagonal-b6.packages."${system}".python
      ]);
      b6 = diagonal-b6.packages.${system};
      b6-wrapped = pkgs.writeShellScriptBin "b6" ''
        ${b6.go}/bin/b6 \
          -http=0.0.0.0:8001 \
          -grpc=0.0.0.0:8002 \
          -js=${b6.b6-js.outPath} \
          -enable-v2-ui \
          -static-v2=${b6.frontend.outPath} \
          "$@"
      '';
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          pyEnv
          b6-wrapped
          # We'll also take a whole bunch of ingest-y things
          diagonal-b6.packages."${system}".go
        ];
      };
    });
}
