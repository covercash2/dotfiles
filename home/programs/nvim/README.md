# Neovim Configuration

Uses Neovim's native `vim.pack` plugin manager (0.12+) and `vim.lsp` API.
No external plugin manager (lazy.nvim, packer, etc.) required.

## Bootstrapping a new machine

1. **Neovim 0.12+** is required. Verify with `nvim --version`.
2. Use Nix home-manager to deploy this directory to `~/.config/nvim/`.
   The Nix module at `home/programs/neovim.nix` handles this.
3. **Launch `nvim`**. On first start, `vim.pack.add()` clones all plugins
   (takes ~1 minute). Build hooks run automatically via `PackChanged`.
4. **Check health** with `:checkhealth vim.pack` to verify everything installed.

### Nix flake gotchas

- **All config files must be git-tracked.** Nix flakes only see committed
  or staged files. Untracked files won't be deployed.
- **`recursive = true` is required** in the `xdg.configFile."nvim"` declaration
  (see `home/programs/neovim.nix`). This makes `~/.config/nvim/` a real writable
  directory so `vim.pack` can write its lockfile. Without it, the directory is a
  read-only Nix store symlink and `vim.pack.add()` fails with `EACCES`.
- If switching from a non-recursive to recursive config, you may need to
  **manually remove the old symlink** (`rm ~/.config/nvim`) before rebuilding.

### Build dependencies

Some plugins compile native code on install/update:

| Plugin | Requires |
|---|---|
| blink.cmp | `cargo` (Rust toolchain) |
| avante.nvim | `make`, C compiler |
| markdown-preview.nvim | `yarn` |
| vscode-js-debug | `npm`, `npx` |

### Lockfile

`vim.pack` writes `nvim-pack-lock.json` to `$XDG_CONFIG_HOME/nvim/`
(typically `~/.config/nvim/`). Commit it for reproducible installs.

To sync another machine to the lockfile:

```vim
:lua vim.pack.update(nil, { target = 'lockfile' })
```

## Directory structure

```
nvim/
├── init.lua                 Entry point: options, keymaps, vim.pack.add(), build hooks
│
├── plugin/                  Auto-sourced after init.lua — plugin .setup() calls
│   ├── ai.lua               copilot, avante, mcphub, img-clip, render-markdown
│   ├── completion.lua        blink.cmp
│   ├── editor.lua            mini.*, autoclose, flash, spider, comment, scrollview
│   ├── git.lua               gitsigns, git-blame
│   ├── lang.lua              rustaceanvim, clangd, cmake, guard, dap, jq
│   ├── lsp.lua               capabilities, LspAttach autocmd, vim.lsp.enable()
│   ├── navigation.lua        telescope + extensions, oil
│   ├── testing.lua           neotest, coverage
│   ├── treesitter.lua        treesitter, autotag, context, rainbow-delimiters
│   └── ui.lua                themes, lualine, neo-tree, winbar, which-key, obsidian
│
├── lsp/                     Per-server LSP configs (return a table, filename = server name)
│   ├── helm_ls.lua
│   └── typos_lsp.lua
│
├── after/ftplugin/          Filetype-specific overrides (sourced when filetype is set)
│   └── json.lua
│
└── lua/                     Lua modules (loaded via require(), not auto-sourced)
    ├── config/
    │   ├── options.lua       Leader key, indent, clipboard, updatetime
    │   └── keymaps.lua       Global keymaps (movement, windows, diagnostics)
    ├── date.lua              :InsertDate command
    ├── edit_section.lua      :EditSection floating buffer for embedded code
    └── tools.lua             Utility functions (dump_table)
```

## Load order

```
init.lua
  ├─ require("config.options")     vim options, leader key
  ├─ require("config.keymaps")     global keymaps
  ├─ vim.pack.add({ ... })         clone/load all plugins into pack/core/opt/
  └─ PackChanged autocmd           build hooks (cargo, make, yarn, etc.)

plugin/*.lua                       alphabetical order, all plugins on rtp
  ai → completion → editor → git → lang → lsp → navigation → testing → treesitter → ui

lsp/*.lua                          read by vim.lsp when a server is enabled

after/ftplugin/*.lua               sourced when a matching filetype buffer opens
```

Key detail: `plugin/` files run **after** `init.lua` completes and all plugins
are on the runtimepath, so every `require()` call works.

## Common operations

| Task | Command |
|---|---|
| Update all plugins | `:lua vim.pack.update()` |
| Update specific plugin | `:lua vim.pack.update({ 'blink.cmp' })` |
| Check plugin status | `:lua vim.print(vim.pack.get())` |
| Remove a plugin | `:lua vim.pack.del({ 'plugin-name' })` |
| Check health | `:checkhealth vim.pack` |

## Adding a new plugin

1. Add the source URL to `vim.pack.add()` in `init.lua`.
2. If it needs a build step, add it to the `PackChanged` autocmd in `init.lua`.
3. Add `.setup()` call to the appropriate `plugin/*.lua` file.
4. If it's an LSP server, add a `lsp/server_name.lua` returning config
   and add the name to `vim.lsp.enable()` in `plugin/lsp.lua`.

## Adding per-server LSP config

Create `lsp/<server_name>.lua` returning a config table:

```lua
-- lsp/lua_ls.lua
return {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
        },
    },
}
```

The filename determines the server name. No `vim.lsp.config()` call needed.
