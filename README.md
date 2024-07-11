# markdown-toggle.nvim

A simple and useful set of toggle commands for Markdown. Similar to [Obsidian](https://obsidian.md)

### Features
- Handles quotes, headings, lists (unordered and ordered), and checkboxes
![markdown_common](https://github.com/roodolv/markdown-toggle.nvim/assets/113752412/a6843366-ba67-4828-a6c3-780a2e0fba5c)

- Cycle through different levels of headings, types of lists, and states of checkboxes
![cyclic_toggling01](https://github.com/roodolv/markdown-toggle.nvim/assets/113752412/f52d5719-5a9a-4770-b149-808f673a1a3f)
![cyclic_toggling02](https://github.com/roodolv/markdown-toggle.nvim/assets/113752412/585fa715-2df8-40df-8f69-bca478340c30)

- Automatically continue quotes, lists, and checkboxes when starting a new line
- Use Vim's dot (`.`) command to repeat toggle actions (only in Normal mode)
- Change plugin settings **on-the-fly**
  - Unmarked Only: Toggle only unmarked lines initially
  - Blankhead Skip: Skip blank lines and headings in Visual mode (except for `quote()`)
  - Inner Indent: Insert an indent for new lines within quoted text
  - Autolist Same-state: Maintain checkbox state when continuing lists
![config_switch01](https://github.com/roodolv/markdown-toggle.nvim/assets/113752412/d34359b2-febe-4165-ba77-eeee79676a95)
![config_switch02](https://github.com/roodolv/markdown-toggle.nvim/assets/113752412/97f9667d-a2c4-4351-9a30-6a370827e48f)

## Installation
<details>
  <summary>lazy.nvim</summary>

```lua
{
  "roodolv/markdown-toggle.nvim",
  config = function()
    require("markdown-toggle").setup()
  end,
},
```
</details>

<details>
  <summary>packer.nvim</summary>

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
  <summary>vim-plug</summary>

```lua
Plug "roodolv/markdown-toggle.nvim"
```
</details>

### Other Plugin Managers
For specific installation instructions, please refer to the documentation of your preferred plugin manager.

## Configuration

### Minimal Setup
Include this single line in your `init.lua` or config:
```lua
require("markdown-toggle").setup()
```

### Default Config
The default settings are as follows:
```lua
require("markdown-toggle").setup({
  -- If true, the auto-setup for the default keymaps is enabled
  use_default_keymaps = false,
  -- The keymaps are valid only for these filetypes
  filetypes = { "markdown", "markdown.mdx" },

  -- Cycle the marks in user-defined table when toggling lists
  enable_list_cycle = false,
  -- The list marks table used in cycle-mode (list_table[1] is used as the default list-mark)
  list_table = { "-", "+", "*", "=" },

  -- Cycle the marks in user-defined table when toggling checkboxes
  enable_box_cycle = false,
  -- The checkbox marks table used in cycle-mode (box_table[1] is used as the default checked-state)
  box_table = { "x", "~", "!", ">" },

  -- The heading marks table used in `markdown-toggle.heading`
  heading_table = { "#", "##", "###", "####", "#####" },

  -- Skip blank lines and headings in Visual mode (except for quotes)
  enable_blankhead_skip = true,
  -- Insert an indented quote for new lines within quoted text
  enable_inner_indent = false,
  -- Toggle only unmarked lines first
  enable_unmarked_only = true,
  -- Automatically continue lists on new lines
  enable_autolist = true,
  -- Maintain checkbox state when continuing lists
  enable_auto_samestate = false,
  -- Dot-repeat for toggle functions in Normal mode
  enable_dot_repeat = true,
})
```

## Keymaps

### Auto-setup
For a quick start with default keymaps, add this to your setup:
```lua
require("markdown-toggle").setup({
  use_default_keymaps = true,
})
```

### Manual-setup Examples
First, set up the common autocmd structure:
```lua
vim.api.nvim_create_autocmd("FileType", {
  desc = "markdown-toggle.nvim keymaps",
  pattern = { "markdown", "markdown.mdx" },
  callback = function(args)
    local opts = { silent = true, noremap = true, buffer = args.buf }
    local toggle = require("markdown-toggle")

    -- Keymap configurations will be added here for each feature

  end,
})
```

#### Dot-repeat
If you set `enable_dot_repeat = true` (default):
```lua
opts.expr = true -- required for dot-repeat in Normal mode
vim.keymap.set("n", "<C-q>", toggle.quote_dot, opts)
vim.keymap.set("n", "<C-l>", toggle.list_dot, opts)
vim.keymap.set("n", "<C-n>", toggle.olist_dot, opts)
vim.keymap.set("n", "<Leader><C-x>", toggle.checkbox_dot, opts)
vim.keymap.set("n", "<C-h>", toggle.heading_dot, opts)

opts.expr = false -- required for Visual mode
vim.keymap.set("x", "<C-q>", toggle.quote, opts)
vim.keymap.set("x", "<C-l>", toggle.list, opts)
vim.keymap.set("x", "<C-n>", toggle.olist, opts)
vim.keymap.set("x", "<Leader><C-x>", toggle.checkbox, opts)
vim.keymap.set("x", "<C-h>", toggle.heading, opts)
```

If you set `enable_dot_repeat = false`:
```lua
vim.keymap.set({ "n", "x" }, "<C-q>", toggle.quote, opts)
vim.keymap.set({ "n", "x" }, "<C-l>", toggle.list, opts)
vim.keymap.set({ "n", "x" }, "<C-n>", toggle.olist, opts)
vim.keymap.set({ "n", "x" }, "<Leader><C-x>", toggle.checkbox, opts)
vim.keymap.set({ "n", "x" }, "<C-h>", toggle.heading, opts)
```

#### Autolist
If you set `enable_autolist = true` (default):
```lua
vim.keymap.set("n", "O", toggle.autolist_up, opts)
vim.keymap.set("n", "o", toggle.autolist_down, opts)
vim.keymap.set("i", "<CR>", toggle.autolist_cr, opts)
```

#### Config-switch
You can switch various options in the comfort of your active buffer, without the need to restart or reload Neovim.
```lua
vim.keymap.set("n", "<Leader>mU", toggle.switch_unmarked_only, opts)
vim.keymap.set("n", "<Leader>mB", toggle.switch_blankhead_skip, opts)
vim.keymap.set("n", "<Leader>mI", toggle.switch_inner_indent, opts)
vim.keymap.set("n", "<Leader>mS", toggle.switch_auto_samestate, opts)
vim.keymap.set("n", "<Leader>mL", toggle.switch_list_cycle, opts)
vim.keymap.set("n", "<Leader>mX", toggle.switch_box_cycle, opts)
```

## API
This plugin provides the following set of API functions:

| type | function | vim-mode |
| -- | -- | -- |
| Quotes         | `quote()`        | Normal, Visual |
|                | `quote_dot()`    | Normal         |
| Lists          | `list()`         | Normal, Visual |
|                | `list_dot()`     | Normal         |
| Ordered Lists  | `olist()`        | Normal, Visual |
|                | `olist_dot()`    | Normal         |
| Checkboxes     | `checkbox()`     | Normal, Visual |
|                | `checkbox_dot()` | Normal         |
| Headings       | `heading()`      | Normal, Visual |
|                | `heading_dot()`  | Normal         |
| Autolist       | `autolist_up()`<br>`autolist_down()` | Normal |
|                | `autolist_cr()`  | Insert         |
| Config-switch  | `switch_unmarked_only()`<br>`switch_blankhead_skip()`<br>`switch_inner_indent()`<br>`switch_auto_samestate()`<br>`switch_list_cycle()`<br>`switch_box_cycle()` | Normal |

## Related Plugins
- [markdowny.nvim](https://github.com/antonk52/markdowny.nvim)
  - If you want to easily apply or toggle **code, codeblock, link, bold, or italic** formatting on Markdown text, this may be ideal for you.
- [nvim-surround](https://github.com/kylechui/nvim-surround)
  - For more information and implementation details, check out this:
    - [Surrounds Showcase](https://github.com/kylechui/nvim-surround/discussions/53)
- [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim)

## References
- [mder.nvim](https://github.com/phanen/mder.nvim)
- [markdown-togglecheck](https://github.com/nfrid/markdown-togglecheck)

## Todo
- [ ] Implement plugin commands (e.g., `:MarkdownToggleQuote`) to call API functions
- [ ] Improve Visual-mode behavior of `heading()` for lines that start with `#`
- [ ] Expand the README with config examples inspired by popular Markdown editors
- [ ] Integrate `v:count` (`vim.v.count`) support to handle repeated actions
  - Example: `2<C-h>` should invoke the `heading()` function twice
