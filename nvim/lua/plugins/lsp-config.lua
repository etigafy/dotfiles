return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({})
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "clangd", "markdown_oxide" }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
	local capabilities = require('cmp_nvim_lsp').default_capabilities()	

	local lspconfig = require("lspconfig")
--	lspconfig.lua_ls.setup({capabilities = capabilities})
	lspconfig.clangd.setup({capabilities = capabilities})
	vim.diagnostic.config({
  		virtual_text = false
	})
--	lspconfig.markdown_oxide.setup({capabilities = capabilities})
	vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {noremap=true, silent=true})
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, {noremap=true, silent=true})
	vim.keymap.set('n', 'j', vim.lsp.buf.definition, {noremap=true, silent=true})
	vim.keymap.set('n', 'b', '<C-o>', { noremap = true, silent = true })		
	vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {noremap=true, silent=true})
    end
  }

}
