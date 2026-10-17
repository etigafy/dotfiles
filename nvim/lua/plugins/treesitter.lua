local defer = require("config.defer")

-- Languages to keep parsers installed for. These are *parser* names, not
-- filetypes (nvim maps filetype -> language itself, e.g. sh -> bash).
local LANGS = { "lua", "c", "bash", "markdown", "cmake" }

return function()
  -- The `main` branch replaced nvim-treesitter.configs: parser management lives
  -- on the module itself, and highlighting/indent are driven by Neovim's own
  -- treesitter API. install() is async and a no-op when parsers are present.
  require("nvim-treesitter").install(LANGS)

  -- Highlighting + indent, for any filetype that actually has a parser
  -- available. Replaces `highlight = { enable = true }` / `indent = {...}`.
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
    callback = function(ev)
      local lang = vim.treesitter.language.get_lang(ev.match)
      if not lang or not pcall(vim.treesitter.language.add, lang) then
        return
      end
      pcall(vim.treesitter.start, ev.buf, lang)
      -- Treesitter indent is still marked experimental upstream; this keeps
      -- the behaviour the old `indent = { enable = true }` gave us.
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })

  defer.later(function()
    require("treesitter-context").setup({
      enable = true,
      max_lines = 1,
      trim_scope = "outer",
      mode = "cursor",
      separator = nil,
    })
    vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#262A33" })
    vim.api.nvim_set_hl(0, "TreesitterContextBottom", {})
  end)
end
