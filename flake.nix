{
  description = "Anyrun system actions plugin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    anyrun.url = "github:anyrun-org/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
    crane.url = "github:ipetkov/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      anyrun,
      crane,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        craneLib = crane.mkLib pkgs;
        src = craneLib.cleanCargoSource ./.;

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

