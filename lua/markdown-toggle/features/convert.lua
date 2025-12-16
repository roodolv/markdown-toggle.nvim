local M = {}

-- Module-level config cache (initialized by set_config)
local list_marks = "" -- Regex pattern for list marks
local box_states = " " -- Regex pattern for box states
local list_mark = "-" -- Default list mark

---Set converter configuration
---@param marks_pattern string Regex pattern for list marks
---@param states_pattern string Regex pattern for box states
---@param default_mark string Default list mark
M.set_config = function(marks_pattern, states_pattern, default_mark)
  list_marks = marks_pattern
  box_states = states_pattern
  list_mark = default_mark
end

---Get empty box representation (helper)
---@return string
local empty_box = function() return "[ ]" end

--------- Converters: Checkbox -> List/Olist ---------

---Convert checkbox to list
---@param line string
---@return string
M.box_to_list = function(line)
  return (line:gsub("^([%s>]*)[" .. list_marks .. "]%s%[[" .. box_states .. "]%]%s(.*)", "%1" .. list_mark .. " %2"))
end

---Convert checkbox to ordered list
---@param line string
---@return string
M.box_to_olist = function(line) return (line:gsub("^([%s>]*)[" .. list_marks .. "]%s%[[" .. box_states .. "]%]%s(.*)", "%11. %2")) end

---Convert ordered checkbox to ordered list
---@param line string
---@return string
M.obox_to_olist = function(line) return (line:gsub("^([%s>]*)(%d+%.%s)%[[" .. box_states .. "]%]%s(.*)", "%1%2%3")) end

--------- Converters: List -> Olist/Checkbox ---------

---Convert list to ordered list
---@param line string
---@return string
M.list_to_olist = function(line) return (line:gsub("^([%s>]*)[" .. list_marks .. "]%s(.*)", "%11. %2")) end

---Convert list to checkbox
---@param line string
---@return string
M.list_to_box = function(line)
  return (line:gsub("^([%s>]*)[" .. list_marks .. "]%s(.*)", "%1" .. string.format("%s %s ", list_mark, empty_box()) .. "%2"))
end

--------- Converters: Olist -> List/Checkbox ---------

---Convert ordered list to list
---@param line string
---@return string
M.olist_to_list = function(line) return (line:gsub("^([%s>]*)%d+%.%s(.*)", "%1" .. list_mark .. " %2")) end

---Convert ordered list to checkbox
---@param line string
---@return string
M.olist_to_box = function(line)
  return (line:gsub("^([%s>]*)%d+%.%s(.*)", "%1" .. string.format("%s %s ", list_mark, empty_box()) .. "%2"))
end

---Convert ordered list to ordered checkbox
---@param line string
---@return string
M.olist_to_obox = function(line) return (line:gsub("^([%s>]*)(%d+%.%s)(.*)", "%1%2" .. empty_box() .. " %3")) end

return M
