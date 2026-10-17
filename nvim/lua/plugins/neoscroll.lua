return function()
  local neoscroll = require("neoscroll")
  neoscroll.setup({ mappings = {} })

  local keymap = {
    ["<C-k>"] = { function() neoscroll.ctrl_u({ duration = 250 }) end, "Scroll up (smooth)" },
    ["<C-j>"] = { function() neoscroll.ctrl_d({ duration = 250 }) end, "Scroll down (smooth)" },
  }
  for key, spec in pairs(keymap) do
    vim.keymap.set({ "n", "v", "x" }, key, spec[1], { desc = spec[2] })
  end
end
