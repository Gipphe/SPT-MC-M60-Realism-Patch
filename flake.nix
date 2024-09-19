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
        fileName = "MC-M60_Realism_Patch";
        zipFileName = "${fileName}.zip";
      in
      {
        packages.default = stdenv.mkDerivation {
          name = fileName;
          src = ./user;
          buildInputs = [ pkgs.zip ];
          buildPhase = ''
            dir="mods/SPT-Realism/db/put_new_stuff_here"
            full_dir="user/$dir"
            mkdir -p "./$full_dir"
            cp "$src/$dir/MC_M60.json" "./$full_dir/MC_M60.json"
            zip -r "${zipFileName}" user/
          '';
          installPhase = ''
            mkdir -p $out
            mv "${zipFileName}" $out
          '';
        };
        devShells.default =
          let
            test-build = pkgs.writeShellScriptBin "test-build" ''
              set -e
              nix build
              cp "./result/MC-M60_Realism_Patch.zip" "/mnt/c/Users/Gipphe/Downloads/MC-M60 Realism Patch.zip"
            '';
            release = pkgs.writeShellScriptBin "release" ''
              set -e
              nix build
              ${lib.getExe pkgs.semantic-release} -b main
            '';
          in
          pkgs.mkShellNoCC {
            packages = with pkgs; [
              nixfmt-rfc-style
              semantic-release
            ];
            shellHook = ''
              export PATH="${release}/bin:${test-build}/bin:$PATH"
            '';
          };
      }
    );
}
