-- Plugin management with Neovim's builtin |vim.pack| (needs 0.12+).
--
-- Day-to-day:
--   :lua vim.pack.update()                           update all, review, :w to
--                                                    confirm / :q to discard
--   :lua vim.pack.update({ "telescope.nvim" })       update one
--   :lua vim.pack.update(nil, { offline = true })    browse what's installed
--   :lua vim.pack.del({ "name" })                    remove from disk
--
-- Plugins live in ~/.local/share/nvim/site/pack/core/opt/.
-- The lockfile is ~/.config/nvim/nvim-pack-lock.json -- it is part of the
-- config, so commit it after every confirmed update.

-- Unused builtin runtime plugins. lazy.nvim disabled these by default; without
-- it they get sourced on every startup.
for _, plugin in ipairs({
  "gzip",
  "matchit",
  "matchparen",
  "netrwPlugin",
  "tarPlugin",
  "tohtml",
  "tutor",
  "zipPlugin",
}) do
  vim.g["loaded_" .. plugin] = 1
end

local function gh(repo)
  return "https://github.com/" .. repo
end

-- Build hooks. Registered BEFORE the first vim.pack.add() so they also fire
-- on a cold install (including the bulk install from a committed lockfile).
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("pack-build", { clear = true }),
  callback = function(ev)
    local name, kind, path = ev.data.spec.name, ev.data.kind, ev.data.path
    if kind ~= "install" and kind ~= "update" then
      return
    end

    if name == "LuaSnip" then
      -- was: build = "make install_jsregexp"
      vim.system({ "make", "install_jsregexp" }, { cwd = path }):wait()
    elseif name == "nvim-treesitter" then
      -- was: build = ":TSUpdate"
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({
  -- Shared libraries first. vim.pack.add() has no dependency resolution, so
  -- anything other plugins require() has to be listed above them.
  { src = gh("nvim-lua/plenary.nvim") },
  { src = gh("MunifTanjim/nui.nvim") },
  { src = gh("nvim-tree/nvim-web-devicons") },

  -- Colorschemes. catppuccin needs an explicit name or it would land in a
  -- directory called "nvim" (the repo is catppuccin/nvim).
  { src = gh("catppuccin/nvim"), name = "catppuccin" },
  { src = gh("folke/tokyonight.nvim") },

  -- Treesitter. Tracks the `main` branch (repo default) -- the rewrite.
  -- Needs nvim >= 0.12, tree-sitter CLI >= 0.26.1, curl, tar and a C compiler.
  { src = gh("nvim-treesitter/nvim-treesitter") },
  { src = gh("nvim-treesitter/nvim-treesitter-context") },

  -- LSP + tooling. mason-lspconfig 2.x requires mason >= 2.0 and
  -- nvim-lspconfig >= 2.0, so these three move together -- keep them in sync.
  { src = gh("neovim/nvim-lspconfig"), version = "v2.12.0" },
  { src = gh("mason-org/mason.nvim"), version = "v2.3.1" },
  { src = gh("mason-org/mason-lspconfig.nvim"), version = "v2.3.0" },

  -- Completion + snippets
  { src = gh("hrsh7th/nvim-cmp") },
  { src = gh("hrsh7th/cmp-nvim-lsp") },
  { src = gh("L3MON4D3/LuaSnip") },
  { src = gh("saadparwaiz1/cmp_luasnip") },
  { src = gh("rafamadriz/friendly-snippets") },

  -- Finder
  { src = gh("nvim-telescope/telescope.nvim"), version = "v0.2.2" },
  { src = gh("nvim-telescope/telescope-live-grep-args.nvim") },
  { src = gh("nvim-telescope/telescope-ui-select.nvim") },

  -- Git
  { src = gh("lewis6991/gitsigns.nvim") },
  { src = gh("tpope/vim-fugitive") },
  { src = gh("APZelos/blamer.nvim") },

  -- UI
  { src = gh("nvim-lualine/lualine.nvim") },
  { src = gh("nvim-neo-tree/neo-tree.nvim") },
  { src = gh("folke/noice.nvim") },
  { src = gh("goolord/alpha-nvim") },

  -- Editing
  { src = gh("windwp/nvim-autopairs") },
  { src = gh("karb94/neoscroll.nvim") },
})

-- Each module under lua/plugins/ returns a function that configures itself and
-- decides whether to run now or defer (see lua/config/defer.lua).
for _, mod in ipairs({
  "colorscheme",
  "treesitter",
  "lsp-config",
  "completions",
  "telescope",
  "gitsigns",
  "lualine",
  "neoscroll",
  "alpha",
  "neo-tree",
  "noice",
  "autopairs",
  "blame",
}) do
  local ok, err = pcall(require("plugins." .. mod))
  if not ok then
    vim.notify(("plugins.%s failed: %s"):format(mod, err), vim.log.levels.ERROR)
  end
end
