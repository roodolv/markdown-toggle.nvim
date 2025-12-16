local M = {}

-- Import dependencies
local quote = require("markdown-toggle.marks.quote")
local heading = require("markdown-toggle.marks.heading")
local codeblock = require("markdown-toggle.marks.codeblock")
local list = require("markdown-toggle.marks.list")
local olist = require("markdown-toggle.marks.olist")
local checkbox = require("markdown-toggle.marks.checkbox")

---Check if recalculation should continue for this line
---@param line string
---@return boolean
local should_continue_recalc = function(line)
  -- Heading or code block lines stop recalculation immediately
  if heading.has_heading(line) or codeblock.has_codeblock(line) then return false end

  -- Quote lines: continue only if they contain list/olist/checkbox/obox marks
  if quote.has_quote(line) then
    local sep_quote = quote.separate_quote(line)
    local body = sep_quote.body

    -- Continue if quote contains any list marks (short-circuit evaluation)
    if list.has_list(body) or olist.has_olist(body) or checkbox.has_box(body) or checkbox.has_obox(body) then return true end
    -- Stop if quote has no internal marks
    return false
  end

  -- All other lines (text, blank, list, checkbox, etc.) continue recalculation
  return true
end

---Find the range of lines that should be recalculated together
---@param cursor_line_num integer
---@return integer, integer
local find_olist_recalc_range = function(cursor_line_num)
  local total_lines = vim.api.nvim_buf_line_count(0)

  -- Find upward boundary (stop condition or buffer start)
  local start_line = cursor_line_num
  for line_num = cursor_line_num - 1, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
    if not should_continue_recalc(line) then
      start_line = line_num + 1 -- Start after the stop condition
      break
    end
    start_line = line_num
  end

  -- Find downward boundary (stop condition or buffer end)
  local end_line = cursor_line_num
  for line_num = cursor_line_num + 1, total_lines do
    local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
    if not should_continue_recalc(line) then
      end_line = line_num - 1 -- End before the stop condition
      break
    end
    end_line = line_num
  end

  return start_line, end_line
end

---Get indentation signature for olist comparison (includes quote context)
---@param line string
---@return string
local get_olist_indent_signature = function(line)
  if quote.has_quote(line) then
    local sep_quote = quote.separate_quote(line)
    -- For quoted olist, return a unique signature that includes quote context
    if olist.has_olist(sep_quote.body) or checkbox.has_obox(sep_quote.body) then
      local inner_indent = sep_quote.body:match("^(%s*)")
      return "quoted:" .. inner_indent -- Unique signature for quoted olist
    end
  end
  -- For regular olist, use just the indentation
  if olist.has_olist(line) or checkbox.has_obox(line) then return "regular:" .. line:match("^(%s*)") end
  return ""
end

---Recalculate ordered list numbers in the specified range with same context and indentation
---@param start_line integer
---@param end_line integer
local recalculate_olist_in_range = function(start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local cursor_line_num = vim.api.nvim_win_get_cursor(0)[1]
  local cursor_line = vim.api.nvim_buf_get_lines(0, cursor_line_num - 1, cursor_line_num, false)[1]

  -- Get the indentation signature of the cursor line or target olist line
  local target_signature = ""
  if olist.has_olist(cursor_line) or checkbox.has_obox(cursor_line) then
    target_signature = get_olist_indent_signature(cursor_line)
  else
    -- Find the first olist line in range to determine target signature
    for _, line in ipairs(lines) do
      if olist.has_olist(line) or checkbox.has_obox(line) then
        target_signature = get_olist_indent_signature(line)
        break
      end
    end
  end

  -- If no target signature found, don't recalculate
  if target_signature == "" then return end

  local olist_counter = 1

  for i, line in ipairs(lines) do
    if olist.has_olist(line) or checkbox.has_obox(line) then
      local line_signature = get_olist_indent_signature(line)

      -- Only recalculate lines with the same signature (context + indentation)
      if line_signature == target_signature then
        local line_num = start_line + i - 1
        local new_line
        if quote.has_quote(line) then
          -- For quoted olist, preserve quote marks and update number
          local sep_quote = quote.separate_quote(line)
          local updated_body = sep_quote.body:gsub("^(%s*)%d+(%.%s)", "%1" .. olist_counter .. "%2")
          new_line = sep_quote.mark .. updated_body
        else
          -- For regular olist, update number directly
          new_line = line:gsub("^(%s*)%d+(%.%s)", "%1" .. olist_counter .. "%2")
        end
        vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { new_line })
        olist_counter = olist_counter + 1
      end
    end
  end
end

---Trigger ordered list recalculation from cursor position
---@param enable_olist_recalc boolean
M.trigger_olist_recalc = function(enable_olist_recalc)
  if not enable_olist_recalc then return end

  local cursor_line_num = vim.api.nvim_win_get_cursor(0)[1]
  local start_line, end_line = find_olist_recalc_range(cursor_line_num)

  -- Only recalculate if there are olist lines in the range
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local has_olist_in_range = false
  for _, line in ipairs(lines) do
    if olist.has_olist(line) or checkbox.has_obox(line) then
      has_olist_in_range = true
      break
    end
  end

  if has_olist_in_range then recalculate_olist_in_range(start_line, end_line) end
end

return M
