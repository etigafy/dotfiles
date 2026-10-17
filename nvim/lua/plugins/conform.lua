local defer = require("config.defer")

return function()
  -- Only registers a BufWritePre hook and a few commands, so it can wait.
  defer.later(function()
    local conform = require("conform")

    conform.setup({
      -- Note the hyphen: `clang_format` is a deprecated alias in conform 9.x.
      -- clang-format is invoked with `-assume-filename <path>`, so it picks up
      -- the nearest .clang-format walking up from the file itself -- per-project
      -- style works with no configuration here.
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        h = { "clang-format" },
      },

      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    })

    -- clang-format rewrites the WHOLE file, which in a big shared tree (the
    -- kernel) means a diff touching lines you never edited. These let you turn
    -- it off per buffer (!) or globally, and format just a range instead.
    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, { desc = "Disable format-on-save (! = this buffer only)", bang = true })

    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, { desc = "Re-enable format-on-save" })

    vim.api.nvim_create_user_command("Format", function(args)
      local range
      if args.count ~= -1 then
        -- :'<,'>Format -- format only the selected lines
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, 999999 },
        }
      end
      conform.format({ async = true, lsp_format = "fallback", range = range })
    end, { desc = "Format buffer or range", range = true })

    vim.keymap.set({ "n", "v" }, "<leader>cf", function()
      conform.format({ async = true, lsp_format = "fallback" })
    end, { desc = "Format buffer/selection" })

    vim.keymap.set("n", "<leader>cF", function()
      if vim.b.disable_autoformat or vim.g.disable_autoformat then
        vim.cmd("FormatEnable")
        vim.notify("format-on-save enabled")
      else
        vim.cmd("FormatDisable")
        vim.notify("format-on-save disabled (global)")
      end
    end, { desc = "Toggle format-on-save" })
  end)
end
