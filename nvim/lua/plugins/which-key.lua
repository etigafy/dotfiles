local defer = require("config.defer")

return function()
  -- UI helper only; nothing depends on it during startup.
  defer.later(function()
    local wk = require("which-key")
    wk.setup({
      preset = "helix",
      win = { border = "rounded" },
    })

    -- Labels for the leader prefixes. Individual mappings get their text from
    -- the `desc` passed to vim.keymap.set, so only groups are declared here.
    wk.add({
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>l", group = "blame" },
      { "<leader>c", group = "code" },
      { "<leader>s", group = "search" },
      { "<leader>T", group = "todo", mode = { "n", "v" } },
      { "?", desc = "Number base / bit expression", mode = { "n", "x" } },
      { "<leader>sn", group = "noice" },
    })
  end)
end
