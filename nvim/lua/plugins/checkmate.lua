return function()
  -- Deliberately NOT deferred. Checkmate's keymaps are all `<Cmd>Checkmate ...<CR>`
  -- and `:Checkmate` is a *buffer-local* command created from its FileType autocmd.
  -- When setup() runs after a todo buffer is already loaded (i.e. `nvim TODO.md`
  -- with a deferred setup), it takes the H.setup_existing_markdown_buffers() path,
  -- which activates highlighting and keymaps but never creates the command -- so
  -- every mapping fails with E492. Still the case in v0.12.1. Costs ~8ms.
  require("checkmate").setup({
    -- Scoped to todo.md only. The plugin's own defaults are broader --
    -- they also match bare `todo`/`TODO` and any `*.todo` / `*.todo.md`.
    files = { "todo.md", "TODO.md" },
  })
end
