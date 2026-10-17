local defer = require("config.defer")

return function()
  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
  end

  -- Keymaps are bound eagerly but only require() telescope when pressed, so
  -- none of telescope is on the startup path.
  map("<leader>fg", function() require("telescope.builtin").live_grep() end, "Live grep")
  map("<leader>ff", function() require("telescope.builtin").find_files() end, "Find files")
  map("<leader>fh", function() require("telescope.builtin").help_tags() end, "Help tags")
  map("<leader>fb", function() require("telescope.builtin").buffers() end, "Buffers")

  map("<leader>fw", function()
    require("telescope-live-grep-args.shortcuts").grep_word_under_cursor({
      postfix = "",
      quote = false,
      trim = false,
    })
  end, "Grep word under cursor")

  map("<leader>fu", function()
    require("telescope.builtin").lsp_document_symbols({ symbols = "function" })
  end, "Find all functions within current file")

  defer.later(function()
    local telescope = require("telescope")

    -- One setup() call. Under lazy.nvim this config had two competing
    -- telescope.setup() calls (the ui-select spec clobbered the first).
    telescope.setup({
      extensions = {
        ["ui-select"] = { require("telescope.themes").get_dropdown({}) },
      },
    })
    telescope.load_extension("live_grep_args")
    telescope.load_extension("ui-select")
  end)
end
