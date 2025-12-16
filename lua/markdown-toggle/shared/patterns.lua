local M = {}

---Generate regex pattern from list table
---@param list_table string[] List of marks
---@return string Regex pattern
M.generate_list_marks = function(list_table)
  local pattern = ""
  for _, mark in ipairs(list_table) do
    pattern = pattern .. "%" .. mark
  end
  return pattern
end

---Generate regex pattern from box states table
---@param box_table string[] List of box states
---@return string Regex pattern
M.generate_box_states = function(box_table)
  local pattern = " "
  for _, state in ipairs(box_table) do
    pattern = pattern .. state
  end
  return pattern
end

return M
