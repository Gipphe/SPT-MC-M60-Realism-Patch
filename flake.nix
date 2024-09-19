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
              cp "./result/${zipFileName}" "/mnt/c/Users/Gipphe/Downloads/MC-M60 Realism Patch.zip"
            '';
            release = pkgs.writeShellScriptBin "release" ''
              set -e
              export PATH=${pkgs.cocogitto}/bin:${pkgs.gh}/bin:${pkgs.pandoc}/bin:$PATH
              nix build
              cog bump --auto
              version="v$(cog get-version 2>/dev/null)"
              release_dir="./releases/$version"
              mkdir -p "$release_dir"
              cog changelog $version > "$release_dir/notes.md"
              pandoc --from=markdown --to=html -o "$release_dir/notes.html" "$release_dir/notes.md"
              cp "./result/MC-M60_Realism_Patch.zip" "./releases/$version/"
              git push --tags
              gh release create "$version" -F "$release_dir/notes.md" "$release_dir/${zipFileName}"
            '';
          in
          pkgs.mkShellNoCC {
            packages = with pkgs; [
              nixfmt-rfc-style
              cocogitto
            ];
            shellHook = ''
              export PATH="${release}/bin:${test-build}/bin:$PATH"
            '';
          };
      }
    );
}
