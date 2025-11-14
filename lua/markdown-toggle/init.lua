local M = {}

local util = require("markdown-toggle.util")

--[========================================================[
                        Configuration
--]========================================================]
local config = require("markdown-toggle.config")
local keymap = require("markdown-toggle.keymap")

---@type MarkdownToggleConfig
local current_config = config.set()
-- Cache frequently used config values for performance
local list_mark = current_config.list_table[1]
local checked_state = current_config.box_table[1]

local update_config_values = function()
  list_mark = current_config.list_table[1]
  checked_state = current_config.box_table[1]
end

---@param user_config MarkdownToggleConfig
M.setup = function(user_config)
  current_config = config.set(user_config)
  update_config_values()

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

---@param option_name string
local switch_option = function(option_name)
  local user_config = { [option_name] = not current_config[option_name] }
  M.setup(user_config)

  local status = current_config[option_name] and "enabled" or "disabled"
  local msg_type = current_config[option_name] and "None" or "WarningMsg"
  vim.api.nvim_echo({ { string.format("MarkdownToggle: `%s` %s", option_name, status), msg_type } }, true, {})
end

local list_marks = function()
  local pattern = ""
  for _, mark in ipairs(current_config.list_table) do
    pattern = pattern .. "%" .. mark
  end
  return pattern
end

local box_states = function()
  local pattern = " " -- Always include space
  for _, state in ipairs(current_config.box_table) do
    pattern = pattern .. state
  end
  return pattern
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
  local headings = current_config.heading_table
  local matched = matched_heading(line)
  for i, heading in ipairs(headings) do
    if matched == heading and i < #headings then return headings[i + 1] end
    if matched == headings[#headings] then return "end" end -- At the last element
  end
  return headings[1]
end
local cycle_heading = function(line)
  local mark = cycled_heading_mark(line)
  if mark == "end" then return remove_heading(line) end
  return (line:gsub("#+", mark, 1))
end

--[========================================================[
                            Lists
--]========================================================]
-- NOTE: This regex matches dynamically generated list marks
local matched_list = function(line) return line:match("^([%s>]*)([" .. list_marks() .. "])%s.*$") end
local has_list = function(line) return matched_list(line) ~= nil end
local create_list = function(line, mark) return (line:gsub("^([%s>]*)(.*)", "%1" .. mark .. " %2")) end
local remove_list = function(line) return (line:gsub("[" .. list_marks() .. "]%s", "", 1)) end
local box_to_list = function(line, mark)
  return (line:gsub("^([%s>]*)[" .. list_marks() .. "]%s%[[" .. box_states() .. "]%]%s(.*)", "%1" .. mark .. " %2"))
end
local olist_to_list = function(line, mark) return (line:gsub("^([%s>]*)%d+%.%s(.*)", "%1" .. mark .. " %2")) end

local cycled_list_mark = function(line)
  local marks = current_config.list_table
  local _, matched = matched_list(line)
  for i, mark in ipairs(marks) do
    if matched == mark and i < #marks then return marks[i + 1] end
    if matched == marks[#marks] then return "end" end -- At the last element
  end
  return marks[1]
end
local cycle_list = function(line)
  local mark = cycled_list_mark(line)
  if mark == "end" then return remove_list(line) end
  return (line:gsub("[" .. list_marks() .. "]", mark, 1))
end

--[========================================================[
                        Ordered Lists
--]========================================================]
-- NOTE: This regex matches: "1", "2", "3", ...
local matched_olist = function(line) return line:match("^([%s>]*)(%d+)%.%s") end
local has_olist = function(line) return matched_olist(line) ~= nil end
local create_olist = function(line) return (line:gsub("^([%s>]*)(.*)", "%11. %2")) end
local remove_olist = function(line) return line:gsub("([%s>]*)%d+%.%s", "%1", 1) end
local list_to_olist = function(line) return (line:gsub("^([%s>]*)[" .. list_marks() .. "]%s(.*)", "%11. %2")) end
local box_to_olist = function(line)
  return (line:gsub("^([%s>]*)[" .. list_marks() .. "]%s%[[" .. box_states() .. "]%]%s(.*)", "%11. %2"))
end
local obox_to_olist = function(line) return (line:gsub("^([%s>]*)(%d+%.%s)%[[" .. box_states() .. "]%]%s(.*)", "%1%2%3")) end

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
-- group2(mark): dynamically generated from list_table
-- group3(state): dynamically generated from box_table
local matched_box = function(line) return line:match("^([%s>]*)([" .. list_marks() .. "])%s%[([" .. box_states() .. "])%]%s") end
local has_box = function(line) return matched_box(line) ~= nil end
local check_box = function(line) return (line:gsub("([" .. list_marks() .. "]%s)%[ %]", "%1[" .. checked_state .. "]", 1)) end
local uncheck_box = function(line)
  return (line:gsub("([" .. list_marks() .. "]%s)%[([" .. box_states() .. "])%]", "%1" .. empty_box(), 1))
end
local create_box = function(line, mark) return (line:gsub("^([%s>]*)(.*)", "%1" .. string.format("%s %s ", mark, empty_box()) .. "%2")) end
local remove_box = function(line) return line:gsub("([%s>]*)[" .. list_marks() .. "]%s%[([" .. box_states() .. "])%]%s", "%1", 1) end
local list_to_box = function(line, mark)
  return (line:gsub("^([%s>]*)[" .. list_marks() .. "]%s(.*)", "%1" .. string.format("%s %s ", mark, empty_box()) .. "%2"))
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
  return states[1]
end
local cycle_box = function(line, mark)
  local state = cycled_box_state(line)
  if state == "end" then return current_config.list_before_box and box_to_list(line, mark) or uncheck_box(line) end
  return (line:gsub("(%[)([" .. box_states() .. "])(%])", "%1" .. state .. "%3", 1))
end

--------- Ordered Checkboxes ---------
-- NOTE: This regex matches ordered-checkbox:
-- group1(whitespace): spaces or quotes
-- group2(number): "1", "2", "3", ...
-- group3(state): dynamically generated from box_table
local matched_obox = function(line) return line:match("^([%s>]*)(%d+)%.%s%[([" .. box_states() .. "])%]%s") end
local has_obox = function(line) return matched_obox(line) ~= nil end
local check_obox = function(line) return (line:gsub("(%d+%.%s)%[ %]", "%1[" .. checked_state .. "]", 1)) end
local uncheck_obox = function(line) return (line:gsub("(%d+%.%s)%[([" .. box_states() .. "])%]", "%1" .. empty_box(), 1)) end
local create_obox = function(line) return (line:gsub("^([%s>]*)(.*)", "%11. " .. empty_box() .. " %2")) end
local remove_obox = function(line) return line:gsub("([%s>]*)%d+%.%s%[([" .. box_states() .. "])%]%s", "%1", 1) end
local olist_to_obox = function(line) return (line:gsub("^([%s>]*)(%d+%.%s)(.*)", "%1%2" .. empty_box() .. " %3")) end
local cycled_obox_state = function(line)
  local states = current_config.box_table
  local _, _, matched = matched_obox(line)
  for i, state in ipairs(states) do
    if matched == state and i < #states then return states[i + 1] end
    if matched == states[#states] then return "end" end -- At the last element
  end
  return states[1]
end
local cycle_obox = function(line)
  local state = cycled_obox_state(line)
  if state == "end" then return current_config.list_before_box and obox_to_olist(line) or uncheck_obox(line) end
  return (line:gsub("(%[)([" .. box_states() .. "])(%])", "%1" .. state .. "%3", 1))
end

--[========================================================[
                  Ordered List Recalculation
--]========================================================]
-- Check if recalculation should continue for this line
local should_continue_recalc = function(line)
  -- Heading lines stop recalculation immediately
  if has_heading(line) then return false end

  -- Quote lines: continue only if they contain list/olist/checkbox/obox marks
  if has_quote(line) then
    local sep_quote = separate_quote(line)
    local body = sep_quote.body

    -- Continue if quote contains any list marks (short-circuit evaluation)
    if has_list(body) or has_olist(body) or has_box(body) or has_obox(body) then return true end
    -- Stop if quote has no internal marks
    return false
  end

  -- All other lines (text, blank, list, checkbox, etc.) continue recalculation
  return true
end

-- Find the range of lines that should be recalculated together
---@param cursor_line_num integer
---@return integer, integer
local find_olist_recalc_range = function(cursor_line_num)
  local total_lines = vim.api.nvim_buf_line_count(0)

  -- Find upward boundary (stop condition or buffer start)
  local start_line = cursor_line_num
  for line_num = cursor_line_num - 1, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
    if not should_continue_recalc(line) then
      start_line = line_num + 1 -- Start after the stop condition
      break
    end
    start_line = line_num
  end

  -- Find downward boundary (stop condition or buffer end)
  local end_line = cursor_line_num
  for line_num = cursor_line_num + 1, total_lines do
    local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
    if not should_continue_recalc(line) then
      end_line = line_num - 1 -- End before the stop condition
      break
    end
    end_line = line_num
  end

  return start_line, end_line
end

-- Get indentation signature for olist comparison (includes quote context)
local get_olist_indent_signature = function(line)
  if has_quote(line) then
    local sep_quote = separate_quote(line)
    -- For quoted olist, return a unique signature that includes quote context
    if has_olist(sep_quote.body) or has_obox(sep_quote.body) then
      local inner_indent = sep_quote.body:match("^(%s*)")
      return "quoted:" .. inner_indent -- Unique signature for quoted olist
    end
  end
  -- For regular olist, use just the indentation
  if has_olist(line) or has_obox(line) then return "regular:" .. line:match("^(%s*)") end
  return ""
end

-- Recalculate ordered list numbers in the specified range with same context and indentation
---@param start_line integer
---@param end_line integer
local recalculate_olist_in_range = function(start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local cursor_line_num = vim.api.nvim_win_get_cursor(0)[1]
  local cursor_line = vim.api.nvim_buf_get_lines(0, cursor_line_num - 1, cursor_line_num, false)[1]

  -- Get the indentation signature of the cursor line or target olist line
  local target_signature = ""
  if has_olist(cursor_line) or has_obox(cursor_line) then
    target_signature = get_olist_indent_signature(cursor_line)
  else
    -- Find the first olist line in range to determine target signature
    for _, line in ipairs(lines) do
      if has_olist(line) or has_obox(line) then
        target_signature = get_olist_indent_signature(line)
        break
      end
    end
  end

  -- If no target signature found, don't recalculate
  if target_signature == "" then return end

  local olist_counter = 1

  for i, line in ipairs(lines) do
    if has_olist(line) or has_obox(line) then
      local line_signature = get_olist_indent_signature(line)

      -- Only recalculate lines with the same signature (context + indentation)
      if line_signature == target_signature then
        local line_num = start_line + i - 1
        local new_line
        if has_quote(line) then
          -- For quoted olist, preserve quote marks and update number
          local sep_quote = separate_quote(line)
          local updated_body = sep_quote.body:gsub("^(%s*)%d+(%.%s)", "%1" .. olist_counter .. "%2")
          new_line = sep_quote.mark .. updated_body
        else
          -- For regular olist, update number directly
          new_line = line:gsub("^(%s*)%d+(%.%s)", "%1" .. olist_counter .. "%2")
        end
        vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { new_line })
        olist_counter = olist_counter + 1
      end
    end
  end
end

-- Trigger ordered list recalculation from cursor position
local trigger_olist_recalc = function()
  if not current_config.enable_olist_recalc then return end

  local cursor_line_num = vim.api.nvim_win_get_cursor(0)[1]
  local start_line, end_line = find_olist_recalc_range(cursor_line_num)

  -- Only recalculate if there are olist lines in the range
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local has_olist_in_range = false
  for _, line in ipairs(lines) do
    if has_olist(line) or has_obox(line) then
      has_olist_in_range = true
      break
    end
  end

  if has_olist_in_range then recalculate_olist_in_range(start_line, end_line) end
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
  local body = separate_quote(line).body

  -- Check if already marked
  return toggle_mode == "checkbox" and (has_box(body) or has_obox(body))
    or toggle_mode == "checkbox_cycle" and (has_box(body) or has_obox(body))
    or toggle_mode == "list" and has_list(body)
    or toggle_mode == "list_cycle" and has_list(body)
    or toggle_mode == "olist" and (has_obox(body) and current_config.obox_as_olist or has_olist(body) and not has_obox(body))
    or toggle_mode == "heading" and has_heading(body)
    or toggle_mode == "heading_toggle" and has_heading(body)
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
local get_cycled_heading = function(line)
  if has_heading(line) then
    return cycle_heading(line)
  else
    return create_heading(line, current_config.heading_table[1])
  end
end

--- @param line string
--- @return string
local get_toggled_heading = function(line)
  if has_heading(line) then
    return remove_heading(line)
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
  local result
  if has_obox(line) then
    result = current_config.obox_as_olist and remove_obox(line) or obox_to_olist(line)
  elseif has_box(line) then
    -- return box_to_obox(line)
    result = box_to_olist(line) -- NOTE: same as Obsidian
  elseif has_list(line) then
    result = list_to_olist(line)
  elseif has_olist(line) then
    result = remove_olist(line)
  else
    result = create_olist(line)
  end

  -- Trigger recalculation after olist toggle (delayed to avoid interference)
  if current_config.enable_olist_recalc then vim.schedule(function() trigger_olist_recalc() end) end

  return result
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
--- @alias ToggleMode "quote" | "list" | "list_cycle" | "olist" | "checkbox" | "checkbox_cycle" | "heading" | "heading_toggle"

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
    new_line = get_cycled_heading(sep_quote.body)
  elseif toggle_mode == "heading_toggle" then
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
      if toggle_mode ~= "quote" and toggle_mode ~= "heading" and toggle_mode ~= "heading_toggle" and skip_heading(line) then break end

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
      if toggle_mode ~= "quote" and toggle_mode ~= "heading" and toggle_mode ~= "heading_toggle" and skip_heading(line) then break end
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

--- @param toggle_mode ToggleMode
local should_use_vcount = function(toggle_mode)
  return toggle_mode == "heading" or toggle_mode == "list_cycle" or toggle_mode == "checkbox_cycle"
end

--- @param toggle_mode ToggleMode
local toggle_with_vcount = function(toggle_mode)
  if should_use_vcount(toggle_mode) then
    local count = vim.v.count1
    for _ = 1, count do
      toggle_by_mode(toggle_mode)
    end
  else
    toggle_by_mode(toggle_mode)
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

  local _, box_mark, box_state = matched_box(sep_quote.body)
  local box = box_state ~= nil and string.format("%s [%s] ", box_mark, box_state) or nil
  local _, list = matched_list(sep_quote.body)
  local _, olist = matched_olist(sep_quote.body)

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

    -- Trigger recalculation after autolist creates olist (delayed)
    if current_config.enable_olist_recalc then
      vim.schedule(function()
        trigger_olist_recalc()
      end)
    end
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
  -- Regular function with v:count support
  M[toggle_mode] = function() toggle_with_vcount(toggle_mode) end

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
