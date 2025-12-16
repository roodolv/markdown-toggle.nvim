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

-- NOTE: How to use:
-- local timestamp = util.echo_exec_time() -- Start
-- util.echo_exec_time(timestamp) -- End

---@param timestamp integer|nil
M.echo_exec_time = function(timestamp)
  if not timestamp then
    return vim.loop.hrtime() -- Return start timestamp(nanoseconds)
  end

  local elapsed_ns = vim.loop.hrtime() - timestamp
  vim.api.nvim_echo({ { ("Elapsed: %.6f ms"):format(elapsed_ns / 1e6), "None" } }, true, {})
end

return M
