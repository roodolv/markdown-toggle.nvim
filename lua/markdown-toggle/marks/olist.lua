local M = {}

---Match ordered list mark in line
-- group1(whitespace): spaces or quotes
-- group2(mark): any digit (0-9) before .
-- group3(text): text after digit and .
-- group4(trailing): trailing spaces after the text
---@param line string
---@return string|nil, string|nil, string|nil, string|nil
M.matched_olist = function(line)
  local ws, mark, text, trailing = line:match("^([%s>]*)(%d+)%.%s(.-)(%s*)$")
  -- Only match positive integers (1 or greater)
  if mark and tonumber(mark) >= 1 then return ws, mark, text, trailing end
  return nil, nil, nil, nil
end

---Check if line has an ordered list mark
---@param line string
---@return boolean
M.has_olist = function(line) return M.matched_olist(line) ~= nil end

---Add ordered list mark to line
---@param line string
---@return string
M.create_olist = function(line) return (line:gsub("^([%s>]*)(.*)", "%11. %2")) end

---Remove ordered list mark from line
---@param line string
---@return string
M.remove_olist = function(line) return line:gsub("([%s>]*)%d+%.%s", "%1", 1) end

---Increment ordered list number
---@param olist_mark string "1", "2", "3", ...
---@return string
M.increment_olist = function(olist_mark)
  local num = tonumber(olist_mark)
  return string.format("%d. ", num + 1)
end

---Decrement ordered list number
---@param olist_mark string "1", "2", "3", ...
---@return string
M.decrement_olist = function(olist_mark)
  local num = tonumber(olist_mark)
  local result = math.max(1, num - 1) -- Clip at minimum value 1
  return string.format("%d. ", result)
end

return M
