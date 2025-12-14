return {
  "karb94/neoscroll.nvim",
  config = function()
    neoscroll = require('neoscroll')
    neoscroll.setup({ mappings = {} })
    local keymap = {
      ["<C-k>"] = function() neoscroll.ctrl_u({ duration = 250 }) end,
      ["<C-j>"] = function() neoscroll.ctrl_d({ duration = 250 }) end,
    }
    local modes = { 'n', 'v', 'x' }
    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func)
    end
  end
}
