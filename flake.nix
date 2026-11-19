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
        ];

        shellHook = ''
          eval "$(mise activate bash)"

          export OPENSSL_DIR="${pkgs.openssl.dev}"
          export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
          export OPENSSL_INCLUDE_DIR="${pkgs.openssl.dev}/include"
          export LD_LIBRARY_PATH="${pkgs.openssl.out}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

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
