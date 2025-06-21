return {
  "nvim-neo-tree/neo-tree.nvim", branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
   config = function()
   vim.keymap.set('n', '<C-n>', ':Neotree filesystem reveal left<CR>', {noremap=true, silent=true})
   vim.keymap.set('n', '<C-d>', ':Neotree close<CR>', {noremap=true, silent=true})
   --vim.keymap.set('n', '<C-N>', ':Neotree toggle<CR>', {noremap=true, silent=true})
    local config = require("neo-tree").setup({
	    filesystem = {
    	filtered_items = {
      		hide_dotfiles = false,  -- This will show hidden files (dotfiles)
      		hide_gitignored = false, -- This will show files ignored by .gitignore
      	},
    },
    })
  end
}
