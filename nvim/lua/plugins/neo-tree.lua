local defer = require("config.defer")

return function()
  -- Keymaps are bound eagerly so they work from the very first keypress;
  -- neo-tree's own setup is deferred until after startup.
  vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", { noremap = true, silent = true })
  vim.keymap.set("n", "<C-d>", ":Neotree close<CR>", { noremap = true, silent = true })

  -- Open the tree automatically when nvim is started on a directory.
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
    desc = "Start Neo-tree with directory",
    once = true,
    callback = function()
      if package.loaded["neo-tree"] then
        return
      end
      local stats = vim.uv.fs_stat(vim.fn.argv(0))
      if stats and stats.type == "directory" then
        require("neo-tree")
      end
    end,
  })

  defer.later(function()
    require("neo-tree").setup({
      sources = { "filesystem", "buffers", "git_status" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["<space>"] = "none",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              vim.fn.setreg("+", node:get_id(), "c")
            end,
            desc = "Copy Path to Clipboard",
          },
          ["O"] = {
            function(state)
              -- was require("lazy.util").open(...); vim.ui.open is builtin
              vim.ui.open(state.tree:get_node().path)
            end,
            desc = "Open with System Application",
          },
          ["P"] = { "toggle_preview", config = { use_float = false } },
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            unstaged = "󰄱",
            staged = "󰱒",
          },
        },
      },
    })

    vim.api.nvim_create_autocmd("TermClose", {
      pattern = "*lazygit",
      callback = function()
        if package.loaded["neo-tree.sources.git_status"] then
          require("neo-tree.sources.git_status").refresh()
        end
      end,
    })
  end)
end
