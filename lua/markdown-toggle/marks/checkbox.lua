local M = {}

-- Module-level config cache (initialized by set_config)
local list_marks = "" -- Regex pattern for list marks
local box_states = " " -- Regex pattern for box states
local list_mark = "-" -- Default list mark
local checked_state = "x" -- Default checked box state
local box_table = { "x", "~", "!", ">" }

---Set checkbox configuration
---@param marks_pattern string Regex pattern for list marks
---@param states_pattern string Regex pattern for box states
---@param default_mark string Default list mark
---@param default_state string Default checked box state
---@param table string[] Box states table
M.set_config = function(marks_pattern, states_pattern, default_mark, default_state, table)
  list_marks = marks_pattern
  box_states = states_pattern
  list_mark = default_mark
  checked_state = default_state
  box_table = table
end

---Get empty box representation
---@return string
M.empty_box = function() return "[ ]" end

--------- Normal Checkboxes ---------

---Match checkbox in line
---@param line string
---@return string|nil, string|nil, string|nil, string|nil, string|nil whitespace, mark, state, text, trailing
-- group1(whitespace): spaces or quotes
-- group2(mark): dynamically generated from list_table
-- group3(state): dynamically generated from box_table
-- group4(text): text after ]
-- group5(trailing): trailing spaces after the text
M.matched_box = function(line) return line:match("^([%s>]*)([" .. list_marks .. "])%s%[([" .. box_states .. "])%]%s(.-)(%s*)$") end

---Check if line has a checkbox
---@param line string
---@return boolean
M.has_box = function(line) return M.matched_box(line) ~= nil end

---Check the checkbox
---@param line string
---@return string
M.check_box = function(line) return (line:gsub("([" .. list_marks .. "]%s)%[ %]", "%1[" .. checked_state .. "]", 1)) end

---Uncheck the checkbox
---@param line string
---@return string
M.uncheck_box = function(line) return (line:gsub("([" .. list_marks .. "]%s)%[([" .. box_states .. "])%]", "%1" .. M.empty_box(), 1)) end

---Add checkbox to line
---@param line string
---@return string
M.create_box = function(line) return (line:gsub("^([%s>]*)(.*)", "%1" .. string.format("%s %s ", list_mark, M.empty_box()) .. "%2")) end

---Remove checkbox from line
---@param line string
---@return string
M.remove_box = function(line) return line:gsub("([%s>]*)[" .. list_marks .. "]%s%[([" .. box_states .. "])%]%s", "%1", 1) end

---Get next box state in cycle
---@param line string
---@return string|"end"
local cycled_box_state = function(line)
  local _, _, matched = M.matched_box(line)
  for i, state in ipairs(box_table) do
    if matched == state and i < #box_table then return box_table[i + 1] end
    if matched == box_table[#box_table] then return "end" end -- At the last element
  end
  return box_table[1]
end

---Cycle box state
---@param line string
---@param list_before_box boolean
---@return string
M.cycle_box = function(line, list_before_box)
  local state = cycled_box_state(line)
  if state == "end" then
    if list_before_box then
      -- Need to call box_to_list from converters
      -- This will be handled by the caller
      return "convert_to_list"
    else
      return M.uncheck_box(line)
    end
  end
  return (line:gsub("(%[)([" .. box_states .. "])(%])", "%1" .. state .. "%3", 1))
end

--------- Ordered Checkboxes ---------

---Match ordered checkbox in line
---@param line string
---@return string|nil, string|nil, string|nil whitespace, number, state
M.matched_obox = function(line) return line:match("^([%s>]*)(%d+)%.%s%[([" .. box_states .. "])%]%s") end

---Check if line has an ordered checkbox
---@param line string
---@return boolean
M.has_obox = function(line) return M.matched_obox(line) ~= nil end

---Check the ordered checkbox
---@param line string
---@return string
M.check_obox = function(line) return (line:gsub("(%d+%.%s)%[ %]", "%1[" .. checked_state .. "]", 1)) end

---Uncheck the ordered checkbox
---@param line string
---@return string
M.uncheck_obox = function(line) return (line:gsub("(%d+%.%s)%[([" .. box_states .. "])%]", "%1" .. M.empty_box(), 1)) end

---Add ordered checkbox to line
---@param line string
---@return string
M.create_obox = function(line) return (line:gsub("^([%s>]*)(.*)", "%11. " .. M.empty_box() .. " %2")) end

---Remove ordered checkbox from line
---@param line string
---@return string
M.remove_obox = function(line) return line:gsub("([%s>]*)%d+%.%s%[([" .. box_states .. "])%]%s", "%1", 1) end

---Get next obox state in cycle
---@param line string
---@return string|"end"
local cycled_obox_state = function(line)
  local _, _, matched = M.matched_obox(line)
  for i, state in ipairs(box_table) do
    if matched == state and i < #box_table then return box_table[i + 1] end
    if matched == box_table[#box_table] then return "end" end -- At the last element
  end
  return box_table[1]
end

---Cycle ordered box state
---@param line string
---@param list_before_box boolean
---@return string
M.cycle_obox = function(line, list_before_box)
  local state = cycled_obox_state(line)
  if state == "end" then
    if list_before_box then
      -- Need to call obox_to_olist from converters
      -- This will be handled by the caller
      return "convert_to_olist"
    else
      return M.uncheck_obox(line)
    end
  end
  return (line:gsub("(%[)([" .. box_states .. "])(%])", "%1" .. state .. "%3", 1))
end

return M
