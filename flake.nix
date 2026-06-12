{
  description = "Todoist CLI - Official Todoist command-line interface";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        spec = import ./versions.nix;

        src = pkgs.fetchFromGitHub {
          owner = "Doist";
          repo = "todoist-cli";
          rev = "v${spec.version}";
          hash = spec.srcHash;
        };

        npmDeps = pkgs.fetchNpmDeps {
          inherit src;
          hash = spec.npmHash;
        };

        todoist-cli = pkgs.buildNpmPackage {
          pname = "todoist-cli";
          inherit src npmDeps;
          version = spec.version;

          makeFlags = [ "build" ];

          nativeBuildInputs = [ pkgs.makeWrapper ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/lib/todoist-cli
            cp -r dist node_modules package.json package-lock.json $out/lib/todoist-cli/

            makeWrapper ${pkgs.nodejs}/bin/node $out/bin/td \
              --add-flags "$out/lib/todoist-cli/dist/index.js" \
              --prefix PATH : "${pkgs.lib.makeBinPath [ pkgs.nodejs ]}"

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Official Todoist command-line interface";
            homepage = "https://github.com/Doist/todoist-cli";
            license = licenses.mit;
            maintainers = [ ];
            platforms = [ "x86_64-linux" ];
          };
        };

      in
      {
        packages = {
          inherit todoist-cli;
          default = todoist-cli;
        };

        apps.default = flake-utils.lib.mkApp {
          drv = todoist-cli;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_22
            nodePackages.npm
          ];
        };
      }
    );
}