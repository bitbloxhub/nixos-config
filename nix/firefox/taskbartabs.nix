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
        options.firefox.taskbartabs.enable = self.lib.mkDisableOption "Firefox Taskbar Tabs" // {
          default = config.firefox.enable;
        };
      };
    projectors.user.homeManager =
      user:
      let
        taskbarTabs = [
          {
            id = "efced280-92b5-4169-bb9c-8e37f07d5516";
            name = "Google Chat";
            scopes = [
              {
                hostname = "mail.google.com";
                prefix = "/chat/u/0";
              }
            ];
            startUrl = "https://chat.google.com";
            userContextId = 0;
          }
        ];
      in
      lib.mkIf user.config.firefox.taskbartabs.enable {
        home.file.".mozilla/firefox/nix/taskbartabs/taskbartabs.json".text = builtins.toJSON {
          inherit taskbarTabs;
          version = 1;
        };

        xdg.desktopEntries = builtins.listToAttrs (
          builtins.map (entry: {
            name = "firefox-nightly-taskbartabs-${entry.id}";
            value = {
              inherit (entry) name;
              exec = "firefox-nightly -taskbar-tab ${entry.id} -new-window ${entry.startUrl}";
              type = "Application";
            };
          }) taskbarTabs
        );
      };
  };
}
