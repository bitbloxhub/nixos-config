{
  flake.aspects.gui._.firefox =
    { aspect, ... }:
    {
      includes = [ aspect._.userchrome-toggle ];
      _.userchrome-toggle.homeManager =
        {
          inputs',
          ...
        }:
        let
          userChromeToggleExtensionId = "userchrome-toggle-extended@n2ezr.ru";
        in
        {
          programs.firefox = {
            policies = {
              "3rdparty".Extensions.${userChromeToggleExtensionId} = {
                allowMultiple = true;
                closePopup = true;
                toggles = [
                  {
                    default_state = true;
                    enabled = true;
                    name = "Hide Left Sidebar";
                    # Fix for nix not doing \u correctly
                    prefix = builtins.fromJSON ''"\u180E"'';
                  }
                  {
                    default_state = false;
                    enabled = true;
                    name = "Hide Right Sidebar";
                    prefix = builtins.fromJSON ''"\u200B"'';
                  }
                  {
                    default_state = false;
                    enabled = true;
                    name = "Hide Navbar";
                    prefix = builtins.fromJSON ''"\u200C"'';
                  }
                  {
                    default_state = false;
                    enabled = false;
                    name = "not used";
                    prefix = builtins.fromJSON ''"\u200D"'';
                  }
                  {
                    default_state = false;
                    enabled = false;
                    name = "not used";
                    prefix = builtins.fromJSON ''"\u200E"'';
                  }
                  {
                    default_state = false;
                    enabled = false;
                    name = "not used";
                    prefix = builtins.fromJSON ''"\u200F"'';
                  }
                ];
              };
              ExtensionSettings.${userChromeToggleExtensionId}.private_browsing = true;
            };
            profiles.nix.extensions.packages = [
              inputs'.firefox-extensions-declarative.packages.userchrome-toggle-extended-2-declarative
            ];
          };
        };
    };
}
