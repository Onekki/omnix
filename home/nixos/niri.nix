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
        LANG "zh_CN.UTF-8"
        XDG_CURRENT_DESKTOP "niri"
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
