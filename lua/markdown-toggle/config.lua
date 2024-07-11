local M = {}

---@class MarkdownToggleConfig
---@field use_default_keymaps boolean
---@field filetypes string[]
---@field enable_list_cycle boolean
---@field list_table string[]
---@field enable_box_cycle boolean
---@field box_table string[]
---@field heading_table string[]
---@field enable_blankhead_skip boolean
---@field enable_inner_indent boolean
---@field enable_unmarked_only boolean
---@field enable_autolist boolean
---@field enable_auto_samestate boolean
---@field enable_dot_repeat boolean

---@type MarkdownToggleConfig
local config = {
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

  -- Skip blank lines and headings in Visual mode (except for `quote()`)
  enable_blankhead_skip = true,
  -- Insert an indent for new lines within quoted text
  enable_inner_indent = false,
  -- Toggle only unmarked lines initially
  enable_unmarked_only = true,
  -- Automatically continue lists on new lines
  enable_autolist = true,
  -- Maintain checkbox state when continuing lists
  enable_auto_samestate = false,
  -- Dot-repeat for toggle functions in Normal mode
  enable_dot_repeat = true,
}

---@param user_config MarkdownToggleConfig
M.set = function(user_config)
  if user_config == nil then return config end
  if type(user_config) ~= "table" then error("Configuration error") end
  config = vim.tbl_deep_extend("force", config, user_config or {})
  return config
end

return M
