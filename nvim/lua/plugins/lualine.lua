return function()
  require("lualine").setup({
    options = { theme = "tokyonight" },
    sections = { lualine_c = { { "filename", path = 1 } } },
  })
end
