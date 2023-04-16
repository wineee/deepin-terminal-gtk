{
  description = "A basic flake to help develop deepin-terminal-gtk";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, flake-utils, nixpkgs, nix-filter }@input:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          deepin-terminal-gtk = pkgs.callPackage ./nix {
            inherit nix-filter;
          };
        in
        rec {
          packages.default = deepin-terminal-gtk;

          devShell = pkgs.mkShell {
            inherit (packages.default) nativeBuildInputs buildInputs;
            shellHook = ''
              echo "Hello Hack for deepin-terminal-gtk!"
            '';
          };
        }
      );
}
