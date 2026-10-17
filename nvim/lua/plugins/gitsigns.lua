return function()
  require("gitsigns").setup()
  vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
  vim.keymap.set("n", "<leader>lb", ":Gitsigns blame_line<CR>", { desc = "Blame line" })
end
