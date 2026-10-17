-- Hyprland config for the DMS greeter (login screen), installed as
-- /etc/greetd/hypr.lua and passed via `dms-greeter --command hyprland -C`.
-- dms-greeter appends the hyprland.start hook that launches the greeter UI,
-- so this file only adds settings on top of its built-in defaults.

hl.env("DMS_RUN_GREETER", "1")

hl.config({
	misc = {
		disable_hyprland_logo = true,
	},
	input = {
		kb_layout = "at",
	},
})
