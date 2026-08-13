local terminal = "foot"
local fileManager = "thunar"
local browser = "google-chrome-beta"

local mainMod = "SUPER"
local userMod = "CTRL"
local singleKeyEnablerMod = ""

hl.config({
    source = "~/.config/hypr/wallust/wallust-hyprland.conf",

    monitor = {
        "eDP-1, 2560x1440@60.05, auto, 1.60, bitdepth, 10",
    },

    render = {
        direct_scanout = true,
        ctm_animation = true,
    },

    workspace = {
        "1, monitor:eDP-1, persistent:true",
        "2, monitor:eDP-1, persistent:true",
        "3, monitor:eDP-1, persistent:true",
        "4, monitor:eDP-1, persistent:true",
    },

    exec_once = {
        "dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DBUS_SESSION_BUS_ADDRESS",
        "~/.config/hypr/scripts/audio.sh &",
        'sh -c "sudo ~/.config/hypr/scripts/resolv &"',
        "/usr/lib/xdg-desktop-portal-hyprland &",
        "/usr/lib/xdg-desktop-portal-gtk &",
        "/usr/lib/xdg-desktop-portal &",
        "/usr/lib/hyprpolkitagent &",
        "hyprpaper &",
        "dunst &",
        "hypridle &",
        "wl-paste --watch clipvault store --min-entry-length 0 --max-entries 20000 --max-entry-age 5d &",
        "wl-paste -p --watch wl-copy &",
        'sh -c "sudo dell-bios-fan-control 0"',
        'sh -c "sudo i8kmon"',
    },

    env = {
        "GDK_SCALE,1",
        "GDK_BACKEND,wayland,x11,*",
        "CLUTTER_BACKEND,wayland",
        "QT_AUTO_SCREEN_SCALE_FACTOR,1",
        "XCURSOR_SIZE,20",
        "HYPRCURSOR_THEME,MyCursor",
        "HYPRCURSOR_SIZE,20",
        "XDG_CURRENT_DESKTOP,Hyprland",
        "XDG_SESSION_TYPE,wayland",
        "XDG_SESSION_DESKTOP,Hyprland",
    },

    ecosystem = {
        enforce_permissions = false,
    },

    permission = {
        "/usr/bin/hyprlock, screencopy, allow",
        "/usr/bin/hypridle, screencopy, allow",
        "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland, screencopy, allow",
    },

    general = {
        gaps_in = 1,
        gaps_out = 0,
        border_size = 1,
        ["col.active_border"] = "$color1 $color3 $color5 $color7 $color8 $color10 $color12 $color14 $color2 45deg",
        ["col.inactive_border"] = "$background",
        resize_on_border = true,
        allow_tearing = true,
        layout = "master",
    },

    dwindle = {
        force_split = 2,
        preserve_split = true,
        smart_split = false,
        use_active_for_splits = true,
        default_split_ratio = 1.0,
        split_bias = 1,
        split_width_multiplier = 1.2,
        smart_resizing = false,
        precise_mouse_move = false,
    },

    master = {
        orientation = "left",
        mfact = 0.52,
        new_status = "slave",
        new_on_top = false,
        new_on_active = "none",
        allow_small_split = false,
        smart_resizing = false,
        drop_at_cursor = false,
        always_keep_position = false,
    },

    animations = {
        enabled = true,
        bezier = {
            "easeOutQuint, 0.23, 1, 0.32, 1",
            "easeInOutCubic, 0.65, 0.05, 0.36, 1",
            "linear, 0, 0, 1, 1",
            "almostLinear, 0.5, 0.5, 0.75, 1",
            "quick, 0.15, 0, 0.1, 1",
            "myBezier, 0.05, 0.9, 0.1, 1.05",
        },
        animation = {
            "global, 1, 10, default",
            "border, 1, 5.39, easeOutQuint",
            "windows, 1, 7, myBezier",
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%",
            "windowsOut, 1, 1.49, linear, popin 87%",
            "fadeIn, 1, 1.73, almostLinear",
            "fadeOut, 1, 1.46, almostLinear",
            "fade, 1, 3.03, quick",
            "layers, 1, 3.81, easeOutQuint",
            "layersIn, 1, 4, easeOutQuint, fade",
            "layersOut, 1, 1.5, linear, fade",
            "fadeLayersIn, 1, 1.79, almostLinear",
            "fadeLayersOut, 1, 1.39, almostLinear",
            "workspaces, 1, 1.94, almostLinear, fade",
            "workspacesIn, 1, 1.21, almostLinear, fade",
            "workspacesOut, 1, 1.94, almostLinear, fade",
            "zoomFactor, 1, 7, quick",
        },
    },

    decoration = {
        rounding = 3,
        rounding_power = 5,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        blur = {
            enabled = false,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
            new_optimizations = false,
            xray = false,
            ignore_opacity = false,
        },
        shadow = {
            enabled = false,
            offset = "1 2",
            range = 10,
            render_power = 4,
            color = "rgba(1a1a1aee)",
        },
    },

    windowrule = {
        "suppress_event maximize, match:class .*",
        "no_focus on, match:class ^$, match:title ^$, match:xwayland 1, match:float 1",
        "float 1, match:class ^(hyprland-run)$",
        "move (monitor_w-120) 20, match:class ^(hyprland-run)$",
        "float 1, match:class ^(dev\\.musagy\\.hypremoji)$",
        "center 1, match:class ^(dev\\.musagy\\.hypremoji)$",
        "border_size 1, match:class ^(dev\\.musagy\\.hypremoji)$",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = false,
        disable_splash_rendering = false,
        vrr = 2,
        mouse_move_enables_dpms = true,
        enable_swallow = true,
        swallow_regex = "^(kitty|Alacritty|konsole|wezterm)$",
        focus_on_activate = false,
        initial_workspace_tracking = 0,
        middle_click_paste = true,
        enable_anr_dialog = true,
        anr_missed_pings = 15,
        allow_session_lock_restore = true,
        on_focus_under_fullscreen = 1,
    },

    xwayland = {
        enabled = true,
        force_zero_scaling = true,
    },

    cursor = {
        sync_gsettings_theme = true,
        no_hardware_cursors = 2,
        enable_hyprcursor = true,
        warp_on_change_workspace = 2,
        no_warps = true,
    },

    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        repeat_rate = 25,
        repeat_delay = 200,
        sensitivity = 0.7,
        numlock_by_default = true,
        left_handed = false,
        follow_mouse = 1,
        float_switch_override_focus = false,
        touchpad = {
            disable_while_typing = true,
            natural_scroll = true,
            clickfinger_behavior = false,
            middle_button_emulation = false,
            ["tap-to-click"] = true,
            drag_lock = false,
        },
        touchdevice = {
            enabled = true,
        },
        tablet = {
            transform = 0,
            left_handed = 0,
        },
    },

    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles = true,
        pass_mouse_when_bound = false,
    },

    gestures = {
        workspace_swipe_distance = 500,
        workspace_swipe_invert = true,
        workspace_swipe_min_speed_to_force = 30,
        workspace_swipe_cancel_ratio = 0.5,
        workspace_swipe_create_new = true,
        workspace_swipe_forever = true,
        gesture = {
            "3, horizontal, workspace",
            '4, up, dispatcher, exec, hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | awk \'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor * 1.5}\')"',
            '4, down, dispatcher, exec, hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | awk \'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor / 1.5}\')"',
            "3, up, dispatcher, exec, $scriptsDir/OverviewToggle.sh",
        },
    },

    device = {
        name = "epic-mouse-v1",
        sensitivity = -0.5,
    },

    bind = {
        mainMod .. " SHIFT, P, exec, systemctl poweroff",
        mainMod .. " SHIFT, R, exec, systemctl reboot",
        mainMod .. ", U, exec, ~/.config/hypr/scripts/sudo.sh",
        mainMod .. ", B, exec, " .. browser,
        mainMod .. ", P, exec, ~/.config/hypr/scripts/phone",
        singleKeyEnablerMod .. ", PRINT, exec, hyprshot -m region",
        mainMod .. ", PRINT, exec, hyprshot -m window -o ~/Pictures/screenshots",
        mainMod .. " SHIFT, PRINT, exec, hyprshot -m output -o ~/Pictures/screenshots",
        mainMod .. ", L, exec, hyprlock",
        mainMod .. ", K, exec, kate",
        mainMod .. ", F, exec, hyprctl dispatch fullscreen",
        mainMod .. ", R, exec, ~/.config/hypr/scripts/force-reload.sh",
        mainMod .. ", 6, exec, sh -c 'IFACE=wg0 ~/.config/hypr/scripts/wireguard.sh'",
        mainMod .. ", 7, exec, sh -c 'IFACE=wg1 ~/.config/hypr/scripts/wireguard.sh'",
        mainMod .. ", 8, exec, sh -c 'IFACE=wg2 ~/.config/hypr/scripts/wireguard.sh'",
        mainMod .. ", G, togglegroup",
        mainMod .. ", Q, exec, " .. terminal,
        mainMod .. ", C, killactive,",
        mainMod .. ", E, exec, " .. fileManager,
        mainMod .. ", V, togglefloating,",
        mainMod .. ", SHIFT, pseudo,",
        mainMod .. ", M, togglespecialworkspace, magic",
        mainMod .. ", X, movetoworkspace, special:magic",
        mainMod .. ", mouse_down, workspace, e+1",
        mainMod .. ", mouse_up, workspace, e-1",
        mainMod .. ", left, movefocus, l",
        mainMod .. ", right, movefocus, r",
        mainMod .. ", up, movefocus, u",
        mainMod .. ", down, movefocus, d",
        mainMod .. ", 1, workspace, 1",
        mainMod .. ", 2, workspace, 2",
        mainMod .. ", 3, workspace, 3",
        mainMod .. ", 4, workspace, 4",
        mainMod .. " SHIFT, 1, movetoworkspace, 1",
        mainMod .. " SHIFT, 2, movetoworkspace, 2",
        mainMod .. " SHIFT, 3, movetoworkspace, 3",
        mainMod .. " SHIFT, 4, movetoworkspace, 4",
    },

    bindr = {
        mainMod .. ", period, exec, hypremoji",
        mainMod .. ", SPACE, exec, sh -c \"fuzzel; pkill fuzzel\"",
        mainMod .. " SHIFT, 6, exec, sh -c \"" .. terminal .. " -e sudo nano /etc/wireguard/wg0.conf; exit 1\"",
        mainMod .. " SHIFT, 7, exec, sh -c \"" .. terminal .. " -e sudo nano /etc/wireguard/wg1.conf; exit 1\"",
        mainMod .. " SHIFT, 8, exec, sh -c \"" .. terminal .. " -e sudo nano /etc/wireguard/wg2.conf; exit 1\"",
    },

    bindel = {
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+",
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-",
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
        ", XF86MonBrightnessUp, exec, brightnessctl -d intel_backlight set +1%",
        ", XF86MonBrightnessDown, exec, brightnessctl -d intel_backlight set 1%-",
        "SHIFT, Up, exec, bash -c 'brightnessctl -d intel_backlight set +1% && val=$(brightnessctl -d intel_backlight get); percent=$((val * 100 / 937)); notify-send -h string:x-canonical-private-synchronous:brightness \"Brightness\" \"${percent}%\"'",
        "SHIFT, Down, exec, bash -c 'brightnessctl -d intel_backlight set 1%- && val=$(brightnessctl -d intel_backlight get); percent=$((val * 100 / 937)); notify-send -h string:x-canonical-private-synchronous:brightness \"Brightness\" \"${percent}%\"'",
    },

    bindm = {
        mainMod .. ", mouse:272, movewindow",
        mainMod .. ", mouse:273, resizewindow",
    },

    bindl = {
        ", XF86AudioNext, exec, playerctl next",
        ", XF86AudioPause, exec, playerctl play-pause",
        ", XF86AudioPlay, exec, playerctl play-pause",
        ", XF86AudioPrev, exec, playerctl previous",
        ", switch:on:Lid Switch, exec, hyprlock",
        ", switch:on:Lid Switch, exec, hyprctl dispatch dpms off eDP-1",
        ", switch:off:Lid Switch, exec, hyprctl dispatch dpms on eDP-1",
        ', switch:on:Lid Switch, exec, notify-send "Lid Event" "Lid Closed (Signal Sent)" --icon=lock',
        ', switch:off:Lid Switch, exec, notify-send "Lid Event" "Lid Opened (Signal Sent)" --icon=unlock',
    },
})
