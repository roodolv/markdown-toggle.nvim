local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local line_state = require("markdown-toggle.shared.line_state")
local heading = require("markdown-toggle.marks.heading")
local list = require("markdown-toggle.marks.list")
local checkbox = require("markdown-toggle.marks.checkbox")

-- Test suite
local T = new_set({
  hooks = {
    pre_case = function()
      -- Set up marks modules for has_mark() tests
      heading.set_config('#', { '#', '##', '###' })
      list.set_config('%-+%*', '-', { '-', '+', '*' })
      checkbox.set_config('%-+%*', ' x~>', '-', 'x', { 'x', '~', '>' })
    end,
  },
})

-- ========== matched_bol() ==========

T["matched_bol()"] = new_set()

T["matched_bol()"]["matches leading whitespace"] = function()
  eq(line_state.matched_bol("  content"), "  ")
  eq(line_state.matched_bol("    content"), "    ")
end

T["matched_bol()"]["returns empty string for no whitespace"] = function()
  eq(line_state.matched_bol("content"), "")
end

T["matched_bol()"]["handles empty line"] = function()
  eq(line_state.matched_bol(""), "")
end

-- ========== matched_body() ==========

T["matched_body()"] = new_set()

T["matched_body()"]["extracts content after whitespace"] = function()
  eq(line_state.matched_body("  content"), "content")
  eq(line_state.matched_body("    - list"), "- list")
end

T["matched_body()"]["returns full line if no whitespace"] = function()
  eq(line_state.matched_body("content"), "content")
end

T["matched_body()"]["handles empty line"] = function()
  eq(line_state.matched_body(""), "")
end

-- ========== matched_bol_body() ==========

T["matched_bol_body()"] = new_set()

T["matched_bol_body()"]["returns both whitespace and body"] = function()
  local bol, body = line_state.matched_bol_body("  content")
  eq(bol, "  ")
  eq(body, "content")
end

T["matched_bol_body()"]["handles no whitespace"] = function()
  local bol, body = line_state.matched_bol_body("content")
  eq(bol, "")
  eq(body, "content")
end

T["matched_bol_body()"]["handles empty line"] = function()
  local bol, body = line_state.matched_bol_body("")
  eq(bol, "")
  eq(body, "")
end

-- ========== is_blankline() ==========

T["is_blankline()"] = new_set()

T["is_blankline()"]["detects empty line"] = function()
  eq(line_state.is_blankline(""), true)
end

T["is_blankline()"]["detects non-empty line"] = function()
  eq(line_state.is_blankline("content"), false)
  eq(line_state.is_blankline("  "), false)
  eq(line_state.is_blankline(" "), false)
end

-- ========== skip_blankline() ==========

T["skip_blankline()"] = new_set()

T["skip_blankline()"]["skips blank when enabled"] = function()
  eq(line_state.skip_blankline("", true), true)
  eq(line_state.skip_blankline("content", true), false)
end

T["skip_blankline()"]["does not skip when disabled"] = function()
  eq(line_state.skip_blankline("", false), false)
  eq(line_state.skip_blankline("content", false), false)
end

-- ========== skip_heading() ==========

T["skip_heading()"] = new_set()

T["skip_heading()"]["skips heading when enabled"] = function()
  eq(line_state.skip_heading("# heading", true), true)
  eq(line_state.skip_heading("## heading", true), true)
  eq(line_state.skip_heading("content", true), false)
end

T["skip_heading()"]["does not skip when disabled"] = function()
  eq(line_state.skip_heading("# heading", false), false)
  eq(line_state.skip_heading("content", false), false)
end

-- ========== has_mark() ==========

T["has_mark()"] = new_set()

T["has_mark()"]["detects checkbox marks"] = function()
  eq(line_state.has_mark("- [ ] content", "checkbox", false), true)
  eq(line_state.has_mark("- [x] content", "checkbox", false), true)
  eq(line_state.has_mark("1. [ ] content", "checkbox", false), true)
  eq(line_state.has_mark("- content", "checkbox", false), false)
end

T["has_mark()"]["detects list marks"] = function()
  eq(line_state.has_mark("- content", "list", false), true)
  eq(line_state.has_mark("+ content", "list", false), true)
  eq(line_state.has_mark("* content", "list", false), true)
  eq(line_state.has_mark("content", "list", false), false)
end

T["has_mark()"]["detects olist marks"] = function()
  eq(line_state.has_mark("1. content", "olist", false), true)
  eq(line_state.has_mark("10. content", "olist", false), true)
  eq(line_state.has_mark("content", "olist", false), false)
end

T["has_mark()"]["detects heading marks"] = function()
  eq(line_state.has_mark("# heading", "heading", false), true)
  eq(line_state.has_mark("## heading", "heading", false), true)
  eq(line_state.has_mark("content", "heading", false), false)
end

T["has_mark()"]["handles obox_as_olist option"] = function()
  -- When obox_as_olist=true, ordered checkbox is treated as olist
  eq(line_state.has_mark("1. [ ] content", "olist", true), true)
  eq(line_state.has_mark("1. [x] content", "olist", true), true)

  -- When obox_as_olist=false, ordered checkbox is NOT treated as olist
  eq(line_state.has_mark("1. [ ] content", "olist", false), false)
  eq(line_state.has_mark("1. [x] content", "olist", false), false)
end

T["has_mark()"]["handles quotes in line"] = function()
  eq(line_state.has_mark("> - content", "list", false), true)
  eq(line_state.has_mark("> # heading", "heading", false), true)
  eq(line_state.has_mark("> content", "list", false), false)
end

return T
