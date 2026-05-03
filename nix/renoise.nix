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
                home.packages = [
                  (pkgs.writeShellScriptBin "renoise" ''
                    exec ${pkgs.pipewire.jack}/bin/pw-jack ${pkgs.renoise}/bin/renoise "$@"
                  '')
                ];

                xdg.desktopEntries.renoise = {
                  name = "Renoise";
                  genericName = "Music Tracker";
                  comment = "A music composition program";
                  categories = [
                    "AudioVideo"
                    "Audio"
                  ];
                  exec = "renoise %f";
                  terminal = false;
                  startupNotify = false;
                  icon = "${pkgs.renoise}/share/icons/hicolor/128x128/apps/renoise.png";
                  mimeType = [
                    "application/x-renoise-module"
                    "application/x-renoise-rns-module"
                  ];
                };

                home.persistence."/persistent".directories = [ ".config/REAPER" ];
              };
          };
        };
    };
}
