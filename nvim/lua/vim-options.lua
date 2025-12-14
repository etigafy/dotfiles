vim.cmd("set tabstop=4")
vim.cmd("set shiftwidth=4")

vim.api.nvim_create_autocmd("FileType", {
	pattern = {"c", "h"},
	callback = function()
		vim.opt_local.tabstop = 8
		vim.opt_local.shiftwidth = 8
		vim.opt_local.expandtab = false
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "dts", "dtsi" },
	callback = function()
		vim.opt_local.tabstop = 8
		vim.opt_local.shiftwidth = 8
		vim.opt_local.expandtab = false
	end,
})


vim.g.mapleader = " "
vim.keymap.set('n', '<leader>z', '<cmd>undo<CR>', {noremap = true, silent = true})

-- VIM Tab settings
vim.keymap.set('n', '<C-t>', ':tabnew<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>1', ':tabn 1<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>2', ':tabn 2<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>3', ':tabn 3<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>4', ':tabn 4<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>5', ':tabn 5<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>6', ':tabn 6<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>7', ':tabn 7<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>8', ':tabn 8<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>9', ':tabn 9<CR>', { noremap = true, silent = true })
