# markdown-toggle.nvim

Smart and customizable markdown toggling for Neovim. Provides intuitive commands for quotes, headings, lists, and checkboxes.

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/roodolv/markdown-toggle.nvim?style=flat-square&logo=github&color=blue&cacheSeconds=86400)](https://github.com/roodolv/markdown-toggle.nvim/releases)
[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg)](https://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim-0.10+-green.svg)](https://neovim.io)
[![License](https://img.shields.io/github/license/roodolv/markdown-toggle.nvim)](LICENSE)

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
  - [Default Settings](#default-settings)
  - [Keymaps Setup](#keymaps-setup)
  - [Cycling Behavior](#cycling-behavior)
- [API Reference](#api-reference)
- [Tips](#tips)
- [Related Plugins](#related-plugins)
- [Roadmap](#roadmap)

## Features

- 🧠 **Smart Toggling** - Cycle through quotes, headings, lists, and checkboxes
- 🎨 **Highly Customizable** - Configure marks, keymaps, and behaviors
- 🚀 **On-the-fly Configuration** - Toggle settings without restarting
- ♻️ **Dot Repeat** - Full support for Vim's `.` command
- 🔢 **Count Prefix** - Use `3<C-h>` to create `### heading`
- 📝 **Auto-list** - Automatic list continuation
- 🧮 **Auto-recalculation** - Ordered lists renumber automatically
- 🪨 **Obsidian-friendly** - Works great for Obsidian users

<details>
<summary>📸 See it in action</summary>

![markdown_common](https://github.com/roodolv/markdown-toggle.nvim/assets/113752412/a6843366-ba67-4828-a6c3-780a2e0fba5c)
![cyclic_toggling01](https://github.com/roodolv/markdown-toggle.nvim/assets/113752412/f52d5719-5a9a-4770-b149-808f673a1a3f)
![cyclic_toggling02](https://github.com/roodolv/markdown-toggle.nvim/assets/113752412/585fa715-2df8-40df-8f69-bca478340c30)

</details>

## Installation

<details open>
<summary><b>lazy.nvim</b></summary>

```lua
{
  "roodolv/markdown-toggle.nvim",
  config = function()
    require("markdown-toggle").setup()
  end,
}
```
</details>

<details>
<summary><b>packer.nvim</b></summary>

```lua
use {
  "roodolv/markdown-toggle.nvim",
  config = function()
    require("markdown-toggle").setup()
  end,
}
```
</details>

<details>
<summary><b>vim-plug</b></summary>

```vim
Plug "roodolv/markdown-toggle.nvim"
```
</details>

## Quick Start

### Minimal Setup
```lua
require("markdown-toggle").setup()
```

### With Default Keymaps
```lua
require("markdown-toggle").setup({
  use_default_keymaps = true,
})
```

### Custom Keymaps (Recommended)
```lua
require("markdown-toggle").setup({
  keymaps = {
    toggle = {
      ["<C-q>"] = "quote",
      ["<C-l>"] = "list",
      ["<Leader><C-l>"] = "list_cycle",
      ["<C-n>"] = "olist",
      ["<M-x>"] = "checkbox",
      ["<Leader><M-x>"] = "checkbox_cycle",
      ["<C-h>"] = "heading",
      ["<Leader><C-h>"] = "heading_toggle",
    },
  },
})
```

## Configuration

### Default Settings

<details>
<summary>View all default settings</summary>

```lua
{
  use_default_keymaps = false,
  filetypes = { "markdown", "markdown.mdx" },
  keymaps = nil,

  list_table = { "-", "+", "*", "=" },
  cycle_list_table = false,

  box_table = { "x", "~", "!", ">" },
  cycle_box_table = false,

  list_before_box = false,
  obox_as_olist = true,

  heading_table = { "#", "##", "###", "####", "#####" },

  enable_blankline_skip = true,
  enable_heading_skip = true,
  enable_unmarked_only = true,
  enable_autolist = true,
  enable_auto_samestate = false,
  enable_olist_recalc = true,
  enable_dot_repeat = true,
}
```
</details>

### Default Keymaps

<details>
<summary>View all default keymaps</summary>

```lua
keymaps = {
  toggle = {
    ["<C-q>"] = "quote",
    ["<C-l>"] = "list",
    ["<Leader><C-l>"] = "list_cycle",
    ["<C-n>"] = "olist",
    ["<M-x>"] = "checkbox",
    ["<Leader><M-x>"] = "checkbox_cycle",
    ["<C-h>"] = "heading",
    ["<Leader><C-h>"] = "heading_toggle",
  },
  switch = {
    ["<Leader>mU"] = "switch_unmarked_only",
    ["<Leader>mB"] = "switch_blankline_skip",
    ["<Leader>mH"] = "switch_heading_skip",
    ["<Leader>mS"] = "switch_auto_samestate",
    ["<Leader>mL"] = "switch_cycle_list_table",
    ["<Leader>mX"] = "switch_cycle_box_table",
    ["<Leader>mC"] = "switch_list_before_box",
    ["<Leader>mO"] = "switch_obox_as_olist",
  },
  autolist = {
    ["O"] = "autolist_up",
    ["o"] = "autolist_down",
    ["<CR>"] = "autolist_cr",
  },
},
```
</details>

### Keymaps Setup

The keymaps table structure:
```lua
keymaps = {
  toggle = { ["<key>"] = "function_name" },
  switch = { ["<key>"] = "function_name" },
  autolist = { ["<key>"] = "function_name" },
}
```

<details>
<summary>Available functions</summary>

**Toggle functions:**
- `quote`
- `list`, `list_cycle`, `olist`
- `checkbox`, `checkbox_cycle`
- `heading`, `heading_toggle`

> **Note**: `XXX_dot` functions are automatically configured if `enable_dot_repeat = true`.

**Switch functions:**
- `switch_blankline_skip`, `switch_heading_skip`
- `switch_unmarked_only`
- `switch_auto_samestate`
- `switch_cycle_list_table`, `switch_cycle_box_table`
- `switch_list_before_box`, `switch_obox_as_olist`

**Autolist functions:**
- `autolist_up`, `autolist_down`, `autolist_cr`

</details>

### Cycling Behavior

#### List Cycling

**Default** (`cycle_list_table = false`):

`foo` → `- foo` → `foo`

**Enabled** (`cycle_list_table = true` with `list_table = { "-", "+", "*" }`):

`foo` → `- foo` → `+ foo` → `* foo` → `foo`

<details>
<summary>Vertical view</summary>

```
foo
↓
- foo
↓
+ foo
↓
* foo
↓
foo
```
</details>

#### Checkbox Cycling

**Default** (`cycle_box_table = false`):

`foo` → `- [ ] foo` → `- [x] foo` → `- [ ] foo`

**Enabled** (`cycle_box_table = true` with `box_table = { "x", "~" }`):

`foo` → `- [ ] foo` → `- [x] foo` → `- [~] foo` → `- [ ] foo`

<details>
<summary>Vertical view</summary>

```
foo
↓
- [ ] foo
↓
- [x] foo
↓
- [~] foo
↓
- [ ] foo
```
</details>

## API Reference

| API Function | Vim Mode | Description |
|----------|----------|-------------|
| `quote()` | Normal, Visual | Toggle blockquote |
| `list()` | Normal, Visual | Toggle bullet list |
| `list_cycle()` | Normal, Visual | Cycle bullet list marks |
| `olist()` | Normal, Visual | Toggle ordered list |
| `checkbox()` | Normal, Visual | Toggle checkbox |
| `checkbox_cycle()` | Normal, Visual | Cycle checkbox states |
| `heading()` | Normal, Visual | Cycle heading levels |
| `heading_toggle()` | Normal, Visual | Toggle heading on/off |
| `XXX_dot()` | Normal | Dot-repeatable version |
| `autolist_up/down()` | Normal | Auto-list (`O`/`o`) |
| `autolist_cr()` | Insert | Auto-list (`<CR>`) |

### Config-switch functions

Config-switch functions have corresponding commands like `:MarkdownToggleSwitchXXX`.

<details>
<summary>Config-switch functions</summary>

| API Function | Commands | Description |
|----------|----------|-------------|
| `switch_unmarked_only()` | `:MarkdownToggleSwitchUnmarked` | Toggle unmarked-line-only mode |
| `switch_blankline_skip()` | `:MarkdownToggleSwitchBlankline` | Toggle blankline-skip mode |
| `switch_heading_skip()` | `:MarkdownToggleSwitchHeading` | Toggle heading-skip mode |
| `switch_auto_samestate()` | `:MarkdownToggleSwitchSamestate` | Toggle same-state mode for autolist |
| `switch_cycle_list_table()` | `:MarkdownToggleSwitchCycleList` | Toggle list cycling mode |
| `switch_cycle_box_table()` | `:MarkdownToggleSwitchCycleBox` | Toggle checkbox cycling mode |
| `switch_list_before_box()` | `:MarkdownToggleSwitchListBeforeBox` | Toggle `list_before_box` |
| `switch_obox_as_olist()` | `:MarkdownToggleSwitchOboxAsOlist` | Toggle `obox_as_olist` |

> **Tip**: Try typing `:mkdtlist`, `:mkdtbox`, or `:mdtlist` for faster command completion.

> **Note**: See [For Obsidian Users](#for-obsidian-users) for `list_before_box`.

> **Note**: See [Ordered Checkbox Configuration](#ordered-checkbox-configuration) for `obox_as_olist`.

</details>

### Dot-repeatable Functions

Dot-repeatable functions have names like `XXX_dot()`. For example:
- `quote_dot()` for blockquote
- `checkbox_dot()` for checkbox

These functions support Vim's `.` (dot) command for repeating actions.

### Cycle-only Functions

The cycle-only functions (`list_cycle()`, `checkbox_cycle()`) **only perform mark-cycling** every time you call them, regardless of the `cycle_XXX_table` setting.

This allows you to have separate keymaps for toggling and cycling:
```lua
-- list() performs toggling/cycling (can be switched with option)
vim.keymap.set({ "n", "x" }, "<C-l>", toggle.list, opts)
-- list_cycle() performs cycling only
vim.keymap.set({ "n", "x" }, "<Leader><C-l>", toggle.list_cycle, opts)
```

## Tips

### Autolist Configuration

> **Note:** For best experience, set `autoindent = true` for Markdown buffers.

<details>
<summary>Example</summary>

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    vim.opt_local.autoindent = true
  end,
})
```
</details>

### For Obsidian Users

If you'd like this plugin to behave like Obsidian, use the following configuration:

| Obsidian Command | API Function | Config |
|:-----------------|:-------------|:-------|
| Toggle blockquote | `quote()`, `quote_dot()` | any |
| Toggle bullet list | `list()`, `list_dot()` | any |
| Toggle numbered list | `olist()`, `olist_dot()` | any |
| Toggle checkbox status | `checkbox()`, `checkbox_dot()` | `list_before_box = false` |
| Cycle bullet/checkbox | `checkbox()`, `checkbox_dot()` | `list_before_box = true` |

> **Note:** `list_before_box` can be toggled with `switch_list_before_box()`.

<details>
<summary>Obsidian-like setup example</summary>

```lua
require("markdown-toggle").setup({
  list_before_box = true,  -- Cycle between list and checkbox
  keymaps = {
    toggle = {
      ["<C-q>"] = "quote",
      ["<C-l>"] = "list",
      ["<C-n>"] = "olist",
      ["<M-x>"] = "checkbox",  -- Cycles: foo → - foo → - [ ] foo → - [x] foo
    },
    autolist = {
      -- ["O"] = "autolist_up", -- Obsidian does not have `autolist_up`
      -- ["o"] = "autolist_down", -- Obsidian does not have `autolist_down`
      ["<CR>"] = "autolist_cr",
    },
  },
})
```
</details>

### Ordered Checkbox Configuration

You can control how ordered checkboxes are treated with the `obox_as_olist` config.

**When `obox_as_olist = true` (default):**
```md
1. [ ] foo
↓ `olist()`
foo
```

**When `obox_as_olist = false`:**
```md
1. [ ] foo
↓ `olist()`
1. foo
```

## Related Plugins

- [markdowny.nvim](https://github.com/antonk52/markdowny.nvim) - Code, link, bold, italic formatting
- [nvim-surround](https://github.com/kylechui/nvim-surround) - Surround text objects
  - [Surrounds Showcase](https://github.com/kylechui/nvim-surround/discussions/53)
- [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) - Obsidian integration
- [mder.nvim](https://github.com/phanen/mder.nvim) - Markdown editing utilities
- [markdown-togglecheck](https://github.com/nfrid/markdown-togglecheck) - Checkbox toggling

## Roadmap

- [x] Smart toggling for quotes, lists, headings, checkboxes
- [x] Cyclic toggling support
- [x] On-the-fly configuration
- [x] Dot-repeat support
- [x] Auto-list continuation
- [x] Ordered list auto-recalculation
- [x] Plugin commands (`:MarkdownToggleSwitchXXX`)
- [x] `v:count` (`vim.v.count`) support
- [x] Smart continuation for empty list items (contributed by [@Dieal](https://github.com/Dieal) in [#37](https://github.com/roodolv/markdown-toggle.nvim/pull/37))
- [x] Comprehensive codebase refactoring
- [ ] Add `mini.test` test framework
- [ ] Improved autolist behavior
- [ ] Grouped configuration structure
- [ ] Tab indentation for quoted text
- [ ] Additional functions: `link()`, `code()`, `codeblock()`, `bold()`, `italic()`, and `strikethrough()`
- [ ] Rename `heading()` → `heading_cycle()`

## License

MIT License - see [LICENSE](LICENSE) for details
