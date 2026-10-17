-- Shared Hyprland config (Lua), used by both sessions:
--   hyprland.lua  - Hyprland + waybar (default session)
--   dms.lua       - Hyprland + DankMaterialShell
-- Each entry point requires this module, then adds its shell layer
-- (autostart, launcher/lock binds) via M.autostart().

local M = {}

local mocha = require("mocha")  -- catppuccin palette (currently unused, kept for reference)

------------------
---- MONITORS ----
------------------
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0",      scale = 1 })
hl.monitor({ output = "DP-6",  mode = "1920x1080@60", position = "1920x0",   scale = 1 })
hl.monitor({ output = "DP-7",  mode = "1920x1080@60", position = "3840x-440", scale = 1, transform = 3 })

-- workspace -> monitor pinning
for _, w in ipairs({ {1,"eDP-1"},{2,"eDP-1"},{3,"eDP-1"},
                     {4,"DP-6"}, {5,"DP-6"}, {6,"DP-6"},
                     {7,"DP-7"}, {8,"DP-7"}, {9,"DP-7"} }) do
    hl.workspace_rule({ workspace = tostring(w[1]), monitor = w[2] })
end

---------------------
---- MY PROGRAMS ----
---------------------
local terminal     = "alacritty -e tmux"
local fileManager  = "nautilus"
local browser      = "brave-browser"

-------------------
---- AUTOSTART ----
-------------------
-- Starts graphical-session.target (via hyprland-session.target; greetd doesn't),
-- then the shell layer's commands.
function M.autostart(cmds)
    hl.on("hyprland.start", function()
        hl.exec_cmd("dbus-update-activation-environment --systemd --all && systemctl --user start hyprland-session.target")
        for _, cmd in ipairs(cmds) do
            hl.exec_cmd(cmd)
        end
    end)

    hl.on("hyprland.shutdown", function()
        hl.exec_cmd("systemctl --user stop hyprland-session.target")
    end)
end

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border   = "rgba(ed8796ff)",
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        blur = { enabled = true, size = 3, passes = 1, vibrancy = 0.1696 },
    },
    animations = { enabled = true },
    dwindle = { preserve_split = true },
    master  = { new_status = "master" },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        col = { splash = "rgba(00000000)" },
    },
    input = {
        kb_layout = "de", kb_variant = "", kb_model = "", kb_options = "", kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = { natural_scroll = false },
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"
M.mainMod = mainMod

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- focus: arrows + vim keys
for _, m in ipairs({ {"left","left"},{"right","right"},{"up","up"},{"down","down"},
                     {"h","left"},{"l","right"},{"k","up"},{"j","down"} }) do
    hl.bind(mainMod .. " + " .. m[1], hl.dsp.focus({ direction = m[2] }))
end

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- multimedia
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Omarchy section
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=spotify --file-forwarding com.spotify.Client @@u %U @@"), { description = "Music" })
hl.bind("SHIFT + F11", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Force full screen" })
hl.bind("SUPER + TAB",         hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
hl.bind("SUPER + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })
hl.bind("PRINT",         hl.dsp.exec_cmd("omarchy-cmd-screenshot"),        { description = "Screenshot of region" })
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("omarchy-cmd-screenshot window"), { description = "Screenshot of window" })
hl.bind("CTRL + PRINT",  hl.dsp.exec_cmd("omarchy-cmd-screenshot output"), { description = "Screenshot of display" })

--------------------------------
---- WINDOW AND LAYER RULES ----
--------------------------------
hl.window_rule({ name = "suppress-maximize-events", match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({ name = "default-opacity",          match = { class = ".*" }, opacity = "0.97 0.9" })
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})
hl.window_rule({ name = "float-network-manager", match = { title = "^(.*Network Manager.*)$" }, float = true })

hl.layer_rule({ name = "no-anim-walker",    match = { namespace = "walker" },    no_anim = true })
hl.layer_rule({ name = "no-anim-selection", match = { namespace = "selection" }, no_anim = true })

return M
