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
          programs.firefox = {
            policies = {
              "3rdparty".Extensions = {
                ${dearrow-declarative.extensionId} = {
                  shouldCleanEmojis = false;
                  showDonationLink = false;
                  showUpsells = false;
                };
                ${sponsorblock-declarative.extensionId} = {
                  showDonationLink = false;
                  showUpsells = false;
                };
              };
              ExtensionSettings = {
                ${dearrow-declarative.extensionId}.private_browsing = true;
                ${sponsorblock-declarative.extensionId}.private_browsing = true;
                ${youtube-shorts-block-declarative.extensionId}.private_browsing = true;
              };
            };
            profiles.nix.extensions.packages = [
              sponsorblock-declarative
              dearrow-declarative
              youtube-shorts-block-declarative
            ];
          };
        };
    };
}
