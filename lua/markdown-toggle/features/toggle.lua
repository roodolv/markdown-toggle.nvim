local M = {}

-- Import dependencies
local quote = require("markdown-toggle.marks.quote")
local heading = require("markdown-toggle.marks.heading")
local list = require("markdown-toggle.marks.list")
local olist = require("markdown-toggle.marks.olist")
local checkbox = require("markdown-toggle.marks.checkbox")
local convert = require("markdown-toggle.features.convert")
local olist_recalc = require("markdown-toggle.features.olist_recalc")
local line_state = require("markdown-toggle.shared.line_state")
local util = require("markdown-toggle.shared.util")

-- Module-level config cache
local current_config = {}

---Set toggle configuration
---@param config MarkdownToggleConfig
M.set_config = function(config) current_config = config end

--[========================================================[
                        Toggle Marks
--]========================================================]

---Toggle quote mark
---@param line string
---@return string
local get_toggled_quote = function(line)
  if quote.has_quote(line) then
    return quote.remove_quote(line)
  else
    return quote.create_quote(line)
  end
end

---Cycle heading mark
---@param line string
---@return string
local get_cycled_heading = function(line)
  if heading.has_heading(line) then
    return heading.cycle_heading(line)
  else
    return heading.create_heading(line)
  end
end

---Toggle heading mark
---@param line string
---@return string
local get_toggled_heading = function(line)
  if heading.has_heading(line) then
    return heading.remove_heading(line)
  else
    return heading.create_heading(line)
  end
end

---Toggle list mark
---@param line string
---@return string
local get_toggled_list = function(line)
  if checkbox.has_box(line) then
    return convert.box_to_list(line)
  elseif list.has_list(line) then
    return current_config.cycle_list_table and list.cycle_list(line) or list.remove_list(line)
  elseif olist.has_olist(line) then
    return convert.olist_to_list(line)
  else
    return list.create_list(line)
  end
end

---Cycle list mark
---@param line string
---@return string
local get_cycled_list = function(line)
  if checkbox.has_box(line) then
    return convert.box_to_list(line)
  elseif list.has_list(line) then
    return list.cycle_list(line)
  elseif olist.has_olist(line) then
    return convert.olist_to_list(line)
  else
    return list.create_list(line)
  end
end

---Toggle ordered list mark
---@param line string
---@return string
local get_toggled_olist = function(line)
  local result
  if checkbox.has_obox(line) then
    result = current_config.obox_as_olist and checkbox.remove_obox(line) or convert.obox_to_olist(line)
  elseif checkbox.has_box(line) then
    result = convert.box_to_olist(line) -- NOTE: same as Obsidian
  elseif list.has_list(line) then
    result = convert.list_to_olist(line)
  elseif olist.has_olist(line) then
    result = olist.remove_olist(line)
  else
    result = olist.create_olist(line)
  end

  -- Trigger recalculation after olist toggle (delayed to avoid interference)
  if current_config.enable_olist_recalc then vim.schedule(function() olist_recalc.trigger_olist_recalc(current_config.enable_olist_recalc) end) end

  return result
end

---Toggle checkbox
---@param line string
---@return string
local get_toggled_box = function(line)
  local _, _, state = checkbox.matched_box(line)
  local _, _, ostate = checkbox.matched_obox(line)

  if state == " " then
    return checkbox.check_box(line)
  elseif state ~= nil then
    return current_config.list_before_box and convert.box_to_list(line) or checkbox.uncheck_box(line)
  elseif ostate == " " then
    return checkbox.check_obox(line)
  elseif ostate ~= nil then
    return current_config.list_before_box and convert.obox_to_olist(line) or checkbox.uncheck_obox(line)
  elseif list.has_list(line) then
    return convert.list_to_box(line)
  elseif olist.has_olist(line) then
    return convert.olist_to_obox(line) -- NOTE: same as Obsidian
  else
    -- If `list_before_box` is true, a bullet list is toggled first.
    return current_config.list_before_box and list.create_list(line) or checkbox.create_box(line)
  end
end

---Cycle checkbox state
---@param line string
---@return string
local get_cycled_box = function(line)
  local _, _, state = checkbox.matched_box(line)
  local _, _, ostate = checkbox.matched_obox(line)

  if state ~= nil then
    local result = checkbox.cycle_box(line, current_config.list_before_box)
    if result == "convert_to_list" then return convert.box_to_list(line) end
    return result
  elseif ostate ~= nil then
    local result = checkbox.cycle_obox(line, current_config.list_before_box)
    if result == "convert_to_olist" then return convert.obox_to_olist(line) end
    return result
  elseif list.has_list(line) then
    return convert.list_to_box(line)
  elseif olist.has_olist(line) then
    return convert.olist_to_obox(line) -- NOTE: same as Obsidian
  else
    -- If `list_before_box` is true, a bullet list is toggled first.
    return current_config.list_before_box and list.create_list(line) or checkbox.create_box(line)
  end
end

--[========================================================[
                        Toggle Lines
--]========================================================]

---@alias ToggleMode "quote" | "list" | "list_cycle" | "olist" | "checkbox" | "checkbox_cycle" | "heading" | "heading_toggle"

---Get toggled line based on mode
---@param toggle_mode ToggleMode
---@param line string
---@return string new_line
M.get_toggled_line = function(toggle_mode, line)
  -- In quote-mode, simply toggle quote mark
  if toggle_mode == "quote" then return get_toggled_quote(line) end

  local new_line
  -- Separate a head-of-line quote mark from the rest(body)
  local sep_quote = quote.separate_quote(line)

  -- Toggle marks
  if toggle_mode == "checkbox" then
    new_line = current_config.cycle_box_table and get_cycled_box(sep_quote.body) or get_toggled_box(sep_quote.body)
  elseif toggle_mode == "checkbox_cycle" then
    new_line = get_cycled_box(sep_quote.body)
  elseif toggle_mode == "list" then
    new_line = current_config.cycle_list_table and get_cycled_list(sep_quote.body) or get_toggled_list(sep_quote.body)
  elseif toggle_mode == "list_cycle" then
    new_line = get_cycled_list(sep_quote.body)
  elseif toggle_mode == "olist" then
    new_line = get_toggled_olist(sep_quote.body)
  elseif toggle_mode == "heading" then
    new_line = get_cycled_heading(sep_quote.body)
  elseif toggle_mode == "heading_toggle" then
    new_line = get_toggled_heading(sep_quote.body)
  else
    error("Invalid toggle mode")
  end

  -- Combine a quote mark with the rest(sep_quote.body)
  if quote.has_quote(line) then new_line = sep_quote.whitespace .. sep_quote.mark .. new_line end

  return new_line
end

---Toggle one line in normal mode
---@param toggle_mode ToggleMode
M.toggle_one_line = function(toggle_mode)
  local line = vim.api.nvim_get_current_line()
  local new_line = M.get_toggled_line(toggle_mode, line)

  vim.api.nvim_set_current_line(new_line)
end

---Toggle all lines in visual mode
---@param toggle_mode ToggleMode
M.toggle_all_lines = function(toggle_mode)
  local start_line, end_line = util.get_vline_position()
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, true)
  local new_lines = lines

  for i, line in ipairs(lines) do
    repeat
      if toggle_mode ~= "quote" and line_state.skip_blankline(line, current_config.enable_blankline_skip) then break end
      if toggle_mode ~= "quote" and toggle_mode ~= "heading" and toggle_mode ~= "heading_toggle" and line_state.skip_heading(line, current_config.enable_heading_skip) then break end

      new_lines[i] = M.get_toggled_line(toggle_mode, line)
    until true
  end

  vim.api.nvim_buf_set_lines(0, start_line, end_line, true, new_lines)
end

---Toggle unmarked lines first, then all lines
---@param toggle_mode ToggleMode
M.toggle_unmarked_lines = function(toggle_mode)
  local start_line, end_line = util.get_vline_position()
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, true)
  local new_lines = lines
  local is_toggled = false

  -- 1st block: Toggle only unmarked lines
  for i, line in ipairs(lines) do
    repeat
      if toggle_mode ~= "quote" and line_state.skip_blankline(line, current_config.enable_blankline_skip) then break end
      if toggle_mode ~= "quote" and toggle_mode ~= "heading" and toggle_mode ~= "heading_toggle" and line_state.skip_heading(line, current_config.enable_heading_skip) then break end
      if toggle_mode ~= "quote" and line_state.has_mark(line, toggle_mode, current_config.obox_as_olist) then break end
      if toggle_mode == "quote" and quote.has_quote(line) then break end

      new_lines[i] = M.get_toggled_line(toggle_mode, line)
      if new_lines[i] ~= line then is_toggled = true end -- Set the toggled flag
    until true
  end

  -- 2nd block: If the toggled flag isn't set, toggle all lines
  if is_toggled == false then
    M.toggle_all_lines(toggle_mode)
    return
  end

  vim.api.nvim_buf_set_lines(0, start_line, end_line, true, new_lines)
end

---Toggle by vim mode
---@param toggle_mode ToggleMode
M.toggle_by_mode = function(toggle_mode)
  local vim_mode = vim.fn.mode()

  if vim_mode == "n" then
    M.toggle_one_line(toggle_mode)
  elseif vim_mode == "v" or vim_mode == "V" then
    if current_config.enable_unmarked_only then
      M.toggle_unmarked_lines(toggle_mode)
    else
      M.toggle_all_lines(toggle_mode)
    end
  end
end

---Check if should use v:count for this toggle mode
---@param toggle_mode ToggleMode
---@return boolean
local should_use_vcount = function(toggle_mode)
  return toggle_mode == "heading" or toggle_mode == "list_cycle" or toggle_mode == "checkbox_cycle"
end

---Toggle with v:count support
---@param toggle_mode ToggleMode
M.toggle_with_vcount = function(toggle_mode)
  if should_use_vcount(toggle_mode) then
    local count = vim.v.count1
    for _ = 1, count do
      M.toggle_by_mode(toggle_mode)
    end
  else
    M.toggle_by_mode(toggle_mode)
  end
end

return M
