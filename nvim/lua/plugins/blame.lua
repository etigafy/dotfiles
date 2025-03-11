return {
   	'APZelos/blamer.nvim',
	config = function()
      -- Optional configuration for blamer.nvim
      vim.g.blamer_enabled = 1
      vim.g.blamer_show_in_insert_modes = 0
      vim.g.blamer_prefix = ' > '
    	end,
    	event = "BufRead", -- Lazy-load on file read
}
