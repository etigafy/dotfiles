local defer = require("config.defer")

return function()
  -- mason.setup() stays eager: it puts mason's bin dir on PATH, which has to
  -- happen before any server is spawned.
  require("mason").setup({})

  -- mason-lspconfig 2.x pulls in the whole mason registry, which costs ~25ms
  -- at startup. Nothing it does is needed on the critical path -- ensure_installed
  -- is a background install check and :LspInstall is interactive -- so it waits
  -- until after startup. clangd is enabled explicitly below, not by this.
  defer.later(function()
    require("mason-lspconfig").setup({
      ensure_installed = { "clangd" },
    })
  end)

  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  vim.lsp.config("clangd", {
    cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never" },
    capabilities = capabilities,
  })
  vim.lsp.enable("clangd")

  vim.diagnostic.config({ virtual_text = false })

  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
  end
  map("<leader>e", vim.diagnostic.open_float, "Diagnostics (float)")
  map("K", vim.lsp.buf.hover, "Hover")
  map("<leader>j", vim.lsp.buf.definition, "Go to definition")
  map("<leader>b", "<C-o>", "Jump back")
  map("<leader>ca", vim.lsp.buf.code_action, "Code action")
end
