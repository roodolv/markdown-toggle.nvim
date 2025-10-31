local M = {}

local util = require("markdown-toggle.util")

--[========================================================[
                        Configuration
--]========================================================]
local config = require("markdown-toggle.config")
local keymap = require("markdown-toggle.keymap")

---@type MarkdownToggleConfig
local current_config = config.set()
local list_mark = current_config.list_table[1] and current_config.list_table[1] or "-"

---@param user_config MarkdownToggleConfig
M.setup = function(user_config)
  current_config = config.set(user_config)

  if current_config.use_default_keymaps then keymap.set(current_config) end
  if current_config.list_table[1] ~= list_mark then list_mark = current_config.list_table[1] end
end

---@param option_name string
local switch_option = function(option_name)
  local user_config = { [option_name] = not current_config[option_name] }
  M.setup(user_config)

  local status = current_config[option_name] and "enabled" or "disabled"
  local msg_type = current_config[option_name] and "None" or "WarningMsg"
  vim.api.nvim_echo({ { string.format("MarkdownToggle: `%s` %s", option_name, status), msg_type } }, true, {})
end

--[========================================================[
                           Quotes
--]========================================================]
local has_quote = function(line) return line:match("^%s*>") ~= nil end
local create_quote = function(line) return (line:gsub("^(.*)$", "> %1")) end
local remove_quote = function(line)
  if line:match("^%s*>%s") then
    -- Pattern: "> content" -> "content"
    return line:gsub("^(%s*)>%s", "%1", 1)
  elseif line:match("^%s*>") then
    -- Pattern: ">content" or ">>content" -> remove first >
    return line:gsub("^(%s*)>", "%1", 1)
  end
  return line
end

-- Extract quote marks from the beginning of line
local extract_quote_marks = function(line)
  -- Match patterns like: >, >>, >>>, > >, > > >, etc.
  local quote_part = line:match("^(%s*>.*)")
  if not quote_part then return "" end

  -- Find where the actual content starts (after all quote marks and spaces)
  local content_start = 1
  local i = 1
  while i <= #quote_part do
    local char = quote_part:sub(i, i)
    if char == ">" then
      content_start = i + 1
      -- Skip optional space after >
      if i + 1 <= #quote_part and quote_part:sub(i + 1, i + 1) == " " then content_start = i + 2 end
    elseif char == " " then
      -- Continue
    else
      break
    end
    i = i + 1
  end

  return quote_part:sub(1, content_start - 1)
end

local separate_quote = function(line)
  local quote_marks = extract_quote_marks(line)
  if quote_marks == "" then return { whitespace = "", mark = "", body = line } end

  local body = line:sub(#quote_marks + 1)
  return { whitespace = "", mark = quote_marks, body = body }
end

--[========================================================[
                          Headings
--]========================================================]
local matched_heading = function(line) return line:match("^[%s>]*(#+)%s") end
local has_heading = function(line) return matched_heading(line) ~= nil end
local create_heading = function(line, mark) return (line:gsub("^([%s>]*)(.*)$", "%1" .. mark .. " %2")) end
local remove_heading = function(line) return line:gsub("#+%s", "", 1) end

local cycled_heading_mark = function(line)
  local headings = current_config.heading_table and current_config.heading_table
    or { "#", "##", "###", "####", "#####" }
  local matched = matched_heading(line)
  for i, heading in ipairs(headings) do
    if matched == heading and i < #headings then return headings[i + 1] end
    if matched == headings[#headings] then return "end" end -- At the last element
  end
  return headings[1] ~= nil and headings[1] or "#"
end
local cycle_heading = function(line)
  local mark = cycled_heading_mark(line)
  if mark == "end" then return remove_heading(line) end
  return (line:gsub("#+", mark, 1))
end

--[========================================================[
                            Lists
--]========================================================]
-- NOTE: This regex matches: "-", "+", "*", "="
local matched_list = function(line) return line:match("^([%s>]*)([%-%+%*%=])%s.*$") end
local has_list = function(line) return matched_list(line) ~= nil end
local create_list = function(line, mark) return (line:gsub("^([%s>]*)(.*)", "%1" .. mark .. " %2")) end
local remove_list = function(line) return (line:gsub("[%-%+%*%=]%s", "", 1)) end
local box_to_list = function(line, mark)
  return (line:gsub("^([%s>]*)[%-%+%*%=]%s%[[ x~!>]%]%s(.*)", "%1" .. mark .. " %2"))
end
local olist_to_list = function(line, mark) return (line:gsub("^([%s>]*)%d+%.%s(.*)", "%1" .. mark .. " %2")) end

local cycled_list_mark = function(line)
  local marks = current_config.list_table and current_config.list_table or { "-" }
  local _, matched = matched_list(line)
  for i, mark in ipairs(marks) do
    if matched == mark and i < #marks then return marks[i + 1] end
    if matched == marks[#marks] then return "end" end -- At the last element
  end
  return marks[1] ~= nil and marks[1] or "-"
end
local cycle_list = function(line)
  local mark = cycled_list_mark(line)
  if mark == "end" then return remove_list(line) end
  return (line:gsub("[%-%+%*%=]", mark, 1))
end

--[========================================================[
                        Ordered Lists
--]========================================================]
-- NOTE: This regex matches: "1", "2", "3", ...
local matched_olist = function(line) return line:match("^([%s>]*)(%d+)%.%s") end
local has_olist = function(line) return matched_olist(line) ~= nil end
local create_olist = function(line) return (line:gsub("^([%s>]*)(.*)", "%11. %2")) end
local remove_olist = function(line) return line:gsub("([%s>]*)%d+%.%s", "%1", 1) end
local list_to_olist = function(line) return (line:gsub("^([%s>]*)[%-%+%*%=]%s(.*)", "%11. %2")) end
local box_to_olist = function(line) return (line:gsub("^([%s>]*)[%-%+%*%=]%s%[[ x~!>]%]%s(.*)", "%11. %2")) end
local obox_to_olist = function(line) return (line:gsub("^([%s>]*)(%d+%.%s)%[[ x~!>]%]%s(.*)", "%1%2%3")) end

---@param olist_mark string 1, 2, 3, ...
---@return string
local increment_olist = function(olist_mark)
  local num = tonumber(olist_mark)
  return string.format("%d. ", num + 1)
end
---@param olist_mark string 1, 2, 3, ...
---@return string
local decrement_olist = function(olist_mark)
  local num = tonumber(olist_mark)
  return string.format("%d. ", num - 1)
end

--[========================================================[
                         Checkboxes
--]========================================================]
local empty_box = function() return "[ ]" end

--------- Normal Checkboxes ---------
-- NOTE: This regex matches:
-- group1(whitespace): spaces or quotes
-- group2(mark): "-", "+", "*", "="
-- group3(state): " ", "x", "~", "!", ">"
local matched_box = function(line) return line:match("^([%s>]*)([%-%+%*%=])%s%[([ x~!>])%]%s") end
local has_box = function(line) return matched_box(line) ~= nil end
local check_box = function(line)
  return (line:gsub("([%-%+%*%=]%s)%[ %]", "%1[" .. current_config.box_table[1] .. "]", 1))
end
local uncheck_box = function(line) return (line:gsub("([%-%+%*%=]%s)%[[x~!>]%]", "%1" .. empty_box(), 1)) end
local create_box = function(line, mark)
  return (line:gsub("^([%s>]*)(.*)", "%1" .. string.format("%s %s ", mark, empty_box()) .. "%2"))
end
local remove_box = function(line) return line:gsub("([%s>]*)[%-%+%*%=]%s%[[ x~!>]%]%s", "%1", 1) end
local list_to_box = function(line, mark)
  return (line:gsub("^([%s>]*)[%-%+%*%=]%s(.*)", "%1" .. string.format("%s %s ", mark, empty_box()) .. "%2"))
end
local olist_to_box = function(line, mark)
  return (line:gsub("^([%s>]*)%d+%.%s(.*)", "%1" .. string.format("%s %s ", mark, empty_box()) .. "%2"))
end
local cycled_box_state = function(line)
  local states = current_config.box_table
  local _, _, matched = matched_box(line)
  for i, state in ipairs(states) do
    if matched == state and i < #states then return states[i + 1] end
    if matched == states[#states] then return "end" end -- At the last element
  end
  return states[1] ~= nil and states[1] or " "
end
local cycle_box = function(line, mark)
  local state = cycled_box_state(line)
  if state == "end" then return current_config.list_before_box and box_to_list(line, mark) or uncheck_box(line) end
  return (line:gsub("(%[)[ x~!>](%])", "%1" .. state .. "%2", 1))
end

--------- Ordered Checkboxes ---------
-- NOTE: This regex matches ordered-checkbox:
-- group1(whitespace): spaces or quotes
-- group2(number): "1", "2", "3", ...
-- group3(state): " ", "x", "~", "!", ">"
local matched_obox = function(line) return line:match("^([%s>]*)(%d+)%.%s%[([ x~!>])%]%s") end
local has_obox = function(line) return matched_obox(line) ~= nil end
local check_obox = function(line) return (line:gsub("(%d+%.%s)%[ %]", "%1[" .. current_config.box_table[1] .. "]", 1)) end
local uncheck_obox = function(line) return (line:gsub("(%d+%.%s)%[[x~!>]%]", "%1" .. empty_box(), 1)) end
local create_obox = function(line) return (line:gsub("^([%s>]*)(.*)", "%11. " .. empty_box() .. " %2")) end
local remove_obox = function(line) return line:gsub("([%s>]*)%d+%.%s%[[ x~!>]%]%s", "%1", 1) end
local olist_to_obox = function(line) return (line:gsub("^([%s>]*)(%d+%.%s)(.*)", "%1%2" .. empty_box() .. " %3")) end
local cycled_obox_state = function(line)
  local states = current_config.box_table
  local _, _, matched = matched_obox(line)
  for i, state in ipairs(states) do
    if matched == state and i < #states then return states[i + 1] end
    if matched == states[#states] then return "end" end -- At the last element
  end
  return states[1] ~= nil and states[1] or " "
end
local cycle_obox = function(line)
  local state = cycled_obox_state(line)
  if state == "end" then return current_config.list_before_box and obox_to_olist(line) or uncheck_obox(line) end
  return (line:gsub("(%[)[ x~!>](%])", "%1" .. state .. "%2", 1))
end

--[========================================================[
                         Line State
--]========================================================]
local matched_bol = function(line) return line:match("^(%s*).*$") end
local matched_body = function(line) return line:match("^%s*(.*)$") end
local matched_bol_body = function(line) return line:match("^(%s*)(.*)$") end
local is_blankline = function(line) return line:match("^$") ~= nil end
local skip_blankline = function(line) return current_config.enable_blankline_skip and is_blankline(line) end
local skip_heading = function(line) return current_config.enable_heading_skip and has_heading(line) end
local has_mark = function(line, toggle_mode)
  -- Separate a head-of-line quote mark from the rest(body)
  local body = separate_quote(line).body or line

  -- Check if already marked
  -- PERF: Only `has_box(body)` is needed; remove `has_box(line)`
  return toggle_mode == "checkbox" and (has_box(line) or has_box(body) or has_obox(line) or has_obox(body))
    or toggle_mode == "checkbox_cycle" and (has_box(line) or has_box(body) or has_obox(line) or has_obox(body))
    or toggle_mode == "list" and (has_list(line) or has_list(body))
    or toggle_mode == "list_cycle" and (has_list(line) or has_list(body))
    or toggle_mode == "olist" and (has_olist(line) or has_olist(body) or has_obox(line) or has_obox(body))
    or toggle_mode == "heading" and (has_heading(line) or has_heading(body))
end

--[========================================================[
                        Toggle Marks
--]========================================================]
--- @param line string
--- @return string
local get_toggled_quote = function(line)
  if has_quote(line) then
    return remove_quote(line)
  else
    return create_quote(line)
  end
end

--- @param line string
--- @return string
local get_toggled_heading = function(line)
  if has_heading(line) then
    return cycle_heading(line)
  else
    return create_heading(line, current_config.heading_table[1])
  end
end

--- @param line string
--- @return string
local get_toggled_list = function(line)
  if has_box(line) then
    return box_to_list(line, list_mark)
  elseif has_list(line) then
    return current_config.cycle_list_table and cycle_list(line) or remove_list(line)
  elseif has_olist(line) then
    return olist_to_list(line, list_mark)
  else
    return create_list(line, list_mark)
  end
end

--- @param line string
--- @return string
local get_cycled_list = function(line)
  if has_box(line) then
    return box_to_list(line, list_mark)
  elseif has_list(line) then
    return cycle_list(line)
  elseif has_olist(line) then
    return olist_to_list(line, list_mark)
  else
    return create_list(line, list_mark)
  end
end

--- @param line string
--- @return string
local get_toggled_olist = function(line)
  if has_obox(line) then
    return current_config.obox_as_olist and remove_obox(line) or obox_to_olist(line)
  elseif has_box(line) then
    -- return box_to_obox(line)
    return box_to_olist(line) -- NOTE: same as Obsidian
  elseif has_list(line) then
    return list_to_olist(line)
  elseif has_olist(line) then
    return remove_olist(line)
  else
    return create_olist(line)
  end
end

--- @param line string
--- @return string
local get_toggled_box = function(line)
  local _, _, state = matched_box(line)
  local _, _, ostate = matched_obox(line)

  if state == " " then
    return check_box(line)
  elseif state ~= nil then
    return current_config.list_before_box and box_to_list(line, list_mark) or uncheck_box(line)
  elseif ostate == " " then
    return check_obox(line)
  elseif ostate ~= nil then
    return current_config.list_before_box and obox_to_olist(line) or uncheck_obox(line)
  elseif has_list(line) then
    return list_to_box(line, list_mark)
  elseif has_olist(line) then
    -- return olist_to_box(line, list_mark)
    return olist_to_obox(line) -- NOTE: same as Obsidian
  else
    -- If `list_before_box` is true, a bullet list is toggled first.
    return current_config.list_before_box and create_list(line, list_mark) or create_box(line, list_mark)
  end
end

--- @param line string
--- @return string
local get_cycled_box = function(line)
  local _, _, state = matched_box(line)
  local _, _, ostate = matched_obox(line)

  if state ~= nil then
    return cycle_box(line, list_mark)
  elseif ostate ~= nil then
    return cycle_obox(line)
  elseif has_list(line) then
    return list_to_box(line, list_mark)
  elseif has_olist(line) then
    -- return olist_to_box(line, list_mark)
    return olist_to_obox(line) -- NOTE: same as Obsidian
  else
    -- If `list_before_box` is true, a bullet list is toggled first.
    return current_config.list_before_box and create_list(line, list_mark) or create_box(line, list_mark)
  end
end

--[========================================================[
                        Toggle Lines
--]========================================================]
--- @alias ToggleMode "quote" | "list" | "list_cycle" | "olist" | "checkbox" | "checkbox_cycle" | "heading"

--- @param toggle_mode ToggleMode
--- @param line string
--- @return string new_line
local get_toggled_line = function(toggle_mode, line)
  -- In quote-mode, simply toggle quote mark
  if toggle_mode == "quote" then return get_toggled_quote(line) end

  local new_line
  -- Separate a head-of-line quote mark from the rest(body)
  local sep_quote = separate_quote(line)

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
    new_line = get_toggled_heading(sep_quote.body)
  else
    error("Invalid toggle mode")
  end

  -- Combine a quote mark with the rest(sep_quote.body)
  if has_quote(line) then new_line = sep_quote.whitespace .. sep_quote.mark .. new_line end

  return new_line
end

--- @param toggle_mode ToggleMode
local toggle_one_line = function(toggle_mode)
  local line = vim.api.nvim_get_current_line()
  local new_line = get_toggled_line(toggle_mode, line)

  vim.api.nvim_set_current_line(new_line)
end

--- @param toggle_mode ToggleMode
local toggle_all_lines = function(toggle_mode)
  local start_line, end_line = util.get_vline_position()
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, true)
  local new_lines = lines

  for i, line in ipairs(lines) do
    repeat
      if toggle_mode ~= "quote" and skip_blankline(line) then break end
      if toggle_mode ~= "quote" and toggle_mode ~= "heading" and skip_heading(line) then break end

      new_lines[i] = get_toggled_line(toggle_mode, line)
    until true
  end

  vim.api.nvim_buf_set_lines(0, start_line, end_line, true, new_lines)
end

--- @param toggle_mode ToggleMode
local toggle_unmarked_lines = function(toggle_mode)
  local start_line, end_line = util.get_vline_position()
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, true)
  local new_lines = lines
  local is_toggled = false

  -- 1st block: Toggle only unmarked lines
  for i, line in ipairs(lines) do
    repeat
      if toggle_mode ~= "quote" and skip_blankline(line) then break end
      if toggle_mode ~= "quote" and toggle_mode ~= "heading" and skip_heading(line) then break end
      if toggle_mode ~= "quote" and has_mark(line, toggle_mode) then break end
      if toggle_mode == "quote" and has_quote(line) then break end

      new_lines[i] = get_toggled_line(toggle_mode, line)
      if new_lines[i] ~= line then is_toggled = true end -- Set the toggled flag
    until true
  end

  -- 2nd block: If the toggled flag isn't set, toggle all lines
  if is_toggled == false then
    toggle_all_lines(toggle_mode)
    return
  end

  vim.api.nvim_buf_set_lines(0, start_line, end_line, true, new_lines)
end

--- @param toggle_mode ToggleMode
local toggle_by_mode = function(toggle_mode)
  local vim_mode = vim.fn.mode()

  if vim_mode == "n" then
    toggle_one_line(toggle_mode)
  elseif vim_mode == "v" or vim_mode == "V" then
    if current_config.enable_unmarked_only then
      toggle_unmarked_lines(toggle_mode)
    else
      toggle_all_lines(toggle_mode)
    end
  end
end

--[========================================================[
                          Autolist
--]========================================================]
---@param cin string character input
local autolist = function(cin)
  local line = vim.api.nvim_get_current_line()

  -- First, separate quote marks from the entire line (preserving leading spaces)
  local sep_quote = separate_quote(line)

  -- New beginning-of-line
  local new_bol = ""

  -- If a quote mark exists, combine the quote mark with the bol spaces
  if sep_quote.mark and sep_quote.mark ~= "" then new_bol = new_bol .. sep_quote.mark end

  -- If a quote mark exists, the rest of the line is passed as a target
  local target_line = (sep_quote.mark and sep_quote.mark ~= "") and sep_quote.body or sep_quote.body

  local _, box_mark, box_state = matched_box(target_line)
  local box = box_state ~= nil and string.format("%s [%s] ", box_mark, box_state) or nil
  local _, list = matched_list(target_line)
  local _, olist = matched_olist(target_line)

  -- stylua: ignore
  if box ~= nil then
    if not current_config.enable_auto_samestate then
      box = string.format("%s %s ", box_mark, empty_box())
    end
    vim.api.nvim_feedkeys(cin .. new_bol .. box, "n", false)
  elseif list ~= nil then
    list = list .. " "
    vim.api.nvim_feedkeys(cin .. new_bol .. list, "n", false)
  elseif olist ~= nil then
    olist = (cin == "O") and decrement_olist(olist) or increment_olist(olist)
    vim.api.nvim_feedkeys(cin .. new_bol .. olist, "n", false)
  elseif sep_quote.mark then
    -- In the case of quote-only
    vim.api.nvim_feedkeys(cin .. new_bol, "n", false)
  else
    vim.api.nvim_feedkeys(cin, "n", false) -- As usual
  end
end

--[========================================================[
                            API
--]========================================================]
-- Setup functions such like: `M.quote()`, `M.quote_dot()`
local setup_toggle_functions = function(toggle_mode)
  M[toggle_mode] = function() toggle_by_mode(toggle_mode) end
  M[toggle_mode .. "_dot"] = function()
    vim.go.operatorfunc = string.format("v:lua.require'markdown-toggle'.%s", toggle_mode)
    return "g@l"
  end
end

-- Toggle Functions
local toggle_modes = { "quote", "list", "list_cycle", "olist", "checkbox", "checkbox_cycle", "heading" }
for _, toggle_mode in ipairs(toggle_modes) do
  setup_toggle_functions(toggle_mode)
end

-- Autolist
M.autolist_up = function() autolist("O") end
M.autolist_down = function() autolist("o") end
M.autolist_cr = function() autolist(util.get_eol()) end

-- Config-switch
M.switch_blankline_skip = function() switch_option("enable_blankline_skip") end
M.switch_heading_skip = function() switch_option("enable_heading_skip") end
M.switch_unmarked_only = function() switch_option("enable_unmarked_only") end
M.switch_auto_samestate = function() switch_option("enable_auto_samestate") end

M.switch_cycle_list_table = function() switch_option("cycle_list_table") end
M.switch_cycle_box_table = function() switch_option("cycle_box_table") end
M.switch_list_before_box = function() switch_option("list_before_box") end

return M
