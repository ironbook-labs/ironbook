{
  description = "Ironbook";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      dockerShim = pkgs.writeShellScriptBin "docker" ''
        if [ "$1" = "compose" ]; then
          shift
          exec ${pkgs.podman-compose}/bin/podman-compose "$@"
        else
          exec ${pkgs.podman}/bin/podman "$@"
        fi
      '';
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.mise
          pkgs.pkgsCross.mingwW64.stdenv.cc
          pkgs.podman
          pkgs.podman-compose
          dockerShim
          pkgs.openssl
          pkgs.pkg-config
          pkgs.nasm
          pkgs.zip
        ];

        shellHook = ''
          eval "$(mise activate bash)"

          export OPENSSL_DIR="${pkgs.openssl.dev}"
          export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
          export OPENSSL_INCLUDE_DIR="${pkgs.openssl.dev}/include"
          export LD_LIBRARY_PATH="${pkgs.openssl.out}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
          export CC_x86_64_pc_windows_gnu="x86_64-w64-mingw32-gcc"
          export AR_x86_64_pc_windows_gnu="x86_64-w64-mingw32-ar"

          MINGW_PTHREAD_LIB="${pkgs.pkgsCross.mingwW64.windows.pthreads}/lib"
          if [ -d "$MINGW_PTHREAD_LIB" ]; then
            export CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS="-L $MINGW_PTHREAD_LIB''${CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS:+ $CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS}"
          fi

          if [ ! -e "$HOME/.config/containers/policy.json" ]; then
            mkdir -p "$HOME/.config/containers"
            cat <<'EOF' > "$HOME/.config/containers/policy.json"
{
  "default": [
    {
      "type": "insecureAcceptAnything"
    }
  ]
}
EOF
          fi
        '';
      };
    };
}
