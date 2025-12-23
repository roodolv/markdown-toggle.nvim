local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local olist_recalc = require("markdown-toggle.features.olist_recalc")
local heading = require("markdown-toggle.marks.heading")
local list = require("markdown-toggle.marks.list")
local checkbox = require("markdown-toggle.marks.checkbox")

-- Integration test suite for olist_recalc
local T = new_set({
  hooks = {
    pre_case = function()
      -- Set up test buffer
      vim.cmd('enew')
      vim.bo.filetype = 'markdown'

      -- Set up marks modules
      heading.set_config('#', { '#', '##', '###' })
      list.set_config('%-+%*', '-', { '-', '+', '*' })
      checkbox.set_config('%-+%*', ' x~>', '-', 'x', { 'x', '~', '>' })
    end,
    post_case = function()
      -- Clean up buffer
      vim.cmd('bwipeout!')
    end,
  },
})

-- ========== Helper Functions ==========

local set_lines = function(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local get_lines = function()
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local set_cursor = function(line, col)
  vim.api.nvim_win_set_cursor(0, { line, col or 0 })
end

-- ========== Basic Recalculation ==========

T["trigger_olist_recalc()"] = new_set()

T["trigger_olist_recalc()"]["recalculates simple list"] = function()
  set_lines({
    "1. first",
    "1. second",
    "1. third",
  })
  set_cursor(2, 0)

  olist_recalc.trigger_olist_recalc("all")

  local result = get_lines()
  eq(result[1], "1. first")
  eq(result[2], "2. second")
  eq(result[3], "3. third")
end

T["trigger_olist_recalc()"]["handles out-of-order numbers"] = function()
  set_lines({
    "5. first",
    "3. second",
    "1. third",
  })
  set_cursor(2, 0)

  olist_recalc.trigger_olist_recalc("all")

  local result = get_lines()
  eq(result[1], "1. first")
  eq(result[2], "2. second")
  eq(result[3], "3. third")
end

-- ========== Stop Conditions ==========

T["trigger_olist_recalc()"]["stop conditions"] = new_set()

T["trigger_olist_recalc()"]["stop conditions"]["stops at heading"] = function()
  set_lines({
    "1. first",
    "# Heading",
    "1. after heading",
  })
  set_cursor(1, 0)

  olist_recalc.trigger_olist_recalc("all")

  local result = get_lines()
  eq(result[1], "1. first")
  eq(result[2], "# Heading")
  eq(result[3], "1. after heading")  -- Should not be recalculated
end

T["trigger_olist_recalc()"]["stop conditions"]["stops at code block"] = function()
  set_lines({
    "1. first",
    "```",
    "code",
    "```",
    "1. after code",
  })
  set_cursor(1, 0)

  olist_recalc.trigger_olist_recalc("all")

  local result = get_lines()
  eq(result[1], "1. first")
  eq(result[5], "1. after code")  -- Should not be recalculated
end

-- ========== Indentation ==========

T["trigger_olist_recalc()"]["indentation"] = new_set()

T["trigger_olist_recalc()"]["indentation"]["recalculates same indent level only"] = function()
  set_lines({
    "1. first",
    "  1. nested first",
    "  1. nested second",
    "1. second",
  })
  set_cursor(2, 0)  -- Cursor on nested item

  olist_recalc.trigger_olist_recalc("all")

  local result = get_lines()
  -- Only nested items (same indent as cursor) are recalculated
  eq(result[1], "1. first")
  eq(result[2], "  1. nested first")
  eq(result[3], "  2. nested second")
  eq(result[4], "1. second")  -- Different indent, not recalculated
end

-- ========== Quote Context ==========

T["trigger_olist_recalc()"]["quote context"] = new_set()

T["trigger_olist_recalc()"]["quote context"]["recalculates in quotes"] = function()
  set_lines({
    "> 1. first",
    "> 1. second",
    "> 1. third",
  })
  set_cursor(2, 0)

  olist_recalc.trigger_olist_recalc("all")

  local result = get_lines()
  eq(result[1], "> 1. first")
  eq(result[2], "> 2. second")
  eq(result[3], "> 3. third")
end

T["trigger_olist_recalc()"]["quote context"]["stops at quote without list"] = function()
  set_lines({
    "1. first",
    "> plain quote",
    "1. after quote",
  })
  set_cursor(1, 0)

  olist_recalc.trigger_olist_recalc("all")

  local result = get_lines()
  eq(result[1], "1. first")
  eq(result[2], "> plain quote")
  eq(result[3], "1. after quote")  -- Should not be recalculated
end

-- ========== Mixed Content ==========

T["trigger_olist_recalc()"]["mixed content"] = new_set()

T["trigger_olist_recalc()"]["mixed content"]["handles bullet lists between olists"] = function()
  set_lines({
    "1. first",
    "- bullet",
    "1. second",
  })
  set_cursor(1, 0)

  olist_recalc.trigger_olist_recalc("all")

  local result = get_lines()
  eq(result[1], "1. first")
  eq(result[2], "- bullet")
  eq(result[3], "2. second")
end

T["trigger_olist_recalc()"]["mixed content"]["handles blank lines"] = function()
  set_lines({
    "1. first",
    "",
    "1. second",
  })
  set_cursor(1, 0)

  olist_recalc.trigger_olist_recalc("all")

  local result = get_lines()
  eq(result[1], "1. first")
  eq(result[2], "")
  eq(result[3], "2. second")
end

return T
