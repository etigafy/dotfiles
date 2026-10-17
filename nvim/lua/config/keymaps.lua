vim.cmd("set tabstop=4")
vim.cmd("set shiftwidth=4")

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

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


vim.keymap.set('n', '<leader>z', '<cmd>undo<CR>', {noremap = true, silent = true, desc = 'Undo'})

-- VIM Tab settings
vim.keymap.set('n', '<C-t>', ':tabnew<CR>', { noremap = true, silent = true, desc = 'New tab' })
vim.keymap.set('n', '<leader>1', ':tabn 1<CR>', { noremap = true, silent = true, desc = 'Go to tab 1' })
vim.keymap.set('n', '<leader>2', ':tabn 2<CR>', { noremap = true, silent = true, desc = 'Go to tab 2' })
vim.keymap.set('n', '<leader>3', ':tabn 3<CR>', { noremap = true, silent = true, desc = 'Go to tab 3' })
vim.keymap.set('n', '<leader>4', ':tabn 4<CR>', { noremap = true, silent = true, desc = 'Go to tab 4' })
vim.keymap.set('n', '<leader>5', ':tabn 5<CR>', { noremap = true, silent = true, desc = 'Go to tab 5' })
vim.keymap.set('n', '<leader>6', ':tabn 6<CR>', { noremap = true, silent = true, desc = 'Go to tab 6' })
vim.keymap.set('n', '<leader>7', ':tabn 7<CR>', { noremap = true, silent = true, desc = 'Go to tab 7' })
vim.keymap.set('n', '<leader>8', ':tabn 8<CR>', { noremap = true, silent = true, desc = 'Go to tab 8' })
vim.keymap.set('n', '<leader>9', ':tabn 9<CR>', { noremap = true, silent = true, desc = 'Go to tab 9' })

-- Man pages. Neovim ships a man pager (:Man, see :h man.lua) and 'keywordprg'
-- already points at it -- but K is bound to vim.lsp.buf.hover, so man gets its
-- own key. Opens in a vertical split; q closes it.
vim.keymap.set('n', 'man', function()
	local word = vim.fn.expand('<cword>')
	if word == '' then
		return
	end
	-- Try the likely sections in order: syscalls, then libc, then the rest.
	for _, sec in ipairs({ '2', '3', '' }) do
		local target = sec == '' and word or (sec .. ' ' .. word)
		if pcall(vim.cmd, 'vertical Man ' .. target) then
			return
		end
	end
	vim.notify('no man page for ' .. word, vim.log.levels.WARN)
end, { desc = 'Man page for word under cursor' })

-- :M printf  /  :M 2 open  -- shorthand with section completion
vim.api.nvim_create_user_command('M', function(a)
	vim.cmd('vertical Man ' .. a.args)
end, { nargs = '+', complete = 'shellcmd', desc = 'Man page in a vertical split' })
