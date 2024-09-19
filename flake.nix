{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib stdenv;
      in
      {
        packages.default = stdenv.mkDerivation {
          name = "M60-Realism-Patch";
          src = ./user;
          buildInputs = [ pkgs.zip ];
          buildPhase = ''
            zip -r "M60-Realism-Patch.zip" "$src"
          '';
          installPhase = ''
            mkdir -p $out
            mv "M60-Realism-Patch.zip" $out
          '';
        };
        devShells.default =
          let
            release = pkgs.writeShellScriptBin "release" ''
              set -e
              nix build
              ${lib.getExe pkgs.semantic-release}
            '';
          in
          pkgs.mkShellNoCC {
            packages = with pkgs; [
              nixfmt-rfc-style
              semantic-release
            ];
            shellHook = ''
              export PATH="${release}/bin:$PATH"
            '';
          };
      }
    );
}
