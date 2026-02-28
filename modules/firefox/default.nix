{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    flake-firefox-nightly = {
      url = "github:nix-community/flake-firefox-nightly";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        lib-aggregate.follows = "lib-aggregate";
        flake-compat.follows = "";
      };
    };
    betterfox-nix = {
      url = "github:HeitorAugustoLN/betterfox-nix";
      inputs = {
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-extensions-declarative = {
      url = "github:firefox-extensions-declarative/firefox-extensions-declarative";
      inputs = {
        actions-nix.follows = "actions-nix";
        flake-file.follows = "flake-file";
        flake-parts.follows = "flake-parts";
        flint.follows = "flint";
        git-hooks.follows = "git-hooks";
        import-tree.follows = "import-tree";
        make-shell.follows = "make-shell";
        nix-auto-ci.follows = "nix-auto-ci";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
  };

  flake.aspects =
    { aspects, ... }:
    {
      gui =
        { aspect, ... }:
        {
          includes = [
            aspect._.firefox
            (aspects.system._.unfree [
              "firefox-nightly-bin"
              "firefox-nightly"
            ])
          ];
          _.firefox.homeManager =
            {
              lib,
              pkgs,
              inputs',
              ...
            }:
            let
              fx-autoconfig = pkgs.fetchFromGitHub {
                owner = "MrOtherGuy";
                repo = "fx-autoconfig";
                rev = "76232083171a8d609bf0258549d843b0536685e1";
                hash = "sha256-xiCikg8c855w+PCy7Wmc3kPwIHr80pMkkK7mFQbPCs4=";
              };
            in
            {
              imports = [
                inputs.betterfox-nix.homeModules.betterfox
              ];

              home.persistence."/persistent".directories = [ ".mozilla" ];

              catppuccin.firefox.profiles.nix.enable = false;

              home.file.".mozilla/firefox/nix/chrome" = {
                source = ./chrome;
                recursive = true;
              };

              home.file.".mozilla/firefox/nix/chrome/utils" = {
                source = "${fx-autoconfig}/profile/chrome/utils";
              };

              programs.firefox = {
                enable = true;
                # supports unsigned extensions and is updated maybe a bit too frequently
                package = inputs'.flake-firefox-nightly.packages.firefox-nightly-bin.override {
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

                policies.Permissions.Notifications = {
                  Allow = [
                    "https://mail.google.com"
                    "https://chat.google.com"
                  ];
                };

                profiles.nix = {
                  id = 0;
                  isDefault = true;
                  extensions.packages = with inputs'.firefox-addons.packages; [
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

                    nixos-options = {
                      icon = "https://search.nixos.org/favicon-96x96.png";
                      urls = [ { template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}"; } ];
                      definedAliases = [ "!nixos" ];
                    };

                    nixos-wiki = {
                      icon = "https://search.nixos.org/favicon-96x96.png";
                      urls = [ { template = "https://nixos.wiki/index.php?title=Special:Search&search={searchTerms}"; } ];
                      definedAliases = [ "!nixosw" ];
                    };

                    nixos-discourse = {
                      icon = "https://search.nixos.org/favicon-96x96.png";
                      urls = [ { template = "https://discourse.nixos.org/search?q={searchTerms}"; } ];
                      definedAliases = [ "!nixosd" ];
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
                    # See https://bugzilla.mozilla.org/show_bug.cgi?id=2010733
                    # "widget.wayland.opaque-region.enabled" = false;
                    "privacy.resistFingerprinting.block_mozAddonManager" = true;
                    "extensions.webextensions.restrictedDomains" = "";
                    "userChromeJS.firstRunShown" = true;
                    "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
                    "browser.download.useDownloadDir" = false;
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

              # See https://github.com/nix-community/home-manager/issues/6934#issuecomment-3471230590
              # home.activation =
              #   let
              #     profilePath =
              #       if pkgs.stdenv.isDarwin then
              #         "/Users/${config.my.user.username}/Library/Application\ Support/Firefox"
              #       else
              #         "/home/${config.my.user.username}/.mozilla/firefox";
              #   in
              #   {
              #     makeProfilesIniWritable =
              #       lib.hm.dag.entryAfter [ "writeBoundary" ]
              #         # bash
              #         ''
              #           ini="${profilePath}/profiles.ini"
              #           bak="${profilePath}/profiles.ini.home-manager.backup" # or whatever you use as backupFileExtension
              #
              #           # prevent failing on initial run
              #           if [ ! -e "$ini" ]; then
              #             touch "$ini"
              #           fi
              #
              #           if [ ! -f "$bak" ]; then
              #             cp -L -- "$ini" "$bak"
              #           fi
              #
              #           mv -f -- "$bak" "$ini"
              #           chmod +w "$ini"
              #         '';
              #   };

              xdg.mimeApps = {
                enable = true;
                defaultApplications = {
                  "text/html" = "firefox-nightly.desktop";
                  "x-scheme-handler/http" = "firefox-nightly.desktop";
                  "x-scheme-handler/https" = "firefox-nightly.desktop";
                  "x-scheme-handler/about" = "firefox-nightly.desktop";
                  "x-scheme-handler/unknown" = "firefox-nightly.desktop";

                  "application/xhtml+xml" = "firefox-nightly.desktop";
                  "application/x-extension-htm" = "firefox-nightly.desktop";
                  "application/x-extension-html" = "firefox-nightly.desktop";
                  "application/x-extension-shtml" = "firefox-nightly.desktop";
                  "application/x-extension-xhtml" = "firefox-nightly.desktop";
                  "application/x-extension-xht" = "firefox-nightly.desktop";
                  "x-scheme-handler/ftp" = "firefox-nightly.desktop";
                  "x-scheme-handler/chrome" = "firefox-nightly.desktop";
                  "application/x-www-browser" = "firefox-nightly.desktop";
                  "application/json" = "firefox-nightly.desktop";
                };
              };
            };
        };
    };
}
