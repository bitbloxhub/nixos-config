{
  inputs,
  ...
}:
inputs.not-denix.lib.module {
  name = "programs.firefox";

  homeManager.ifEnabled =
    {
      inputs',
      ...
    }:
    {
      programs.firefox.profiles.nix = {
        extensions.packages = with inputs'.firefox-addons.packages; [
          ublock-origin
        ];
      };
      programs.firefox.policies = {
        ExtensionSettings."uBlock0@raymondhill.net".private_browsing = true;
        "3rdparty".Extensions."uBlock0@raymondhill.net".adminSettings = {
          userSettings = {
            cloudStorageEnabled = false;
          };
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
        };
      };
    };
}
