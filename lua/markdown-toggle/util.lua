local M = {}

M.get_vline_position = function()
  local start_line, end_line = vim.fn.getpos("v")[2], vim.fn.getpos(".")[2]
  if end_line < start_line then
    start_line, end_line = end_line, start_line
  end
  return start_line - 1, end_line
end

M.get_eol = function()
  local eol = vim.bo.fileformat
  if eol == "dos" then
    -- return "\r\n"
    return "\r" -- for autolist feature
  elseif eol == "mac" then
    return "\r"
  else
    return "\n"
  end
end

return M
