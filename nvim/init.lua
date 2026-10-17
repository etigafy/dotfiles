-- Byte-compilation cache for Lua modules. lazy.nvim installed its own cache
-- implicitly; vim.loader is still opt-in on 0.12, so enabling it here is what
-- keeps startup comparable. Must come before anything else is required.
vim.loader.enable()

-- Leader has to be set before any plugin is configured, otherwise <leader>
-- mappings created during plugin setup bind against the wrong prefix.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.numbase")
require("config.pack")
