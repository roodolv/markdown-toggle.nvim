local M = {}

-- Import modules
local config = require("markdown-toggle.config")
local keymap = require("markdown-toggle.keymap")
local patterns = require("markdown-toggle.shared.patterns")
local util = require("markdown-toggle.shared.util")
local list = require("markdown-toggle.marks.list")
local checkbox = require("markdown-toggle.marks.checkbox")
local heading = require("markdown-toggle.marks.heading")
local convert = require("markdown-toggle.features.convert")
local toggle = require("markdown-toggle.features.toggle")
local autolist = require("markdown-toggle.features.autolist")

--[========================================================[
                        Configuration
--]========================================================]

---@type MarkdownToggleConfig
local current_config = config.set()

---Update all module configurations
local update_all_configs = function()
  -- Generate patterns from config tables
  local list_marks = patterns.generate_list_marks(current_config.list_table)
  local box_states = patterns.generate_box_states(current_config.box_table)
  local list_mark = current_config.list_table[1]
  local checked_state = current_config.box_table[1]
  local heading_mark = current_config.heading_table[1]

  -- Update each module's configuration
  heading.set_config(heading_mark, current_config.heading_table)
  list.set_config(list_marks, list_mark, current_config.list_table)
  checkbox.set_config(list_marks, box_states, list_mark, checked_state, current_config.box_table)
  convert.set_config(list_marks, box_states, list_mark)
  toggle.set_config(current_config)
  autolist.set_config(current_config)
end

---Setup function
---@param user_config MarkdownToggleConfig
M.setup = function(user_config)
  current_config = config.set(user_config)
  update_all_configs()

  -- Always setup common keymaps (Vim commands)
  keymap.setup_common_keymaps(current_config)

  -- Setup keymaps based on configuration
  if current_config.use_default_keymaps then
    -- Use default keymaps
    keymap.setup_all_keymaps(current_config)
  elseif current_config.keymaps then
    -- Use user-defined keymaps (toggle, switch, or autolist)
    keymap.setup_all_keymaps(current_config)
  end
end

---Switch a boolean option
---@param option_name string
local switch_option = function(option_name)
  local user_config = { [option_name] = not current_config[option_name] }
  M.setup(user_config)

  local status = current_config[option_name] and "enabled" or "disabled"
  local msg_type = current_config[option_name] and "None" or "WarningMsg"
  vim.api.nvim_echo({ { string.format("MarkdownToggle: `%s` %s", option_name, status), msg_type } }, true, {})
end

--[========================================================[
                            API
--]========================================================]

-- Setup toggle functions such like: `M.quote()`, `M.quote_dot()`
local setup_toggle_functions = function(toggle_mode)
  -- Regular function with v:count support
  M[toggle_mode] = function() toggle.toggle_with_vcount(toggle_mode) end

  -- Dot-repeat function (operatorfunc compatible)
  M[toggle_mode .. "_dot"] = function()
    vim.go.operatorfunc = string.format("v:lua.require'markdown-toggle'.%s", toggle_mode)
    return "g@l"
  end
end

-- Toggle Functions
local toggle_modes = { "quote", "list", "list_cycle", "olist", "checkbox", "checkbox_cycle", "heading", "heading_toggle" }
for _, toggle_mode in ipairs(toggle_modes) do
  setup_toggle_functions(toggle_mode)
end

-- Autolist
M.autolist_up = function() autolist.autolist("O") end
M.autolist_down = function() autolist.autolist("o") end
M.autolist_cr = function() autolist.autolist(util.get_eol()) end

-- Config-switch
M.switch_blankline_skip = function() switch_option("enable_blankline_skip") end
M.switch_heading_skip = function() switch_option("enable_heading_skip") end
M.switch_unmarked_only = function() switch_option("enable_unmarked_only") end
M.switch_auto_samestate = function() switch_option("enable_auto_samestate") end

M.switch_cycle_list_table = function() switch_option("cycle_list_table") end
M.switch_cycle_box_table = function() switch_option("cycle_box_table") end
M.switch_list_before_box = function() switch_option("list_before_box") end
M.switch_obox_as_olist = function() switch_option("obox_as_olist") end

return M
