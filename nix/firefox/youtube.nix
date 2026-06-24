{
  flake.aspects.gui._.firefox =
    { aspect, ... }:
    {
      includes = [ aspect._.youtube ];
      # Various youtube-related settings
      _.youtube.homeManager =
        {
          inputs',
          ...
        }:
        let
          inherit (inputs'.firefox-extensions-declarative.packages) sponsorblock-declarative;
          inherit (inputs'.firefox-extensions-declarative.packages) dearrow-declarative;
          inherit (inputs'.firefox-extensions-declarative.packages) youtube-shorts-block-declarative;
        in
        {
          programs.firefox.profiles.nix = {
            extensions.packages = [
              sponsorblock-declarative
              dearrow-declarative
              youtube-shorts-block-declarative
            ];
          };
          programs.firefox.policies = {
            ExtensionSettings.${sponsorblock-declarative.extensionId}.private_browsing = true;
            "3rdparty".Extensions.${sponsorblock-declarative.extensionId} = {
              showDonationLink = false;
              showUpsells = false;
            };
            ExtensionSettings.${dearrow-declarative.extensionId}.private_browsing = true;
            "3rdparty".Extensions.${dearrow-declarative.extensionId} = {
              showDonationLink = false;
              showUpsells = false;
              shouldCleanEmojis = false;
            };
            ExtensionSettings.${youtube-shorts-block-declarative.extensionId}.private_browsing = true;
          };
        };
    };
}
