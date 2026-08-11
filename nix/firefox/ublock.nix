{
  lib,
  self,
  ...
}:
{
  flake.grove = {
    types.user =
      {
        config,
        ...
      }:
      {
        options.firefox.ublock.enable = self.lib.mkDisableOption "uBlock Origin" // {
          default = config.firefox.enable;
        };
      };
    projectors.user.homeManager =
      user:
      {
        inputs',
        ...
      }:
      lib.mkIf user.config.firefox.ublock.enable {
        programs.firefox = {
          policies = {
            "3rdparty".Extensions."uBlock0@raymondhill.net".adminSettings = {
              selectedFilterLists = [
                "user-filters"
                "ublock-filters"
                "ublock-badware"
                "ublock-privacy"
                "ublock-quick-fixes"
                "ublock-unbreak"
                "easylist"
                "easyprivacy"
                "urlhaus-1"
                "plowe-0"
                "fanboy-cookiemonster"
                "ublock-cookies-easylist"
                "adguard-cookies"
                "ublock-cookies-adguard"
                "easylist-chat"
                "easylist-newsletters"
                "easylist-notifications"
                "easylist-annoyances"
                "adguard-mobile-app-banners"
                "adguard-other-annoyances"
                "adguard-popup-overlays"
                "adguard-widgets"
                "ublock-annoyances"
              ];
              userSettings.cloudStorageEnabled = false;
            };
            ExtensionSettings."uBlock0@raymondhill.net".private_browsing = true;
          };
          profiles.nix.extensions.packages = with inputs'.firefox-addons.packages; [
            ublock-origin
          ];
        };
      };
  };
}
