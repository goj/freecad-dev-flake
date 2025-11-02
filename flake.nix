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
          freecad-pkg = "${nixpkgs}/pkgs/by-name/fr/freecad";
      
          freecad = pkgs.freecad.overrideAttrs (oldAttrs: {
            src = freecad-src;

            version = "dev-${freecad-src.shortRev or "dirty"}";

            patches = [
              "${freecad-pkg}/0001-NIXOS-don-t-ignore-PYTHONPATH.patch"
              "${freecad-pkg}/0002-FreeCad-OndselSolver-pkgconfig.patch"
            ];
            postPatch = "";

          });
          
          # A version that can co-exist with the mainline FreeCAD
          freecad-dev = freecad.overrideAttrs (oldAttrs: {
            pname = "freecad-dev";
            postInstall = (oldAttrs.postInstall or "") + ''
              ln -s $out/bin/freecad $out/bin/freecad-dev

              substituteInPlace $out/share/applications/org.freecad.FreeCAD.desktop \
                --replace "Exec=FreeCAD" "Exec=freecad-dev"
              substituteInPlace $out/share/applications/org.freecad.FreeCAD.desktop \
                --replace "Name=FreeCAD" "Name=FreeCAD (dev)"

              mv $out/share/applications/org.freecad.FreeCAD.desktop $out/share/applications/org.freecad.FreeCAD.dev.desktop
            '';
          });

        in
        {
          packages = {
            inherit freecad;
            inherit freecad-dev;
            default = freecad;
          };
        };
    };
}
