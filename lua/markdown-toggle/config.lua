local M = {}

-- Default keymaps
local default_keymaps = {
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
  },
  autolist = {
    ["O"] = "autolist_up",
    ["o"] = "autolist_down",
    ["<CR>"] = "autolist_cr",
  },
}

-- Export default keymaps for use in other modules
M.default_keymaps = default_keymaps

---@class MarkdownToggleConfig
---@field use_default_keymaps boolean
---@field filetypes string[]
---@field keymap table|nil
---@field list_table string[]
---@field cycle_list_table boolean
---@field box_table string[]
---@field cycle_box_table boolean
---@field list_before_box boolean
---@field obox_as_olist boolean
---@field heading_table string[]
---@field enable_blankline_skip boolean
---@field enable_heading_skip boolean
---@field enable_unmarked_only boolean
---@field enable_autolist boolean
---@field enable_auto_samestate boolean
---@field enable_olist_recalc boolean
---@field enable_dot_repeat boolean

---@type MarkdownToggleConfig
local config = {
  -- If true, the auto-setup for the default keymaps is enabled
  use_default_keymaps = false,
  -- The keymaps are valid only for these filetypes
  filetypes = { "markdown", "markdown.mdx" },
  -- User-defined keymaps (nil by default)
  keymap = nil,

  -- The list marks table used in cycle-mode (list_table[1] is used as the default list-mark)
  list_table = { "-", "+", "*", "=" },
  -- Cycle the marks in user-defined table when toggling lists
  cycle_list_table = false,

  -- The checkbox marks table used in cycle-mode (box_table[1] is used as the default checked-state)
  box_table = { "x", "~", "!", ">" },
  -- Cycle the marks in user-defined table when toggling checkboxes
  cycle_box_table = false,

  -- A bullet/ordered list is toggled before turning into a checkbox (similar to how it works in Obsidian).
  list_before_box = false,
  -- Whether to treat an ordered checkbox as an ordered list when you call `olist()`
  obox_as_olist = true,

  -- The heading marks table used in `markdown-toggle.heading`
  heading_table = { "#", "##", "###", "####", "#####" },

  -- Skip blank lines in Visual mode (except for `quote()`)
  enable_blankline_skip = true,
  -- Skip headings in Visual mode (except for `quote()`)
  enable_heading_skip = true,
  -- Toggle only unmarked lines first
  enable_unmarked_only = true,
  -- Automatically continue lists on new lines
  enable_autolist = true,
  -- Maintain checkbox state when continuing lists
  enable_auto_samestate = false,
  -- Automatically recalculate ordered list numbers
  enable_olist_recalc = true,
  -- Dot-repeat for toggle functions in Normal mode
  enable_dot_repeat = true,
}

---@param user_config MarkdownToggleConfig|nil
M.set = function(user_config)
  if user_config == nil then return config end
  if type(user_config) ~= "table" then error("Configuration error") end
  config = vim.tbl_deep_extend("force", config, user_config or {})
  return config
end

return M
