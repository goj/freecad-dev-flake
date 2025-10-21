{
  description = "A cutting edge version of FreeCAD.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    freecad-src = {
      url = "git+https://github.com/FreeCAD/FreeCAD.git?submodules=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-parts, freecad-src }@inputs:

    flake-parts.lib.mkFlake { inherit inputs; } {

      # List the systems you want to support
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { pkgs, ... }:
        let
          basePackage = pkgs.freecad;
          freecad-pkg = "${nixpkgs}/pkgs/by-name/fr/freecad";

          freecad = basePackage.overrideAttrs (oldAttrs: {
            src = freecad-src;

            version = "dev-${freecad-src.shortRev or "dirty"}";

            patches = [
              "${freecad-pkg}/0001-NIXOS-don-t-ignore-PYTHONPATH.patch"
              "${freecad-pkg}/0002-FreeCad-OndselSolver-pkgconfig.patch"
            ];
            postPatch = "";
          });

        in
        {
          packages.default = freecad;
        };
    };
}
