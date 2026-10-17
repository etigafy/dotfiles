# nvim TODO

Migrated from lazy.nvim to builtin `vim.pack` on 2026-10-17, then bumped versions
the same day. Startup 180ms (lazy) -> 133ms. All plugins, keymaps, clangd and
treesitter verified working.

## Versions

| Plugin | Was | Now |
|---|---|---|
| mason.nvim | v2.2.1 | v2.3.1 |
| mason-lspconfig.nvim | v1.32.0 (`williamboman`) | v2.3.0 (`mason-org`) |
| nvim-lspconfig | unpinned | v2.12.0 |
| telescope.nvim | 0.1.8 | v0.2.2 |
| nvim-treesitter | `master` (frozen) | `main` (rewrite) |

The mason trio moves together: mason-lspconfig 2.x needs mason >= 2.0 and
nvim-lspconfig >= 2.0. Do not bump one alone.
Everything else tracks its default branch; `nvim-pack-lock.json` pins exact revisions.

## Cheatsheet

```
:lua vim.pack.update()                        -- update all; review, :w confirm / :q discard
:lua vim.pack.update({ "telescope.nvim" })    -- update one
:lua vim.pack.update(nil, { offline = true }) -- browse installed, no network
:lua vim.pack.del({ "name" })                 -- remove from disk
:lua = vim.pack.get()                         -- inspect state
```

Plugins: `~/.local/share/nvim/site/pack/core/opt/`
Lockfile: `nvim-pack-lock.json` (in this repo -- commit it after every confirmed update)

## 1. Finish the migration

- [ ] Use it for a few days before cleaning up the rollback path.
      Rollback = point `init.lua` at `config.lazy` instead of `config.pack`.
- [ ] Commit the migration, including `nvim-pack-lock.json`.
- [ ] Once happy, delete the lazy.nvim leftovers:
      - [ ] `rm lua/config/lazy.lua lazy-lock.json`
      - [ ] `rm -rf ~/.local/share/nvim/lazy`
- [ ] Consider `vim.pack.update()` on a slow day -- the lockfile pins the exact
      revisions that were tested, so you can always revert the file and restart.

## 2. Resolved by the version bump

- [x] **mason version mismatch** (mason 2.x paired with mason-lspconfig 1.x) --
      fixed by moving to the `mason-org/mason-lspconfig.nvim` v2.3.0 line.
      `ensure_installed = { "clangd" }` still works; 2.x also auto-enables
      mason-installed servers via `vim.lsp.enable()`. The explicit
      `vim.lsp.enable("clangd")` is kept so Fedora's `/usr/bin/clangd` works too.
      `mason-lspconfig.setup()` is deferred via `defer.later()` -- it pulls in the
      whole mason registry, which cost ~25ms at startup and is needed by nothing
      on the critical path. `mason.setup()` stays eager because it wires PATH.
- [x] **nvim-treesitter off the frozen `master` branch** -- now on `main`.
      `require("nvim-treesitter.configs")` is gone; `lua/plugins/treesitter.lua`
      now calls `require("nvim-treesitter").install(LANGS)` and starts
      highlighting from a `FileType` autocmd via `vim.treesitter.start()`.
      Verified: C, sh (filetype `sh` -> parser `bash`) and markdown all highlight,
      and treesitter indent still applies.
- [x] **telescope 0.1.8 -> v0.2.2.** 0.2.0 exists specifically to fix
      deprecations on Neovim 0.12, so the old pin was on the wrong side of that.
      `live-grep-args` and `ui-select` both verified working against it.

### Note on the treesitter `main` branch

Parsers are now **compiled locally** rather than downloaded prebuilt, so they need
`tree-sitter` CLI >= 0.26.1 (you have 0.26.11 from `tree-sitter-cli`), `curl`, `tar`
and a C compiler. A fresh machine will compile parsers in the background on first
start -- `bash` takes noticeably longer than the rest. Neovim itself bundles
c/lua/markdown/vim/vimdoc parsers in `/usr/lib64/nvim/parser/`, so highlighting for
those never fully breaks even if a compile fails.

## 3. Real problems still open

- [ ] **catppuccin is fully configured but never activated** --
      `lua/plugins/colorscheme.lua` sets it up, then selects `tokyonight`. Either
      drop catppuccin or switch to it; right now you pay its setup cost for nothing.
- [ ] **`TermClose *lazygit` autocmd with no lazygit.** `lua/plugins/neo-tree.lua`
      refreshes git status when a lazygit terminal closes, but nothing in the config
      opens lazygit. Leftover from a LazyVim copy -- either add a lazygit integration
      (see snacks.nvim below) or delete the autocmd.

### Removed during migration (were already broken)

- `neo-tree`'s `on_move` handler called `Snacks.rename.on_rename_file`, but
  snacks.nvim was never installed -- it would have errored on any file move or
  rename in the tree. Removed. Re-add it if you install snacks.nvim.
- `neo-tree`'s `O` mapping used `require("lazy.util").open`; now the builtin
  `vim.ui.open`.
- `telescope` had two competing `telescope.setup()` calls -- the ui-select spec
  silently clobbered the first. Merged into one.
- `noice`'s `if vim.o.filetype == "lazy"` message-clearing hack. Dead without lazy.

## 4. Plugins worth trying

Add to the `vim.pack.add({...})` list in `lua/config/pack.lua`, then configure in
`lua/plugins/`. `lua/config/defer.lua` has `later()` and `on()` for deferring setup.

### High value for your C workflow

- [ ] **nvim-dap** + **nvim-dap-ui** + **nvim-dap-virtual-text** -- step debugging
      for C via codelldb or gdb. The biggest actual gap in your setup: you have
      full LSP but no debugger.
- [ ] **trouble.nvim** -- a real diagnostics/quickfix list. You set
      `virtual_text = false`, so right now diagnostics are only visible via
      `<leader>e` one at a time. This is the natural companion.
- [ ] **conform.nvim** -- format on save via `clang-format`, with `.clang-format`
      respected per project. Cleaner than wiring LSP formatting by hand.
- [ ] **which-key.nvim** -- you have ~25 leader mappings across six files and no
      discoverability. Pays for itself immediately.

### Quality of life

- [ ] **undotree** -- you already set `undofile = true` and map `<leader>z`;
      this makes the history navigable instead of linear.
- [ ] **nvim-surround** -- change/add/delete surrounding brackets and quotes.
- [ ] **grug-far.nvim** -- project-wide find and replace with a live preview.
      Complements telescope, which only finds.
- [ ] **oil.nvim** -- edit the filesystem as a normal buffer. Many people run it
      alongside neo-tree: the tree for browsing, oil for bulk renames.
- [ ] **flash.nvim** -- jump anywhere on screen with two keystrokes.

### Consolidation (replace things you already have)

- [ ] **snacks.nvim** -- folke's collection; your config already assumes it exists
      (see the `Snacks.rename` note above). Would subsume `alpha-nvim` (dashboard),
      add a lazygit integration for that orphaned autocmd, plus notifier, indent
      guides, and a picker. One dependency replacing several.
- [ ] **blink.cmp** -- replaces `nvim-cmp` + `cmp-nvim-lsp` + `cmp_luasnip` +
      `cmp-buffer` with one plugin and a Rust fuzzy matcher. Roughly 20ms of your
      remaining startup is the cmp/LuaSnip stack. Note: this is your completion
      engine, so try it on a branch.
- [ ] **fzf-lua** -- faster telescope alternative. Only worth it if telescope
      feels slow on big repos; otherwise not worth relearning the keymaps.

### Notes on adding plugins under vim.pack

- No dependency resolution: list shared libraries *before* the plugins that
  `require()` them.
- No `build =`: add a case to the `PackChanged` autocmd at the top of `pack.lua`.
- No `event`/`cmd`/`ft`/`keys`: bind keymaps eagerly with a lazy `require()` inside
  the callback, and wrap `setup()` in `defer.later()`.
