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
        fileName = "M60-Realism-Patch";
        zipFileName = "${fileName}.zip";
      in
      {
        packages.default = stdenv.mkDerivation {
          name = fileName;
          src = ./user;
          buildInputs = [ pkgs.zip ];
          buildPhase = ''
            zip -r "${zipFileName}" "$src"
          '';
          installPhase = ''
            mkdir -p $out
            mv "${zipFileName}" $out
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
