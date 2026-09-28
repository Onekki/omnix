{ ... }:
{
  xdg.configFile."niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "us"
            }
        }
        touchpad {
            tap
            natural-scroll
        }
    }

    prefer-no-csd

    environment {
        QT_QPA_PLATFORM "wayland"
        QT_QPA_PLATFORMTHEME "gtk3"
        QT_QPA_PLATFORMTHEME_QT6 "gtk3"
        ELECTRON_OZONE_PLATFORM_HINT "auto"
    }

    layout {
        background-color "transparent"
    }

    layer-rule {
        match namespace="^quickshell$"
        place-within-backdrop true
    }

    layer-rule {
        match namespace="dms:blurwallpaper"
        place-within-backdrop true
    }

    spawn-at-startup "fcitx5" "-d"

    binds {
        Mod+Return { spawn "kitty"; }
        Mod+E { spawn "nautilus"; }
        Mod+B { spawn "firefox"; }
        Mod+Ctrl+Page_Up { move-column-to-workspace-up; }
        Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
    }

    include optional=true "dms/colors.kdl"
    include optional=true "dms/layout.kdl"
    include optional=true "dms/alttab.kdl"
    include optional=true "dms/binds.kdl"
    include optional=true "dms/outputs.kdl"
    include optional=true "dms/cursor.kdl"
    include optional=true "dms/input.kdl"
    include optional=true "dms/windowrules.kdl"
  '';
}
