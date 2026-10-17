local defer = require("config.defer")

return function()
  -- was: event = "VeryLazy"
  defer.later(function()
    require("noice").setup({
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    })
  end)

  -- was: the `keys` table
  local function map(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  map("n", "<leader>sn", "", { desc = "+noice" })
  map("c", "<S-Enter>", function()
    require("noice").redirect(vim.fn.getcmdline())
  end, { desc = "Redirect Cmdline" })

  for lhs, cmd in pairs({
    ["<leader>snl"] = "last",
    ["<leader>snh"] = "history",
    ["<leader>sna"] = "all",
    ["<leader>snd"] = "dismiss",
    ["<leader>snt"] = "pick",
  }) do
    map("n", lhs, function()
      require("noice").cmd(cmd)
    end, { desc = "Noice " .. cmd })
  end

  map({ "i", "n", "s" }, "<c-f>", function()
    if not require("noice.lsp").scroll(4) then
      return "<c-f>"
    end
  end, { silent = true, expr = true, desc = "Scroll Forward" })

  map({ "i", "n", "s" }, "<c-b>", function()
    if not require("noice.lsp").scroll(-4) then
      return "<c-b>"
    end
  end, { silent = true, expr = true, desc = "Scroll Backward" })
end
