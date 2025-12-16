local M = {}

---Match code block delimiter in line
---@param line string
---@return string|nil
M.matched_codeblock = function(line) return line:match("^(```)") end

---Check if line has code block delimiter
---@param line string
---@return boolean
M.has_codeblock = function(line) return M.matched_codeblock(line) ~= nil end

return M
