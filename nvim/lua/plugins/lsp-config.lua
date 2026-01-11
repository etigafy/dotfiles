return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({})
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    version = "v1.32.0",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
      ensure_installed = { "clangd" },
    })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()  
      -- local lspconfig = require("lspconfig")

      --lspconfig.clangd.setup({
      --  cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never" },
      --  capabilities = require('cmp_nvim_lsp').default_capabilities()
      --})
      vim.lsp.enable('clangd')

      vim.lsp.config('clangd', {
        cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never" },
        capabilities = capabilities
      })

      vim.diagnostic.config({
        virtual_text = false
      })

      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {noremap=true, silent=true})
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {noremap=true, silent=true})
      vim.keymap.set('n', '<leader>j', vim.lsp.buf.definition, {noremap=true, silent=true})
      vim.keymap.set('n', '<leader>b', '<C-o>', { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {noremap=true, silent=true})
    end
  }
}
