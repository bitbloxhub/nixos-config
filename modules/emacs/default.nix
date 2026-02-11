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
                easysession
                org
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
          xdg.configFile."emacs".source = pkgs.symlinkJoin {
            name = "emacs-config";
            paths = [
              inputs.minimal-emacs
              ./.
            ];
          };
        };
    };
}
