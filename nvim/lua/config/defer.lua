-- Deferred-execution helpers.
--
-- vim.pack has no declarative lazy-loading (no event/cmd/ft/keys like
-- lazy.nvim), so plugins are always on 'runtimepath' and what we defer instead
-- is the *setup* call -- which is where nearly all the startup cost lives.

local M = {}

--- Run `fn` once, after startup has settled. Replaces lazy.nvim's "VeryLazy".
function M.later(fn)
  if vim.v.vim_did_enter == 1 then
    vim.schedule(fn)
  else
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        vim.schedule(fn)
      end,
    })
  end
end

--- Run `fn` once, the first time any of `events` fires. Replaces lazy.nvim's
--- `event = "..."`.
function M.on(events, fn)
  vim.api.nvim_create_autocmd(events, { once = true, callback = fn })
end

return M
