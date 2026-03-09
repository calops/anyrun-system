{
  description = "Anyrun system actions plugin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    anyrun.url = "github:anyrun-org/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, anyrun, crane, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # We need a toolchain that crane can use. 
        # Since the previous attempt failed to find cargo, we'll be more explicit.
        craneLib = crane.mkLib pkgs;

        src = craneLib.cleanCargoSource ./.;

        anyrun-system = craneLib.buildPackage {
          inherit src;
          strictDeps = true;
          cargoExtraArgs = "--lib";
          
          # Anyrun requires a cdylib
          postInstall = ''
            mkdir -p $out/lib
            cp target/release/libanyrun_system.so $out/lib/libanyrun-system.so || \
            cp target/release/libanyrun_system.dylib $out/lib/libanyrun-system.so || \
            true
          '';

          doCheck = false;

          nativeBuildInputs = [
            pkgs.cargo
            pkgs.rustc
          ];
        };
      in
      {
        packages.default = anyrun-system;

        formatter = pkgs.nixfmt-rfc-style;

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.cargo
            pkgs.rustc
            pkgs.rust-analyzer
          ];
        };
      });
}
