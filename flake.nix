{
  description = "Anyrun system actions plugin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      crane,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
            let
              pkgs = nixpkgs.legacyPackages.${system};
              inherit (pkgs) lib;
      
              craneLib = crane.mkLib pkgs;
      
        # We need to include the vendor directory in the source
        src = lib.cleanSourceWith {
          src = ./.;
          filter = path: type: 
            (lib.hasInfix "/vendor" path) || 
            (craneLib.filterCargoSources path type);
        };

        anyrun-system = craneLib.buildPackage {
          inherit src;
          strictDeps = true;
          cargoExtraArgs = "--lib";
          postInstall = ''
            mkdir -p $out/lib
            [ -f target/release/libanyrun_system.so ] && cp target/release/libanyrun_system.so $out/lib/libanyrun-system.so
            [ -f target/release/libanyrun_system.dylib ] && cp target/release/libanyrun_system.dylib $out/lib/libanyrun-system.so
            true
          '';
          doCheck = false;
        };
      in
      {
        packages.default = anyrun-system;
        formatter = pkgs.nixfmt;
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.cargo
            pkgs.rustc
            pkgs.rust-analyzer
          ];
        };
      }
    );
}
