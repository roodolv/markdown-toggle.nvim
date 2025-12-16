local M = {}

-- Import dependencies
local quote = require("markdown-toggle.marks.quote")
local checkbox = require("markdown-toggle.marks.checkbox")
local list = require("markdown-toggle.marks.list")
local olist = require("markdown-toggle.marks.olist")
local olist_recalc = require("markdown-toggle.features.olist_recalc")
local line_state = require("markdown-toggle.shared.line_state")
local util = require("markdown-toggle.shared.util")

-- Module-level config cache
local current_config = {}

---Set autolist configuration
---@param config MarkdownToggleConfig
M.set_config = function(config) current_config = config end

---Clear line and insert
---@param cin string character input
---@param is_blank boolean whether the line is blank
--stylua: ignore
local clear_and_insert = function(cin, is_blank) -- TODO: Issue #39 (D)
  local cursor_line_num = vim.api.nvim_win_get_cursor(0)[1]

  if cin == "o" then -- TODO: Issue #39 (D)
    -- Clear current line and create new line below
    vim.api.nvim_set_current_line("")

    if current_config.clear_and_newline then
      vim.api.nvim_buf_set_lines(0, cursor_line_num, cursor_line_num, false, { "" })
      vim.api.nvim_win_set_cursor(0, { cursor_line_num + 1, 0 })
    else
      vim.api.nvim_win_set_cursor(0, { cursor_line_num, 0 })
    end

    vim.cmd("startinsert")
  elseif cin == "O" then -- TODO: Issue #39 (D)
    -- Clear current line and create new line above
    vim.api.nvim_set_current_line("")

    if current_config.clear_and_newline then
      vim.api.nvim_buf_set_lines(0, cursor_line_num - 1, cursor_line_num - 1, false, { "" })
    end
    vim.api.nvim_win_set_cursor(0, { cursor_line_num, 0 })

    vim.cmd("startinsert")
  elseif cin == util.get_eol() then -- TODO: Issue #39 (D)
    vim.api.nvim_set_current_line("")
    if is_blank then
      vim.api.nvim_feedkeys(cin, "n", false) -- TODO: Issue #39 (D)
    else
      vim.api.nvim_win_set_cursor(0, { cursor_line_num, 0 })
      vim.cmd("startinsert")
    end
  end
end

---Autolist functionality
---@param cin string character input
M.autolist = function(cin) -- TODO: Issue #39 (D)
  local line = vim.api.nvim_get_current_line()

  -- First, separate quote marks from the entire line (preserving leading spaces)
  local sep_quote = quote.separate_quote(line)

  -- New beginning-of-line
  local new_bol = ""

  -- If a quote mark exists, combine the quote mark with the bol spaces
  if sep_quote.mark and sep_quote.mark ~= "" then new_bol = new_bol .. sep_quote.mark end

  local _, box_mark, box_state, box_text, _ = checkbox.matched_box(sep_quote.body)
  local box = box_state ~= nil and string.format("%s [%s] ", box_mark, box_state) or nil
  local _, list_mark, list_text, _ = list.matched_list(sep_quote.body)
  local _, olist_mark, olist_text, _ = olist.matched_olist(sep_quote.body)

  -- stylua: ignore
  if box ~= nil then
    if not current_config.enable_auto_samestate then
      box = string.format("%s %s ", box_mark, checkbox.empty_box())
    end

    if box_text == "" then
      clear_and_insert(cin, line_state.is_blankline(line))
    else
      vim.api.nvim_feedkeys(cin .. new_bol .. box, "n", false) -- TODO: Issue #39 (D)
    end
  elseif list_mark ~= nil then
    list_mark = list_mark .. " "
    if list_text == "" then
      clear_and_insert(cin, line_state.is_blankline(line))
    else
      vim.api.nvim_feedkeys(cin .. new_bol .. list_mark, "n", false) -- TODO: Issue #39 (D)
    end
  elseif olist_mark ~= nil then
    -- TODO: Issue #39 (D)
    olist_mark = (cin == "O") and olist.decrement_olist(olist_mark) or olist.increment_olist(olist_mark)
    if olist_text == "" then
      clear_and_insert(cin, line_state.is_blankline(line))
    else
      vim.api.nvim_feedkeys(cin .. new_bol .. olist_mark, "n", false) -- TODO: Issue #39 (D)
    end

    -- Trigger recalculation after autolist creates olist (delayed)
    if current_config.enable_olist_recalc then
      vim.schedule(function()
        olist_recalc.trigger_olist_recalc(current_config.enable_olist_recalc)
      end)
    end
  elseif sep_quote.mark ~= "" then
    -- Check if quote body is empty (only whitespace)
    local quote_text = sep_quote.body:match("^(.-)%s*$")
    if quote_text == "" then
      clear_and_insert(cin, line_state.is_blankline(line))
    else
      vim.api.nvim_feedkeys(cin .. new_bol, "n", false) -- TODO: Issue #39 (D)
    end
  else
    -- clear_and_insert(cin, line_state.is_blankline(line))
    vim.api.nvim_feedkeys(cin, "n", false) -- TODO: Issue #39 (D)
  end
end

return M
