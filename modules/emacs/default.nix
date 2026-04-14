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
          pkgs,
          ...
        }:
        {
          programs.emacs = {
            enable = true;
            package = pkgs.emacs-pgtk;
            extraPackages =
              epkgs: with epkgs; [
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
        };
    };
}
