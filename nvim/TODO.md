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

Keys added on top of the plugin defaults:

```
?            number under cursor -> dec/hex/oct/bin/bit positions   (normal)
?            evaluate selection as a C bit expression               (visual)
<leader>K    man page for the word under the cursor, vertical split
:M 2 open    man page lookup by section
<leader>T*   checkmate, in todo.md / TODO.md only (see below)
<leader>cf   conform: format buffer, or selection in visual mode
```

`?` replaces the builtin backwards search. Use `/pattern` then `N` for that, or
rebind if you miss it.

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
- [] **`TermClose *lazygit` autocmd with no lazygit.** `lua/plugins/neo-tree.lua`
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
- [x] **conform.nvim** v9.1.0 -- installed, format-on-save for c/cpp/h.
      Verified against two projects with different `.clang-format` files; style
      resolves per project with no config (clang-format is passed
      `-assume-filename`, so it walks up from the file itself).

      **Careful in the kernel tree:** clang-format rewrites the *whole* file, so
      saving a file you only touched two lines in produces a diff across
      everything. Controls for that:
      - `<leader>cF` toggles format-on-save globally
      - `:FormatDisable!` disables it for the current buffer only
      - `:FormatDisable` / `:FormatEnable` globally
      - `<leader>cf` formats on demand, and in visual mode formats **only the
        selection** -- this is the one to use for kernel patches
      - `:'<,'>Format` does the same from the command line

      If you want it off by default in the kernel and on elsewhere, set
      `vim.g.disable_autoformat = true` and enable per project instead.
- [x] **which-key.nvim** v3.17.0 -- installed. Groups are declared in
      `lua/plugins/which-key.lua`; individual entries come from the `desc` on
      each `vim.keymap.set`, so every mapping that was missing one now has it
      (keymaps.lua, lsp-config.lua, gitsigns.lua, neoscroll.lua, neo-tree.lua).
      Add `desc` to any new mapping and it shows up automatically.

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

### Number bases & man pages (no plugins needed)

Both of these are config, not dependencies -- nothing to update or pin.

- [x] **Number base inspector** -- `lua/config/numbase.lua`, bound to `?`.
      - Normal mode: inspects the literal under the cursor and shows decimal,
        hex, octal, binary (grouped in nibbles), **which bit positions are set**,
        and the inferred width. Reads `42`, `0x2A`, `0b101010`, `0o52`, C
        suffixes (`0xFFu`, `1UL`), and C leading-zero octal (`052`) in c/cpp/h
        buffers only -- elsewhere `052` is decimal 52.
      - Visual mode: evaluates the selection as a C bit expression, so selecting
        `(1 << 3) | (1 << 7)` reports `dec 136 / hex 0x88 / bits 3 7`. Supports
        `<< >> | & ^ ~ + - * / %` and parentheses at **C precedence** (`1 << 5 - 1`
        is `1 << 4`, and `(1 << 5) - 1` is the N-bit mask idiom).
      - Written against arithmetic rather than LuaJIT's `bit` library, which is
        32-bit only -- so u64 masks work. Exact to 2^53; past that the float
        says so rather than quietly rounding.
      - 17 unit tests covering the above live in the scratch tests; the
        `GENMASK`/`BIT`/`PAGE_SIZE-1` idioms are among them.
      - Alternative if you ever want *in-place* conversion (`crx` rewrites the
        number as hex in the buffer): `glts/vim-radical`. Stale (2024, vimscript,
        needs `vim-magnum`) and shows no bit positions, which is why it wasn't used.

- [x] **Man pages in nvim** -- no plugin: Neovim ships a man pager (`:h man.lua`)
      and `keywordprg` already defaults to `:Man`.
      - `<leader>K` opens the man page for the word under the cursor in a
        vertical split, trying section 2, then 3, then any. Verified:
        `ioctl`->`ioctl(2)`, `printf`->`printf(3)`, `memcpy`->`memcpy(3)`.
      - `:M printf` / `:M 2 open` for an explicit lookup.
      - `K` is left alone as `vim.lsp.buf.hover`. If you'd rather have one key
        do both, `lewis6991/hover.nvim` chains providers (LSP, then man) under a
        single `K`; it's maintained, but it's a plugin for something two keys
        already cover.
      - Your `man-pages 6.13` covers sections 2/3. `man-pages-posix` is **not**
        installed -- `dnf install man-pages-posix` if you want the POSIX variants.

### Todo / task management

You already keep this file as plain markdown checkboxes, which is the right
starting point -- it stays readable in git and outside nvim. Remaining options if you
ever want more:

- [x] **checkmate.nvim** v0.12.1 -- installed, scoped to `todo.md` / `TODO.md`
      only (`files` in `lua/plugins/checkmate.lua`). The plugin's own defaults are
      broader -- they also match bare `todo`/`TODO` and any `*.todo`/`*.todo.md` --
      so this is narrowed deliberately. Verified it stays inactive on README.md,
      notes.md, CHANGELOG.md and project.todo.

      In the buffer, items render as `□` / `✔`; **on disk the file stays plain
      `- [ ]` / `- [x]` markdown**, so this file is unchanged for git and still
      readable outside nvim.

      Keys are under `<leader>T` (which-key shows the group):
      `Tt` toggle, `Tc` check, `Tu` uncheck, `Tn` new item, `T=`/`T-` cycle
      state, `Ta` archive completed, `Td` toggle `@done`, `Tp` toggle
      `@priority`, `TF` picker. Also `:Checkmate <cmd>`.

      Behaviour worth knowing:
      - In **insert** mode, `<CR>` at the end of a todo line starts the next
        item (`<S-CR>` starts it indented as a child), the way a list behaves
        in a notes app. That is checkmate's `list_continuation`; outside a todo
        line `<CR>` is just `<CR>`.
      - Checking every child checks the parent, and unchecking a child
        unchecks it again (`smart_toggle`, one level only). Parents show a
        `done/total` count at end of line.
      - `<leader>Ta` archives **every** checked item in the file into a
        `## Archive` heading at the bottom, not just the one under the cursor.
      - Nested items need a 2-space indent. Deeper indents still render, but
        the linter flags them and they do not count toward the parent.

      `setup()` is deliberately **not** deferred, which costs ~8ms of startup.
      Checkmate's keymaps are all `<Cmd>Checkmate ...<CR>` and `:Checkmate` is a
      *buffer-local* command created from its `FileType` autocmd. When `setup()`
      runs after the buffer is already open -- i.e. a deferred setup plus
      `nvim TODO.md` -- it takes the `H.setup_existing_markdown_buffers()` path,
      which starts highlighting and the keymaps but never creates the command,
      so every key fails with `E492: Not an editor command`. Still true in
      v0.12.1; worth an upstream issue.

- [ ] **todo-comments.nvim** -- solves a different problem and is worth having
      *alongside*, not instead: highlights `TODO:` / `FIXME:` / `HACK:` in source
      code and lists them with `:TodoTelescope`, which plugs straight into the
      telescope setup you already have. Good for the kernel tree.
- [ ] **nvim-orgmode** -- the heavy option. Real agenda views, scheduling,
      deadlines, recurring tasks, capture. Very actively maintained. The cost is
      `.org` files instead of markdown, so your TODO.md would have to move.
      Pick this only if you actually want an agenda, not just checkboxes.
- [ ] **dooing** -- a floating scratch todo window, standalone from your files.
      Nice for ephemeral lists; not a fit for something repo-tracked like this.

Not recommended for your case: **vimwiki** (large, opinionated, wants to own a
whole wiki directory) and **obsidian.nvim** (only worth it if you keep an
Obsidian vault -- note the maintained version is now the community fork
`obsidian-nvim/obsidian.nvim`, not `epwalsh/obsidian.nvim`).

### Notes on adding plugins under vim.pack

- No dependency resolution: list shared libraries *before* the plugins that
  `require()` them.
- No `build =`: add a case to the `PackChanged` autocmd at the top of `pack.lua`.
- No `event`/`cmd`/`ft`/`keys`: bind keymaps eagerly with a lazy `require()` inside
  the callback, and wrap `setup()` in `defer.later()`.
