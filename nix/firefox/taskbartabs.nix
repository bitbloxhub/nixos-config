{
  flake.aspects.gui._.firefox =
    { aspect, ... }:
    {
      includes = [ aspect._.taskbartabs ];
      _.taskbartabs.homeManager =
        let
          taskbartabs = [
            {
              id = "efced280-92b5-4169-bb9c-8e37f07d5516";
              name = "Google Chat";
              scopes = [ { hostname = "https://mail.google.com/chat/u/0"; } ];
              startUrl = "https://chat.google.com";
              userContextId = 0;
            }
          ];
        in
        {
          home.file.".mozilla/firefox/nix/taskbartabs/taskbartabs.json".text = builtins.toJSON {
            taskbarTabs = taskbartabs;
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
            }) taskbartabs
          );
        };
    };
}
