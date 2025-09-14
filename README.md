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
  - Unmarked Only: Toggle only unmarked lines first
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

<details>
  <summary>Default Config</summary>

```lua
require("markdown-toggle").setup({
  -- If true, the auto-setup for the default keymaps is enabled
  use_default_keymaps = false,
  -- The keymaps are valid only for these filetypes
  filetypes = { "markdown", "markdown.mdx" },

  -- The list marks table used in cycle-mode (list_table[1] is used as the default list-mark)
  list_table = { "-", "+", "*", "=" },
  -- Cycle the marks in user-defined table when toggling lists
  cycle_list_table = false,

  -- The checkbox marks table used in cycle-mode (box_table[1] is used as the default checked-state)
  box_table = { "x", "~", "!", ">" },
  -- Cycle the marks in user-defined table when toggling checkboxes
  cycle_box_table = false,
  -- A bullet list is toggled before turning into a checkbox (similar to how it works in Obsidian).
  list_before_box = false,

  -- The heading marks table used in `markdown-toggle.heading`
  heading_table = { "#", "##", "###", "####", "#####" },

  -- Skip blank lines and headings in Visual mode (except for `quote()`)
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
</details>

### Config for Cycling
<details>
  <summary>List-Cycling</summary>

- `cycle_list_table = false` (default):
```
foo
↓ call `list()`
- foo
↓
foo
↓
```

- `cycle_list_table = true` and `list_table = { "-", "+" }`:
```
foo
↓ call `list()`
- foo
↓
+ foo
↓
foo
↓
```
</details>

<details>
  <summary>Checkbox-Cycling</summary>

- `cycle_box_table = false` (default):
```
foo
↓ call `checkbox()`
- foo
↓
- [ ] foo
↓
- [x] foo
↓
- foo
↓
```

- `cycle_box_table = true` and `box_table = { "x", "~" }`:
```
foo
↓ call `checkbox()`
- foo
↓
- [ ] foo
↓
- [x] foo
↓
- [~] foo
↓
- foo
↓
```
</details>

<details>
  <summary>List-Before-Checkbox</summary>

- `list_before_box = false` (default):
```
foo
↓ call `checkbox()`
- [ ] foo
↓
- [x] foo
↓
- [ ] foo
↓
```

- `list_before_box = true`:
```
foo
↓ call `checkbox()`
- foo
↓
- [ ] foo
↓
- [x] foo
↓
- foo
↓
```
</details>

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

#### Toggle Functions
Common keymap examples for toggle functions.
<details>
  <summary>Examples</summary>

If `enable_dot_repeat = true` (default):
```lua
opts.expr = true -- required for dot-repeat in Normal mode
vim.keymap.set("n", "<C-q>", toggle.quote_dot, opts)
vim.keymap.set("n", "<C-l>", toggle.list_dot, opts)
vim.keymap.set("n", "<Leader><C-l>", toggle.list_cycle_dot, opts)
vim.keymap.set("n", "<C-n>", toggle.olist_dot, opts)
vim.keymap.set("n", "<M-x>", toggle.checkbox_dot, opts)
vim.keymap.set("n", "<Leader><M-x>", toggle.checkbox_cycle_dot, opts)
vim.keymap.set("n", "<C-h>", toggle.heading_dot, opts)

opts.expr = false -- required for Visual mode
vim.keymap.set("x", "<C-q>", toggle.quote, opts)
vim.keymap.set("x", "<C-l>", toggle.list, opts)
vim.keymap.set("x", "<Leader><C-l>", toggle.list_cycle, opts)
vim.keymap.set("x", "<C-n>", toggle.olist, opts)
vim.keymap.set("x", "<M-x>", toggle.checkbox, opts)
vim.keymap.set("x", "<Leader><M-x>", toggle.checkbox_cycle, opts)
vim.keymap.set("x", "<C-h>", toggle.heading, opts)
```

If `enable_dot_repeat = false`:
```lua
vim.keymap.set({ "n", "x" }, "<C-q>", toggle.quote, opts)
vim.keymap.set({ "n", "x" }, "<C-l>", toggle.list, opts)
vim.keymap.set({ "n", "x" }, "<Leader><C-l>", toggle.list_cycle, opts)
vim.keymap.set({ "n", "x" }, "<C-n>", toggle.olist, opts)
vim.keymap.set({ "n", "x" }, "<M-x>", toggle.checkbox, opts)
vim.keymap.set({ "n", "x" }, "<Leader><M-x>", toggle.checkbox_cycle, opts)
vim.keymap.set({ "n", "x" }, "<C-h>", toggle.heading, opts)
```
</details>

#### Autolist
<details>
  <summary>Examples</summary>

If `enable_autolist = true` (default):
```lua
vim.keymap.set("n", "O", toggle.autolist_up, opts)
vim.keymap.set("n", "o", toggle.autolist_down, opts)
vim.keymap.set("i", "<CR>", toggle.autolist_cr, opts)
```
</details>

#### Config-switch
You can switch various options in the comfort of your active buffer, without the need to restart or reload Neovim.
<details>
  <summary>Examples</summary>

```lua
vim.keymap.set("n", "<Leader>mU", toggle.switch_unmarked_only, opts)
vim.keymap.set("n", "<Leader>mB", toggle.switch_blankhead_skip, opts)
vim.keymap.set("n", "<Leader>mI", toggle.switch_inner_indent, opts)
vim.keymap.set("n", "<Leader>mS", toggle.switch_auto_samestate, opts)
vim.keymap.set("n", "<Leader>mL", toggle.switch_cycle_list_table, opts)
vim.keymap.set("n", "<Leader>mX", toggle.switch_cycle_box_table, opts)
vim.keymap.set("n", "<Leader>mC", toggle.switch_list_before_box, opts)
```
</details>

## API
### API: Functions
This plugin provides the following set of API functions:

| type | function | vim-mode |
| -- | -- | -- |
| Quotes                | `quote()`             | Normal, Visual |
| Lists                 | `list()`              | Normal, Visual |
| Lists(cycle-only)     | `list_cycle()`        | Normal, Visual |
| Ordered Lists         | `olist()`             | Normal, Visual |
| Checkboxes            | `checkbox()`          | Normal, Visual |
| Checkboxes(cycle-only)| `checkbox_cycle()`    | Normal, Visual |
| Headings              | `heading()`           | Normal, Visual |
| Dot-repeatable        | `XXX_dot()`           | Normal         |
| Autolist              | `autolist_up()`<br>`autolist_down()` | Normal |
|                       | `autolist_cr()`       | Insert         |
| Config-switch         | `switch_unmarked_only()`<br>`switch_blankhead_skip()`<br>`switch_inner_indent()`<br>`switch_auto_samestate()`<br>`switch_cycle_list_table()`<br>`switch_cycle_box_table()`<br>`switch_list_before_box` | Normal |

### API: Dot-repeatable
Dot-repeatable functions have names like `XXX_dot()`.

For example:
- Dot-repeatable function for block-quote is `quote_dot()`
- Dot-repeatable function for checkbox is `checkbox_dot()`

### API: Cycle-only
<details>
  <summary>Cycle-only Functions</summary>

The **cycle-only** functions are like:
- `list_cycle()`, `list_cycle_dot()`
- `checkbox_cycle()`, `checkbox_cycle_dot()`

These funcs **only perform mark-cycling** every time you call them, regardless of whether `cycle_XXX_table` is `true` or not.

So if you'd like to have TWO separate keymaps for both toggling and cycling functions, you no longer need to set or switch `cycle_XXX_table`:
```lua
-- list() performs toggling/cycling (can be switched with option)
vim.keymap.set({ "n", "x" }, "<C-l>", toggle.list, opts)
-- list_cycle() performs cycling only
vim.keymap.set({ "n", "x" }, "<Leader><C-l>", toggle.list_cycle, opts)
```
</details>

## Etc
### For Obsidian Users
If you'd like this plugin to behave like Obsidian, take a look at this:

<details>
  <summary>How to use like Obsidian</summary>

| Obsidian commands | API | config |
| :-- | :-- | :-- |
| Toggle blockquote     | `quote()`, `quote_dot()`      | any |
| Toggle bullet list    | `list()`, `list_dot()`        | any |
| Toggle numbered list  | `olist()`, `olist_dot()`      | any |
| Toggle checkbox status| `checkbox()`, `checkbox_dot()`| `list_before_box` is `false` |
| Cycle bullet/checkbox | `checkbox()`, `checkbox_dot()`| `list_before_box` is `true`  |

**NOTE**: `list_before_box` can be toggled with `switch_list_before_box()`.
</details>

### Autolist Configs
If you'd like a good experience, you should set `autoindent = false` or `noautoindent` for Markdown buffers.

<details>
  <summary>Here is an example:</summary>

  ```lua
  vim.o.autoindent = true
  ```

  or

  ```lua
  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "markdown",
    command = "setl expandtab tabstop=4 shiftwidth=4 softtabstop=4 noautoindent",
  })
  ```

**NOTE**: You can freely set the values for `tabstop`, `shiftwidth` and `softtabstop`.
</details>

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
**NOTE**: This is just a provisional plan.

- [ ] Rename and consolidate options
    - Use more generic config names
- [ ] Recalculate ordered lists automatically
- [ ] Implement various **autolist** behaviors triggered by consecutive `<CR>` presses
- [ ] Enable `heading()` to directly replace list, olist, or checkbox items
- [ ] Add an option to toggle `1.` inside headings like `### hoge` to `### 1. hoge`
- [ ] Indent text in block quotes with `Tab`, changing `> hoge` to `> ____hoge`
- [ ] Add plugin commands (e.g., `:MarkdownToggleQuote`) to call API functions
- [ ] Integrate `v:count` (`vim.v.count`) support to handle repeated actions
  - Example: `2<C-h>` should call the `heading()` function twice
