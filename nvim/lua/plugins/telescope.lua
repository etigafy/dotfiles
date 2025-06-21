return {
  {  
  'nvim-telescope/telescope.nvim', 
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {noremap = true, silent = true})
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {noremap = true, silent = true})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {noremap = true, silent = true})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {noremap = true, silent = true})
	-- Shortcut for searching all function within the current file --
      vim.keymap.set('n', '<leader>fu', function()
        builtin.lsp_document_symbols {
          symbols = 'function',
        }
      end, { desc = 'Find all functions within current file' })
    end
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {
            }
          }
        }
      })
      require("telescope").load_extension("ui-select")
      end  
  },
	
}
