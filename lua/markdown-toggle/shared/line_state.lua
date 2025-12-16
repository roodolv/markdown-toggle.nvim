local M = {}

-- Import mark modules
local quote = require("markdown-toggle.marks.quote")
local heading = require("markdown-toggle.marks.heading")
local list = require("markdown-toggle.marks.list")
local olist = require("markdown-toggle.marks.olist")
local checkbox = require("markdown-toggle.marks.checkbox")

---Match beginning-of-line whitespace
---@param line string
---@return string|nil
M.matched_bol = function(line) return line:match("^(%s*).*$") end

---Match body (content after leading whitespace)
---@param line string
---@return string|nil
M.matched_body = function(line) return line:match("^%s*(.*)$") end

---Match both beginning-of-line whitespace and body
---@param line string
---@return string|nil, string|nil
M.matched_bol_body = function(line) return line:match("^(%s*)(.*)$") end

---Check if line is blank
---@param line string
---@return boolean
M.is_blankline = function(line) return line:match("^$") ~= nil end

---Check if should skip blank line (depends on config)
---@param line string
---@param enable_blankline_skip boolean
---@return boolean
M.skip_blankline = function(line, enable_blankline_skip) return enable_blankline_skip and M.is_blankline(line) end

---Check if should skip heading (depends on config)
---@param line string
---@param enable_heading_skip boolean
---@return boolean
M.skip_heading = function(line, enable_heading_skip) return enable_heading_skip and heading.has_heading(line) end

---Check if line has a specific mark type
---@param line string
---@param toggle_mode string
---@param obox_as_olist boolean
---@return boolean
M.has_mark = function(line, toggle_mode, obox_as_olist)
  -- Separate a head-of-line quote mark from the rest(body)
  local body = quote.separate_quote(line).body

  -- Check if already marked
  return toggle_mode == "checkbox" and (checkbox.has_box(body) or checkbox.has_obox(body))
    or toggle_mode == "checkbox_cycle" and (checkbox.has_box(body) or checkbox.has_obox(body))
    or toggle_mode == "list" and list.has_list(body)
    or toggle_mode == "list_cycle" and list.has_list(body)
    or toggle_mode == "olist" and (checkbox.has_obox(body) and obox_as_olist or olist.has_olist(body) and not checkbox.has_obox(body))
    or toggle_mode == "heading" and heading.has_heading(body)
    or toggle_mode == "heading_toggle" and heading.has_heading(body)
end

return M
