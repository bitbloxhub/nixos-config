{
  flake.modules.homeManager.default =
    {
      pkgs,
      ...
    }:
    let
      userChromeToggleExtensionId = "userchrome-toggle-extended@n2ezr.ru";
      src = pkgs.fetchFromGitHub {
        owner = "bitbloxhub";
        repo = "userchrome-toggle-extended-2-declarative";
        rev = "ade2f8f9c003a04cfccc99f16e110359729303c0";
        hash = "sha256-sItk960a9ok7CAgYXa9fXLrgYFZ5ii7Oigpa9u2e0h4=";
      };
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
      programs.firefox.policies."3rdparty".Extensions.${userChromeToggleExtensionId} = {
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
}
