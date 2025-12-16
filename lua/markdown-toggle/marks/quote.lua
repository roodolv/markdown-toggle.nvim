local M = {}

---Check if line has a quote mark
---@param line string
---@return boolean
M.has_quote = function(line) return line:match("^%s*>") ~= nil end

---Add quote mark to line
---@param line string
---@return string
M.create_quote = function(line) return (line:gsub("^(.*)$", "> %1")) end

---Remove one level of quote mark from line
---@param line string
---@return string
M.remove_quote = function(line)
  if line:match("^%s*>%s") then
    -- Pattern: "> content" -> "content"
    return line:gsub("^(%s*)>%s", "%1", 1)
  elseif line:match("^%s*>") then
    -- Pattern: ">content" or ">>content" -> remove first >
    return line:gsub("^(%s*)>", "%1", 1)
  end
  return line
end

---Extract quote marks from the beginning of line
---@param line string
---@return string
M.extract_quote_marks = function(line)
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

---Separate quote marks from line body
---@param line string
---@return {whitespace: string, mark: string, body: string}
M.separate_quote = function(line)
  local quote_marks = M.extract_quote_marks(line)
  if quote_marks == "" then return { whitespace = "", mark = "", body = line } end

  local body = line:sub(#quote_marks + 1)
  return { whitespace = "", mark = quote_marks, body = body }
end

return M
