{
  flake.aspects.gui =
    { aspect, ... }:
    {
      includes = [ aspect._.mpv ];
      _.mpv.homeManager =
        {
          pkgs,
          ...
        }:
        {
          programs.mpv = {
            enable = true;
            bindings = {
              "_" = "{image} add video-zoom -0.01"; # zoom out slowly
              "+" = "{image} add video-zoom 0.01"; # zoom in slowly
              "-" = "{image} add video-zoom -0.1"; # zoom out
              "0" = "{image} no-osd set video-zoom 0; no-osd set panscan 0"; # reset zoom
              ":" = "{image} add video-zoom -0.1";
              # Alternatively, these are easier to reach:
              ";" = "{image} add video-zoom +0.1";
              "=" = "{image} add video-zoom 0.1"; # zoom in
              "Ctrl+DOWN" = "{image} no-osd set video-align-y 1"; # align to the bottom
              "Ctrl+LEFT" = "{image} no-osd set video-align-x -1"; # align to the left
              "Ctrl+RIGHT" = "{image} no-osd set video-align-x 1"; # align to the right
              "Ctrl+UP" = "{image} no-osd set video-align-y -1"; # align to the top
              "Ctrl+h" = "{image} no-osd set video-align-x -1"; # align to the left
              "Ctrl+j" = "{image} no-osd set video-align-y 1"; # align to the bottom
              "Ctrl+k" = "{image} no-osd set video-align-y -1"; # align to the top
              "Ctrl+l" = "{image} no-osd set video-align-x 1"; # align to the right
              DOWN = "{image} script-binding positioning/pan-y 0.1"; # pan down
              LEFT = "{image} script-binding positioning/pan-x -0.1"; # pan left
              MBTN_LEFT = "{image} script-binding positioning/drag-to-pan";
              MBTN_LEFT_DBL = "{image} ignore";
              MBTN_MID = "{image} script-binding positioning/align-to-cursor"; # pan through the whole image
              N = "playlist-next-playlist";
              P = "playlist-prev-playlist";
              RIGHT = "{image} script-binding positioning/pan-x 0.1"; # pan right
              SPACE = "{image} cycle-values image-display-duration inf 5; set pause no"; # toggle slideshow
              "Shift+DOWN" = "{image} script-binding positioning/pan-y 0.10"; # pan down slowly
              "Shift+LEFT" = "{image} script-binding positioning/pan-x -0.01"; # pan left slowly
              "Shift+RIGHT" = "{image} script-binding positioning/pan-x 0.01"; # pan right slowly
              "Shift+UP" = "{image} script-binding positioning/pan-y -0.01"; # pan up slowly
              UP = "{image} script-binding positioning/pan-y -0.1"; # pan up
              WHEEL_DOWN = "{image} script-binding positioning/cursor-centric-zoom -0.1"; # zoom out towards the cursor
              WHEEL_UP = "{image} script-binding positioning/cursor-centric-zoom 0.1"; # zoom in towards the cursor
              "[" = "{image} add image-display-duration -1"; # decrease the slideshow duration
              "]" = "{image} add image-display-duration 1"; # increase the slideshow duration
              g = "ignore";
              g-y = "script-message-to playlist_view playlist-view-toggle";
              # We don't need to change time in images
              h = "{image} repeatable playlist-prev";
              j = "{image} playlist-next-playlist";
              k = "{image} playlist-prev-playlist";
              l = "{image} repeatable playlist-next force";
              # Based on https://github.com/guidocella/mpv-image-config/blob/9cbf8680ff1b7fce3dc1df59c4b34f6826311ffb/input.conf
              n = "repeatable playlist-next force";
              # panscan crops scaled videos with different aspect ratio than the window.
              o = "{image} no-osd set panscan 1; no-osd set video-unscaled no; no-osd set video-zoom 0"; # fill black bars
              p = "repeatable playlist-prev";
              r = "cycle-values video-rotate 270 180 90 0"; # rotate counterclockwise (default: add sub-pos -1)
              t = "cycle-values video-rotate 90 180 270 0"; # rotate clockwise (default: add sub-pos +1)
              u = "{image} no-osd cycle-values video-unscaled yes no; no-osd set video-zoom 0; no-osd set panscan 0"; # toggle scaling the image to the window.
              v = "{image} cycle-values video-rotate 0 180"; # rotate by 180 degrees
              "{" = "{image} multiply image-display-duration 0.5"; # halve the slideshow duration
              "}" = "{image} multiply image-display-duration 2"; # double the slideshow duration
            };
            config = {
              image-display-duration = "inf";
              loop-file = "inf";
              loop-playlist = "inf";
              osd-font = "Fira Code";
              reset-on-next-file = "video-zoom,panscan,video-unscaled,video-align-x,video-align-y,video-rotate";
            };
            profiles = {
              # Based on https://github.com/guidocella/mpv-image-config/blob/9cbf8680ff1b7fce3dc1df59c4b34f6826311ffb/mpv.conf
              "image" = {
                input-commands-append = "no-osd set user-data/mpv/image 1; enable-section image allow-hide-cursor";
                input-preprocess-wheel = "no"; # pan diagonally with a touchpad
                profile-cond = "(get('current-tracks/video', {}).image and not get('current-tracks/video', {}).albumart) or (not get('current-tracks/video') and get('user-data/mpv/image'))";
                profile-restore = "copy";
                video-recenter = "yes"; # recenter after zooming out
              };
              non-image = {
                input-commands = "no-osd del user-data/mpv/image; disable-section image";
                profile-cond = "get('user-data/mpv/image') and (not get('current-tracks/video', {image = true}).image or get('current-tracks/audio'))";
              };
            };
            scriptOpts.uosc.timeline_style = "bar";
            scripts = with pkgs.mpvScripts; [
              mpris
              uosc
              thumbfast
              mpv-image-viewer.image-positioning
            ];
          };

          xdg.mimeApps = {
            enable = true;
            defaultApplications = {
              "audio/*" = [ "mpv.desktop" ];
              "image/*" = [ "mpv.desktop" ];
              "image/bmp" = [ "mpv.desktop" ];
              "image/gif" = [ "mpv.desktop" ];
              "image/jpeg" = [ "mpv.desktop" ];
              "image/jpg" = [ "mpv.desktop" ];
              "image/png" = [ "mpv.desktop" ];
              "image/svg+xml" = [ "mpv.desktop" ];
              "image/tiff" = [ "mpv.desktop" ];
              "image/webp" = [ "mpv.desktop" ];
              "image/x-icon" = [ "mpv.desktop" ];
              "video/*" = [ "mpv.desktop" ];
            };
          };
        };
    };
}
