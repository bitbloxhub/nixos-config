{
  inputs,
  ...
}:
{
  flake-file.inputs.minimal-emacs = {
    url = "github:jamescherti/minimal-emacs.d";
    flake = false;
  };

  # even though emacs is technically an OS, it goes under the editors aspect.
  flake.aspects.editors =
    { aspect, ... }:
    {
      includes = [ aspect._.emacs ];
      _.emacs.homeManager =
        {
          lib,
          config,
          pkgs,
          ...
        }:
        lib.mkMerge [
          {
            programs.emacs = {
              enable = true;
              package = pkgs.emacs-pgtk;
              extraPackages =
                epkgs: with epkgs; [
                  (
                    let
                      pname = "ghostel";
                      version = "0.20.1";
                      src = pkgs.fetchFromGitHub {
                        owner = "dakra";
                        repo = "ghostel";
                        rev = "v${version}";
                        hash = "sha256-UZ/AGuuvdhjTqx4IBIp4w/NuqklAvecl6bkpSEs3izY=";
                      };
                      libExt = pkgs.stdenv.hostPlatform.extensions.sharedLibrary;
                      module = pkgs.fetchurl {
                        url = "https://github.com/dakra/ghostel/releases/download/v0.20.1/ghostel-module-x86_64-linux.so";
                        hash = "sha256-R/m5mFHLAy7MhdE0t93e8AJJ4wPRmMnCWI//LilXXd4=";
                      };
                      rpath = pkgs.lib.makeLibraryPath [
                        pkgs.stdenv.cc.cc.lib
                        pkgs.glibc
                      ];
                    in
                    melpaBuild {
                      inherit pname version src;
                      files = ''
                        (:defaults "etc" "ghostel-module${libExt}")
                      '';
                      nativeBuildInputs = [ pkgs.patchelf ];
                      preBuild = ''
                        install ${module} ghostel-module${libExt}
                        patchelf --set-rpath "${rpath}" ghostel-module${libExt}
                      '';
                      packageRequires = [ ];
                    }
                  )
                  compile-angel
                  catppuccin-theme
                  ligature
                  nerd-icons
                  meow
                  elisp-autofmt
                  corfu
                  cape
                  vertico
                  orderless
                  marginalia
                  embark
                  embark-consult
                  consult
                  stripspace
                  undo-fu
                  undo-fu-session
                  org
                  org-roam
                  ox-json
                  markdown-mode
                  nix-ts-mode
                  treesit-grammars.with-all-grammars
                  treesit-auto
                  avy
                  helpful
                  aggressive-indent
                  highlight-defined
                  which-key
                  centaur-tabs
                ];
            };
            home.packages = [
              pkgs.nerd-fonts.fira-code
            ];

            services.emacs.enable = true;
            xdg.configFile."emacs".source = pkgs.symlinkJoin {
              name = "emacs-config";
              paths = [
                inputs.minimal-emacs
                ./.
              ];
            };
          }

          (lib.mkIf (lib.attrByPath [ "programs" "niri" "enable" ] false config) {
            # Floating emacs window config, mostly for note taking with org-mode/org-roam
            programs.niri.settings = {
              binds."Mod+E".action.spawn = [
                "emacsclient"
                "-c"
                "-F"
                "((name . \"Emacs Float\"))"
              ];
              window-rules = [
                {
                  matches = [ { title = "Emacs Float"; } ];
                  open-floating = true;
                  open-focused = true;
                  default-column-width = {
                    fixed = 1440;
                  };
                  default-window-height = {
                    fixed = 720;
                  };
                }
              ];
            };
          })
        ];
    };
}
