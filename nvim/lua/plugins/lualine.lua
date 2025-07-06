return {
	"nvim-lualine/lualine.nvim",
	config = function()
		require('lualine').setup({
		options = {
			-- theme = 'dracula'
			theme = 'catppuccin'
		},
		sections = {
			lualine_c = { {'filename', path = 1} }
		},
		})
	end
}
