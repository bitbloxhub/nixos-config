{
  inputs,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.firefox";

  homeManager.ifEnabled =
    {
      pkgs,
      ...
    }:
    let
      userChromeToggleExtensionId = "userchrome-toggle-extended@n2ezr.ru";
      src = (import ./npins).userchrome-toggle-extended-2-declarative;
      userchrome-toggle-extended-2-declarative = pkgs.stdenv.mkDerivation {
        inherit src;
        name = "userchrome-toggle-extended-2-declarative";
        nativeBuildInputs = [
          pkgs.zip
        ];
        buildPhase = ''
          zip -r ../userchrome-toggle-extended-2-declarative.xpi .
        '';
        installPhase = ''
          dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
          mkdir -p $dst
          cp ../userchrome-toggle-extended-2-declarative.xpi $dst/${userChromeToggleExtensionId}.xpi
        '';
      };
    in
    {
      programs.firefox.profiles.nix = {
        extensions.packages = [
          userchrome-toggle-extended-2-declarative
        ];
      };
      programs.firefox.policies = {
        ExtensionSettings.${userChromeToggleExtensionId}.private_browsing = true;
        "3rdparty".Extensions.${userChromeToggleExtensionId} = {
          allowMultiple = true;
          closePopup = true;
          toggles = [
            {
              name = "Hide Left Sidebar";
              enabled = true;
              # Fix for nix not doing \u correctly
              prefix = builtins.fromJSON ''"\u180E"'';
              default_state = true;
            }
            {
              name = "Hide Right Sidebar";
              enabled = true;
              prefix = builtins.fromJSON ''"\u200B"'';
              default_state = false;
            }
            {
              name = "Hide Navbar";
              enabled = true;
              prefix = builtins.fromJSON ''"\u200C"'';
              default_state = false;
            }
            {
              name = "not used";
              enabled = false;
              prefix = builtins.fromJSON ''"\u200D"'';
              default_state = false;
            }
            {
              name = "not used";
              enabled = false;
              prefix = builtins.fromJSON ''"\u200E"'';
              default_state = false;
            }
            {
              name = "not used";
              enabled = false;
              prefix = builtins.fromJSON ''"\u200F"'';
              default_state = false;
            }
          ];
        };
      };
    };
}
