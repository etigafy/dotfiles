return function()
  -- blamer.nvim is a vimscript plugin driven entirely by globals; its plugin/
  -- file is sourced during startup, so these just need to be set beforehand.
  vim.g.blamer_enabled = 1
  vim.g.blamer_show_in_insert_modes = 0
  vim.g.blamer_prefix = " > "
end
