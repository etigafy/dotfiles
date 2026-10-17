-- Entry point: Hyprland + waybar (the default session).
-- Everything except the shell layer is shared with dms.lua via common.lua.

local common  = require("common")
local mainMod = common.mainMod

common.autostart({
    "/usr/libexec/polkit-mate-authentication-agent-1",
    "waybar & hyprpaper & hypridle & swaync",
})

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("wofi --show drun"))
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("/home/chris/.local/bin/swaylock-fancy -e -K -p 10 -f CaskaydiaMono-NF-Regular"), { description = "Lock" })
