return {
{
  "nvim-treesitter/nvim-treesitter", 
  build = ":TSUpdate",
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = {"lua", "c", "bash", "markdown", "cmake"},
      highlight = { enable = true},
      indent = { enable = true }
    })
  end
},
{
  "nvim-treesitter/nvim-treesitter-context",
  config = function()
    require("treesitter-context").setup({
        -- Optional settings:
        enable = true,            -- Enable this plugin
        max_lines = 1,            -- Show up to 3 lines of context
        trim_scope = 'outer',     -- How to trim context
        mode = 'cursor',          -- Line under cursor determines context
        separator = nil,          -- No separator line
      })
   vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#262A33" })
   vim.api.nvim_set_hl(0, "TreesitterContextBottom", {})
    end
}
}

