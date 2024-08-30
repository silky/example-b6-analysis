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
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          pyEnv
        ];
      };
    });
}
