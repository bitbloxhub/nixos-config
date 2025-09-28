{
  inputs,
  ...
}:
{
  flake.modules.homeManager.default =
    {
      pkgs,
      ...
    }:
    {
      programs.firefox.profiles.nix = {
        extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
          ublock-origin
        ];
      };
      programs.firefox.policies."3rdparty".Extensions."uBlock0@raymondhill.net".adminSettings = {
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
}
