{
  description = "A basic flake to help develop deepin-terminal-gtk";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
          packages = {
            default = deepin-terminal-gtk;
            gtk4 = deepin-terminal-gtk.override { gtkVersion = "4"; };
          };

          devShell = pkgs.mkShell {
            packages = with pkgs; [
              vala-lint
              vala-language-server
              uncrustify
            ];

            inputsFrom = [
              packages.default
            ];

            shellHook = ''
              echo "Hello Hack for deepin-terminal-gtk!"
            '';
          };
        }
      );
}
