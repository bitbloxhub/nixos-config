{
  lib,
  inputs,
  self,
  ...
}:
{
  flake-file.inputs.xcompose = {
    url = "github:Udzu/xcompose";
    flake = false;
  };

  flake.grove = {
    types.user.options.xcompose.enable = self.lib.mkDisableOption "XCompose and Fcitx5";
    projectors.user.homeManager =
      user:
      {
        pkgs,
        ...
      }:
      lib.mkIf user.config.xcompose.enable {
        home.packages = [ pkgs.xcompose ];
        i18n.inputMethod = {
          enable = true;
          fcitx5.settings = {
            addons = {
              classicui.globalSection = {
                EnableFractionalScale = true;
                Font = "Fira Code 12";
                ForceWaylandDPI = 0;
                MenuFont = "Fira Sans 11";
                "Vertical Candidate List" = true;
                WheelForPaging = true;
              };
              keyboard.globalSection = {
                # Makes Compose sequences expose their partial input as preedit.
                UseNewComposeBehavior = true;
              };
            };
            globalOptions = {
              Behavior = {
                # false = put preedit in the Fcitx input panel instead of
                # embedding it inside the application.
                PreeditEnabledByDefault = false;
              };
              "Behavior/DisabledAddons" = {
                "0" = "notificationitem";
                "1" = "clipboard";
              };
            };
          };
          type = "fcitx5";
        };
        xdg.configFile."XCompose".source =
          pkgs.runCommand "XCompose"
            {
              nativeBuildInputs = [ pkgs.perl ];
            }
            ''
              while IFS= read -r line; do
                case "$line" in
                  'include "HangulSyllables"')
                    cat ${inputs.xcompose}/HangulSyllables
                    ;;
                  'include "Logograms"')
                    cat ${inputs.xcompose}/Logograms
                    ;;
                  *)
                    printf '%s\n' "$line"
                    ;;
                esac
              done < ${inputs.xcompose}/Compose > "$out"

              # Compose permits a quoted string plus at most one keysym. The string
              # already contains every codepoint, so remove invalid multi-keysym suffixes.
              perl -i -pe \
                's{(:\s*"(?:\\.|[^"])*")\s+U[0-9A-Fa-f]+(?:\s+U[0-9A-Fa-f]+)+(?=\s*(?:#|$))}{$1}' \
                "$out"
            '';
      };
  };
}
