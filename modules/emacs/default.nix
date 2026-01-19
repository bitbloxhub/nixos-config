{
  inputs,
  self,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.emacs";

  flake-file.inputs.minimal-emacs = {
    url = "github:jamescherti/minimal-emacs.d";
    flake = false;
  };

  options.programs.emacs = {
    enable = self.lib.mkDisableOption "Emacs";
  };

  homeManager.ifEnabled =
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
}
