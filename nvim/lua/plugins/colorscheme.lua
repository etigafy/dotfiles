-- Both themes are configured; tokyonight is the one actually activated.
-- (catppuccin is set up but never selected -- see TODO.md.)
return function()
  require("catppuccin").setup({
    flavour = "auto", -- latte, frappe, macchiato, mocha
    background = { light = "latte", dark = "mocha" },
    transparent_background = false,
    show_end_of_buffer = false,
    term_colors = false,
    dim_inactive = { enabled = false, shade = "dark", percentage = 0.15 },
    no_italic = false,
    no_bold = false,
    no_underline = false,
    styles = {
      comments = { "italic" },
      conditionals = { "italic" },
      loops = {},
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
    },
    color_overrides = {
      all = { base = "#262626" },
      latte = {},
      frappe = {},
      macchiato = {},
      mocha = {},
    },
    custom_highlights = {},
    default_integrations = true,
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      notify = false,
      neotree = true,
      mini = { enabled = true, indentscope_color = "" },
    },
  })

  require("tokyonight").setup({
    style = "moon",
    transparent = true,
    on_highlights = function(hl, _)
      hl.CursorLineNr = { fg = "#FF00FF", bold = true, bg = "NONE" }
    end,
  })

  vim.cmd.colorscheme("tokyonight")
end
