local M = {}

-- Module-level config cache (initialized by set_config)
local list_marks = "" -- Regex pattern for list marks
local list_mark = "-" -- Default list mark
local list_table = { "-", "+", "*", "=" }

---Set list configuration
---@param marks_pattern string Regex pattern for list marks
---@param default_mark string Default list mark
---@param table string[] List marks table
M.set_config = function(marks_pattern, default_mark, table)
  list_marks = marks_pattern
  list_mark = default_mark
  list_table = table
end

---Match list mark in line
-- group1(whitespace): spaces or quotes
-- group2(mark): dynamically generated from list_table
-- group3(text): text after -
-- group4(trailing): trailing spaces after the text
---@param line string
---@return string|nil, string|nil, string|nil, string|nil whitespace, mark, text, trailing
M.matched_list = function(line) return line:match("^([%s>]*)([" .. list_marks .. "])%s(.-)(%s*)$") end

---Check if line has a list mark
---@param line string
---@return boolean
M.has_list = function(line) return M.matched_list(line) ~= nil end

---Add list mark to line
---@param line string
---@return string
M.create_list = function(line) return (line:gsub("^([%s>]*)(.*)", "%1" .. list_mark .. " %2")) end

---Remove list mark from line
---@param line string
---@return string
M.remove_list = function(line) return (line:gsub("[" .. list_marks .. "]%s", "", 1)) end

---Get next list mark in cycle
---@param line string
---@return string|"end"
local cycled_list_mark = function(line)
  local _, matched = M.matched_list(line)
  for i, mark in ipairs(list_table) do
    if matched == mark and i < #list_table then return list_table[i + 1] end
    if matched == list_table[#list_table] then return "end" end -- At the last element
  end
  return list_table[1]
end

---Cycle list mark
---@param line string
---@return string
M.cycle_list = function(line)
  local mark = cycled_list_mark(line)
  if mark == "end" then return M.remove_list(line) end
  return (line:gsub("[" .. list_marks .. "]", mark, 1))
end

return M
