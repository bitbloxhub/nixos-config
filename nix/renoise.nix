{
  flake.aspects =
    { aspects, ... }:
    {
      daw =
        { aspect, ... }:
        {
          includes = [ aspect._.renoise ];
          _.renoise = {
            includes = [
              (aspects.system._.unfree [
                "renoise"
              ])
            ];
            homeManager =
              {
                pkgs,
                ...
              }:
              {
                home = {
                  packages = [
                    (pkgs.writeShellScriptBin "renoise" ''
                      exec ${pkgs.pipewire.jack}/bin/pw-jack ${pkgs.renoise}/bin/renoise "$@"
                    '')
                  ];
                  persistence."/persistent".directories = [ ".config/REAPER" ];
                };
                xdg.desktopEntries.renoise = {
                  categories = [
                    "AudioVideo"
                    "Audio"
                  ];
                  comment = "A music composition program";
                  exec = "renoise %f";
                  genericName = "Music Tracker";
                  icon = "${pkgs.renoise}/share/icons/hicolor/128x128/apps/renoise.png";
                  mimeType = [
                    "application/x-renoise-module"
                    "application/x-renoise-rns-module"
                  ];
                  name = "Renoise";
                  startupNotify = false;
                  terminal = false;
                };
              };
          };
        };
    };
}
