{
  description = "Anyrun system actions plugin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "anyrun-system";
          version = "0.1.0";

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "anyrun-0.1.0" = "sha256-hUn2PLI/7Q8bZbLbbaT5lDyeoBKxY+QO3NEEGzhxB5w=";
              "anyrun-interface-0.1.0" = "sha256-zcKI1OUg+Ukst0nasodrhKgBi61XT8vbvdK6/nuuApk=";
            };
          };

          nativeBuildInputs = [
            pkgs.cargo
            pkgs.rustc
          ];

          buildPhase = ''
            cargo build --release --lib
          '';

          installPhase = ''
            mkdir -p $out/lib
            [ -f target/release/libanyrun_system.so ] && cp target/release/libanyrun_system.so $out/lib/libanyrun-system.so
            [ -f target/release/libanyrun_system.dylib ] && cp target/release/libanyrun_system.dylib $out/lib/libanyrun-system.so
            true
          '';

          doCheck = false;
        };

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
