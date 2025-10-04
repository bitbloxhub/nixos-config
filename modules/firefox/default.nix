{
  lib,
  inputs,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.firefox = {
      enable = lib.my.mkDisableOption "Firefox";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      pkgs,
      ...
    }:
    let
      fx-autoconfig = pkgs.fetchFromGitHub {
        owner = "MrOtherGuy";
        repo = "fx-autoconfig";
        rev = "849602523e2a7fe7747dd964cc028e54078a5247";
        hash = "sha256-ibtYuRv21s4T+PbV0o3jRAuG/6mlaLzwWhkEivL1sho=";
      };
    in
    {
      my.allowedUnfreePackages = [
        "firefox-nightly-bin"
        "firefox-nightly"
      ];

      catppuccin.firefox.profiles.nix.enable = false;

      home.file.".mozilla/firefox/nix/chrome" = {
        source = ./chrome;
        recursive = true;
      };

      home.file.".mozilla/firefox/nix/chrome/utils" = {
        source = "${fx-autoconfig}/profile/chrome/utils";
      };

      programs.firefox = {
        inherit (config.my.programs.firefox) enable;
        # supports unsigned extensions and is updated maybe a bit too frequently
        package = inputs.flake-firefox-nightly.packages.${pkgs.system}.firefox-nightly-bin.override {
          extraPrefsFiles = [
            "${fx-autoconfig}/program/config.js"
          ];
        };

        betterfox = {
          enable = true;
          profiles.nix = {
            enableAllSections = true;
          };
        };

        profiles.nix = {
          id = 0;
          isDefault = true;
          extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
            tab-session-manager
            keepassxc-browser
          ];
          search.default = "brave";
          search.force = true;
          search.engines = {
            bing.metaData.hidden = true;
            # For some reason it's ebay-ch
            ebay-ch.metaData.hidden = true;
            ecosia.metaData.hidden = true;
            qwant.metaData.hidden = true;

            brave = {
              icon = "https://cdn.search.brave.com/serp/v2/_app/immutable/assets/brave-search-icon.CsIFM2aN.svg";
              name = "Brave Search";
              urls = [ { template = "https://search.brave.com/search?q={searchTerms}"; } ];
              definedAliases = [ "@bs" ];
            };

            nixpkgs = {
              icon = "https://search.nixos.org/favicon-96x96.png";
              urls = [ { template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; } ];
              definedAliases = [ "!nix" ];
            };

            home-manager-options = {
              icon = "https://home-manager-options.extranix.com/images/favicon.png";
              name = "Home Manager Options";
              urls = [
                { template = "https://home-manager-options.extranix.com/?release=master&query={searchTerms}"; }
              ];
              definedAliases = [ "!hm" ];
            };

            noogle = {
              icon = "https://noogle.dev/favicon.png";
              name = "Noogle";
              urls = [ { template = "https://noogle.dev/q?term={searchTerms}"; } ];
              definedAliases = [ "!noogle" ];
            };

            wiktionary = {
              icon = "https://en.wiktionary.org/favicon.ico";
              name = "Wiktionary";
              urls = [ { template = "https://en.wiktionary.org/wiki/{searchTerms}"; } ];
              definedAliases = [ "!wikt" ];
            };
          };
          settings = {
            "extensions.autoDisableScopes" = 0;
            "extensions.update.autoUpdateDefault" = false;
            "extensions.update.enabled" = false;
            "xpinstall.signatures.required" = false;
            "sidebar.verticalTabs" = true;
            "apz.overscroll.enabled" = false;
            "browser.urlbar.trimHttps" = lib.mkForce false;
            "browser.urlbar.trimURLs" = false;
            "browser.tabs.allow_transparent_browser" = true;
            "widget.wayland.opaque-region.enabled" = false;
            "privacy.resistFingerprinting.block_mozAddonManager" = true;
            "extensions.webextensions.restrictedDomains" = "";
            "userChromeJS.firstRunShown" = true;
            "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
            "browser.uiCustomization.state" = builtins.toJSON {
              placements = {
                widget-overflow-fixed-list = [ ];
                unified-extensions-area = [
                  "surfingkeys_brookhong_github_io-browser-action"
                ];
                nav-bar = [
                  "firefox-view-button"
                  "sidebar-button"
                  "back-button"
                  "forward-button"
                  "reset-pbm-toolbar-button"
                  "urlbar-container"
                  "vertical-spacer"
                  "userchrome-toggle-extended_n2ezr_ru-browser-action"
                  "keepassxc-browser_keepassxc_org-browser-action"
                  "tab-session-manager_sienori-browser-action"
                  "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action"
                  "_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action"
                  "addon_darkreader_org-browser-action"
                  "ublock0_raymondhill_net-browser-action"
                  "unified-extensions-button"
                  "alltabs-button"
                ];
                toolbar-menubar = [
                  "menubar-items"
                ];
                TabsToolbar = [ ];
                vertical-tabs = [
                  "tabbrowser-tabs"
                ];
                PersonalToolbar = [
                  "import-button"
                  "personal-bookmarks"
                ];
                sb2-main = [
                  "new-web-panel"
                ];
              };
              seen = [
                "reset-pbm-toolbar-button"
                "profiler-button"
                "surfingkeys_brookhong_github_io-browser-action"
                "userchrome-toggle-extended_n2ezr_ru-browser-action"
                "tab-session-manager_sienori-browser-action"
                "addon_darkreader_org-browser-action"
                "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action"
                "ublock0_raymondhill_net-browser-action"
                "_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action"
                "developer-button"
                "new-web-panel"
                "sb2-collapse-button"
                "screenshot-button"
                "keepassxc-browser_keepassxc_org-browser-action"
              ];
              dirtyAreaCache = [
                "unified-extensions-area"
                "nav-bar"
                "TabsToolbar"
                "vertical-tabs"
                "sb2-main"
                "PersonalToolbar"
                "toolbar-menubar"
              ];
              currentVersion = 23;
              newElementCount = 2;
            };
            "sidebar.backupState" = builtins.toJSON {
              panelOpen = false;
              launcherWidth = 300;
              launcherExpanded = false;
              launcherVisible = true;
              pinnedTabsHeight = 0;
              collapsedPinnedTabsHeight = 0;
            };
            "devtools.toolbox.host" = "right";
            "devtools.chrome.enabled" = true;
            "devtools.debugger.remote-enabled" = true;
            # Remove the annoying message about restoring sessions
            "browser.startup.couldRestoreSession.count" = 2;
            # PWA support
            # See https://www.reddit.com/r/firefox/comments/1mtbugu/comment/n9bvk9e/
            "browser.taskbarTabs.enabled" = true;
            "browser.search.separatePrivateDefault" = false;
          };
        };
      };
    };
}
