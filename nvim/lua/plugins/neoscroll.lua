return function()
  local neoscroll = require("neoscroll")
  neoscroll.setup({ mappings = {} })

  local keymap = {
    ["<C-k>"] = function() neoscroll.ctrl_u({ duration = 250 }) end,
    ["<C-j>"] = function() neoscroll.ctrl_d({ duration = 250 }) end,
  }
  for key, func in pairs(keymap) do
    vim.keymap.set({ "n", "v", "x" }, key, func)
  end
end
