local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local toggle = require("markdown-toggle.features.toggle")
local heading = require("markdown-toggle.marks.heading")
local list = require("markdown-toggle.marks.list")
local checkbox = require("markdown-toggle.marks.checkbox")
local converters = require("markdown-toggle.features.converters")

-- Test suite
local T = new_set({
  hooks = {
    pre_case = function()
      -- Set up default configuration
      local config = {
        cycle_list_table = false,
        cycle_box_table = false,
        list_before_box = false,
        obox_as_olist = false,
        enable_olist_recalc = false,
        enable_blankline_skip = true,
        enable_heading_skip = true,
        enable_unmarked_only = false,
      }
      toggle.set_config(config)

      -- Set up marks modules (quote and olist don't have set_config)
      heading.set_config('#', { '#', '##', '###', '####', '#####', '######' })
      list.set_config('%-+%*', '-', { '-', '+', '*' })
      checkbox.set_config('%-+%*', ' xX~>-', '-', 'x', { 'x', 'X', '~', '>', '-' })
      converters.set_config('*+-', ' xX~>-', '-')
    end,
  },
})

-- ========== Quote Toggle ==========

T["get_toggled_line() - quote mode"] = new_set()

T["get_toggled_line() - quote mode"]["toggles quote on/off"] = function()
  eq(toggle.get_toggled_line("quote", "content"), "> content")
  eq(toggle.get_toggled_line("quote", "> content"), "content")
  eq(toggle.get_toggled_line("quote", ">> content"), "> content")
end

T["get_toggled_line() - quote mode"]["handles empty lines"] = function()
  eq(toggle.get_toggled_line("quote", ""), "> ")
  eq(toggle.get_toggled_line("quote", "> "), "")
end

-- ========== Heading Toggle/Cycle ==========

T["get_toggled_line() - heading mode"] = new_set()

T["get_toggled_line() - heading mode"]["cycles heading levels"] = function()
  eq(toggle.get_toggled_line("heading", "content"), "# content")
  eq(toggle.get_toggled_line("heading", "# content"), "## content")
  eq(toggle.get_toggled_line("heading", "## content"), "### content")
  eq(toggle.get_toggled_line("heading", "###### content"), "# content")
end

T["get_toggled_line() - heading_toggle mode"] = new_set()

T["get_toggled_line() - heading_toggle mode"]["toggles heading on/off"] = function()
  eq(toggle.get_toggled_line("heading_toggle", "content"), "# content")
  eq(toggle.get_toggled_line("heading_toggle", "# content"), "content")
  eq(toggle.get_toggled_line("heading_toggle", "## content"), "content")
end

-- ========== List Toggle/Cycle ==========

T["get_toggled_line() - list mode"] = new_set()

T["get_toggled_line() - list mode"]["creates list from plain text"] = function()
  eq(toggle.get_toggled_line("list", "content"), "- content")
end

T["get_toggled_line() - list mode"]["removes list when cycle_list_table=false"] = function()
  eq(toggle.get_toggled_line("list", "- content"), "content")
end

T["get_toggled_line() - list mode"]["cycles list when cycle_list_table=true"] = function()
  local config = {
    cycle_list_table = true,
    cycle_box_table = false,
    list_before_box = false,
    obox_as_olist = false,
    enable_olist_recalc = false,
  }
  toggle.set_config(config)

  eq(toggle.get_toggled_line("list", "- content"), "* content")
  eq(toggle.get_toggled_line("list", "* content"), "+ content")
  eq(toggle.get_toggled_line("list", "+ content"), "- content")
end

T["get_toggled_line() - list mode"]["converts checkbox to list"] = function()
  eq(toggle.get_toggled_line("list", "- [ ] content"), "- content")
  eq(toggle.get_toggled_line("list", "- [x] content"), "- content")
end

T["get_toggled_line() - list mode"]["converts olist to list"] = function()
  eq(toggle.get_toggled_line("list", "1. content"), "- content")
  eq(toggle.get_toggled_line("list", "10. content"), "- content")
end

T["get_toggled_line() - list_cycle mode"] = new_set()

T["get_toggled_line() - list_cycle mode"]["always cycles list marks"] = function()
  eq(toggle.get_toggled_line("list_cycle", "- content"), "* content")
  eq(toggle.get_toggled_line("list_cycle", "* content"), "+ content")
  eq(toggle.get_toggled_line("list_cycle", "+ content"), "- content")
end

-- ========== Ordered List Toggle ==========

T["get_toggled_line() - olist mode"] = new_set()

T["get_toggled_line() - olist mode"]["creates olist from plain text"] = function()
  eq(toggle.get_toggled_line("olist", "content"), "1. content")
end

T["get_toggled_line() - olist mode"]["removes olist"] = function()
  eq(toggle.get_toggled_line("olist", "1. content"), "content")
  eq(toggle.get_toggled_line("olist", "10. content"), "content")
end

T["get_toggled_line() - olist mode"]["converts list to olist"] = function()
  eq(toggle.get_toggled_line("olist", "- content"), "1. content")
  eq(toggle.get_toggled_line("olist", "* content"), "1. content")
end

T["get_toggled_line() - olist mode"]["converts checkbox to olist"] = function()
  eq(toggle.get_toggled_line("olist", "- [ ] content"), "1. content")
  eq(toggle.get_toggled_line("olist", "- [x] content"), "1. content")
end

T["get_toggled_line() - olist mode"]["converts ordered checkbox to olist"] = function()
  eq(toggle.get_toggled_line("olist", "1. [ ] content"), "1. content")
  eq(toggle.get_toggled_line("olist", "2. [x] content"), "2. content")
end

T["get_toggled_line() - olist mode"]["removes obox when obox_as_olist=true"] = function()
  local config = {
    cycle_list_table = false,
    cycle_box_table = false,
    list_before_box = false,
    obox_as_olist = true,
    enable_olist_recalc = false,
  }
  toggle.set_config(config)

  eq(toggle.get_toggled_line("olist", "1. [ ] content"), "1. content")
end

-- ========== Checkbox Toggle/Cycle ==========

T["get_toggled_line() - checkbox mode"] = new_set()

T["get_toggled_line() - checkbox mode"]["creates checkbox from plain text"] = function()
  eq(toggle.get_toggled_line("checkbox", "content"), "- [ ] content")
end

T["get_toggled_line() - checkbox mode"]["checks unchecked box"] = function()
  eq(toggle.get_toggled_line("checkbox", "- [ ] content"), "- [x] content")
end

T["get_toggled_line() - checkbox mode"]["unchecks checked box when cycle_box_table=false"] = function()
  eq(toggle.get_toggled_line("checkbox", "- [x] content"), "- [ ] content")
end

T["get_toggled_line() - checkbox mode"]["cycles box states when cycle_box_table=true"] = function()
  local config = {
    cycle_list_table = false,
    cycle_box_table = true,
    list_before_box = false,
    obox_as_olist = false,
    enable_olist_recalc = false,
  }
  toggle.set_config(config)

  eq(toggle.get_toggled_line("checkbox", "- [ ] content"), "- [x] content")
  eq(toggle.get_toggled_line("checkbox", "- [x] content"), "- [~] content")
  eq(toggle.get_toggled_line("checkbox", "- [~] content"), "- [>] content")
  eq(toggle.get_toggled_line("checkbox", "- [>] content"), "- [ ] content")
end

T["get_toggled_line() - checkbox mode"]["converts to list when list_before_box=true"] = function()
  local config = {
    cycle_list_table = false,
    cycle_box_table = false,
    list_before_box = true,
    obox_as_olist = false,
    enable_olist_recalc = false,
  }
  toggle.set_config(config)

  eq(toggle.get_toggled_line("checkbox", "- [x] content"), "- content")
  eq(toggle.get_toggled_line("checkbox", "1. [x] content"), "1. content")
end

T["get_toggled_line() - checkbox mode"]["converts list to checkbox"] = function()
  eq(toggle.get_toggled_line("checkbox", "- content"), "- [ ] content")
  eq(toggle.get_toggled_line("checkbox", "* content"), "- [ ] content")
end

T["get_toggled_line() - checkbox mode"]["converts olist to ordered checkbox"] = function()
  eq(toggle.get_toggled_line("checkbox", "1. content"), "1. [ ] content")
  eq(toggle.get_toggled_line("checkbox", "10. content"), "10. [ ] content")
end

T["get_toggled_line() - checkbox mode"]["creates list first when list_before_box=true"] = function()
  local config = {
    cycle_list_table = false,
    cycle_box_table = false,
    list_before_box = true,
    obox_as_olist = false,
    enable_olist_recalc = false,
  }
  toggle.set_config(config)

  eq(toggle.get_toggled_line("checkbox", "content"), "- content")
end

T["get_toggled_line() - checkbox_cycle mode"] = new_set()

T["get_toggled_line() - checkbox_cycle mode"]["cycles through box states"] = function()
  eq(toggle.get_toggled_line("checkbox_cycle", "- [ ] content"), "- [x] content")
  eq(toggle.get_toggled_line("checkbox_cycle", "- [x] content"), "- [~] content")
  eq(toggle.get_toggled_line("checkbox_cycle", "- [~] content"), "- [>] content")
  eq(toggle.get_toggled_line("checkbox_cycle", "- [>] content"), "- [ ] content")
end

T["get_toggled_line() - checkbox_cycle mode"]["converts to list when list_before_box=true at end of cycle"] = function()
  local config = {
    cycle_list_table = false,
    cycle_box_table = false,
    list_before_box = true,
    obox_as_olist = false,
    enable_olist_recalc = false,
  }
  toggle.set_config(config)

  eq(toggle.get_toggled_line("checkbox_cycle", "- [>] content"), "- content")
end

-- ========== Quote Preservation ==========

T["get_toggled_line() - quote preservation"] = new_set()

T["get_toggled_line() - quote preservation"]["preserves quote when toggling list"] = function()
  eq(toggle.get_toggled_line("list", "> content"), "> - content")
  eq(toggle.get_toggled_line("list", "> - content"), "> content")
end

T["get_toggled_line() - quote preservation"]["preserves quote when toggling olist"] = function()
  eq(toggle.get_toggled_line("olist", "> content"), "> 1. content")
  eq(toggle.get_toggled_line("olist", "> 1. content"), "> content")
end

T["get_toggled_line() - quote preservation"]["preserves quote when toggling checkbox"] = function()
  eq(toggle.get_toggled_line("checkbox", "> content"), "> - [ ] content")
  eq(toggle.get_toggled_line("checkbox", "> - [ ] content"), "> - [x] content")
end

T["get_toggled_line() - quote preservation"]["preserves quote when toggling heading"] = function()
  eq(toggle.get_toggled_line("heading", "> content"), "> # content")
  eq(toggle.get_toggled_line("heading", "> # content"), "> ## content")
end

T["get_toggled_line() - quote preservation"]["preserves nested quotes"] = function()
  eq(toggle.get_toggled_line("list", ">> content"), ">> - content")
  eq(toggle.get_toggled_line("heading", ">>> content"), ">>> # content")
end

T["get_toggled_line() - quote preservation"]["preserves whitespace before quote"] = function()
  eq(toggle.get_toggled_line("list", "  > content"), "  > - content")
  eq(toggle.get_toggled_line("olist", "    > content"), "    > 1. content")
end

return T
