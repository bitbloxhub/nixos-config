{
  inputs,
  ...
}:
{
  flake-file.inputs.minimal-emacs = {
    url = "github:jamescherti/minimal-emacs.d";
    flake = false;
  };

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      treefmt.settings.formatter."elisp-autofmt" = {
        command = pkgs.bash;
        includes = [ "**/*.el" ];
        options = [
          "-euc"
          ''
            autofmt_el="$(echo ${pkgs.emacsPackages.elisp-autofmt}/share/emacs/site-lisp/elpa/elisp-autofmt-*/elisp-autofmt.el)"
            for f in "$@"; do
              ELISP_AUTOFMT_FILE="$f" ${pkgs.emacs}/bin/emacs --batch --quick \
                --eval "(progn
                  (load-file \"$autofmt_el\")
                  (setq elisp-autofmt-python-bin \"${pkgs.python3}/bin/python3\")
                  (setq elisp-autofmt-cache-directory (expand-file-name \"elisp-autofmt-cache\" temporary-file-directory))
                  (let ((file (getenv \"ELISP_AUTOFMT_FILE\")))
                    (find-file file)
                    (emacs-lisp-mode)
                    (elisp-autofmt-buffer)
                    (save-buffer)))"
            done
          ''
          "--"
        ];
      };
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
            home.packages = [
              pkgs.nerd-fonts.fira-code
            ];
            programs.emacs = {
              enable = true;
              package = pkgs.emacs-pgtk;
              extraPackages =
                epkgs: with epkgs; [
                  (
                    let
                      libExt = pkgs.stdenv.hostPlatform.extensions.sharedLibrary;
                      module = pkgs.fetchurl {
                        hash = "sha256-R/m5mFHLAy7MhdE0t93e8AJJ4wPRmMnCWI//LilXXd4=";
                        url = "https://github.com/dakra/ghostel/releases/download/v0.20.1/ghostel-module-x86_64-linux.so";
                      };
                      pname = "ghostel";
                      rpath = pkgs.lib.makeLibraryPath [
                        pkgs.stdenv.cc.cc.lib
                        pkgs.glibc
                      ];
                      src = pkgs.fetchFromGitHub {
                        hash = "sha256-UZ/AGuuvdhjTqx4IBIp4w/NuqklAvecl6bkpSEs3izY=";
                        owner = "dakra";
                        repo = "ghostel";
                        rev = "v${version}";
                      };
                      version = "0.20.1";
                    in
                    melpaBuild {
                      inherit pname version src;
                      files = ''
                        (:defaults "etc" "ghostel-module${libExt}")
                      '';
                      nativeBuildInputs = [ pkgs.patchelf ];
                      packageRequires = [ ];
                      preBuild = ''
                        install ${module} ghostel-module${libExt}
                        patchelf --set-rpath "${rpath}" ghostel-module${libExt}
                      '';
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
                  default-column-width.fixed = 1440;
                  default-window-height.fixed = 720;
                  matches = [ { title = "Emacs Float"; } ];
                  open-floating = true;
                  open-focused = true;
                }
              ];
            };
          })
        ];
    };
}
