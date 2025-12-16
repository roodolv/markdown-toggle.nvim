local M = {}

-- Module-level config cache (initialized by set_config)
local heading_mark = "#"
local heading_table = { "#", "##", "###", "####", "#####" }

---Set heading configuration
---@param mark string Default heading mark
---@param table string[] Heading marks table
M.set_config = function(mark, table)
  heading_mark = mark
  heading_table = table
end

---Match heading mark in line
---@param line string
---@return string|nil
local matched_heading = function(line) return line:match("^[%s>]*(#+)%s") end

---Check if line has a heading mark
---@param line string
---@return boolean
M.has_heading = function(line) return matched_heading(line) ~= nil end

---Add heading mark to line
---@param line string
---@return string
M.create_heading = function(line) return (line:gsub("^([%s>]*)(.*)$", "%1" .. heading_mark .. " %2")) end

---Remove heading mark from line
---@param line string
---@return string
M.remove_heading = function(line) return line:gsub("#+%s", "", 1) end

---Get next heading mark in cycle
---@param line string
---@return string|"end"
local cycled_heading_mark = function(line)
  local matched = matched_heading(line)
  for i, heading in ipairs(heading_table) do
    if matched == heading and i < #heading_table then return heading_table[i + 1] end
    if matched == heading_table[#heading_table] then return "end" end -- At the last element
  end
  return heading_table[1]
end

---Cycle heading mark
---@param line string
---@return string
M.cycle_heading = function(line)
  local mark = cycled_heading_mark(line)
  if mark == "end" then return M.remove_heading(line) end
  return (line:gsub("#+", mark, 1))
end

return M
