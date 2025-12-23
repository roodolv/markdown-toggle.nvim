local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local converters = require("markdown-toggle.features.converters")

-- Test suite
local T = new_set({
  hooks = {
    pre_case = function()
      -- Set up config for converters (list_marks, box_states, default_list_mark)
      converters.set_config("*+-", " x~>", "-")
    end,
  },
})

-- ========== Configuration ==========

T["set_config()"] = new_set()

T["set_config()"]["sets configuration for converters"] = function()
  converters.set_config("*+", "x", "*")
  -- Test that config is applied by converting a list
  local result = converters.list_to_box("* content")
  eq(result, "* [ ] content")
end

-- ========== Checkbox -> List/Olist ==========

T["box_to_list()"] = new_set()

T["box_to_list()"]["converts checkbox to list"] = function()
  eq(converters.box_to_list("- [ ] content"), "- content")
  eq(converters.box_to_list("- [x] content"), "- content")
  eq(converters.box_to_list("* [~] content"), "- content")
  eq(converters.box_to_list("+ [>] content"), "- content")
end

T["box_to_list()"]["preserves whitespace prefix"] = function()
  eq(converters.box_to_list("  - [ ] content"), "  - content")
  eq(converters.box_to_list("    * [x] content"), "    - content")
end

T["box_to_list()"]["preserves quote prefix"] = function()
  eq(converters.box_to_list("> - [ ] content"), "> - content")
  eq(converters.box_to_list(">> * [x] content"), ">> - content")
end

T["box_to_list()"]["preserves mixed quote and whitespace prefix"] = function()
  eq(converters.box_to_list(">  - [ ] content"), ">  - content")
  eq(converters.box_to_list("  > * [x] content"), "  > - content")
end

T["box_to_olist()"] = new_set()

T["box_to_olist()"]["converts checkbox to ordered list"] = function()
  eq(converters.box_to_olist("- [ ] content"), "1. content")
  eq(converters.box_to_olist("- [x] content"), "1. content")
  eq(converters.box_to_olist("* [~] content"), "1. content")
  eq(converters.box_to_olist("+ [>] content"), "1. content")
end

T["box_to_olist()"]["preserves whitespace prefix"] = function()
  eq(converters.box_to_olist("  - [ ] content"), "  1. content")
  eq(converters.box_to_olist("    * [x] content"), "    1. content")
end

T["box_to_olist()"]["preserves quote prefix"] = function()
  eq(converters.box_to_olist("> - [ ] content"), "> 1. content")
  eq(converters.box_to_olist(">> * [x] content"), ">> 1. content")
end

T["obox_to_olist()"] = new_set()

T["obox_to_olist()"]["converts ordered checkbox to ordered list"] = function()
  eq(converters.obox_to_olist("1. [ ] content"), "1. content")
  eq(converters.obox_to_olist("2. [x] content"), "2. content")
  eq(converters.obox_to_olist("10. [~] content"), "10. content")
  eq(converters.obox_to_olist("99. [>] content"), "99. content")
end

T["obox_to_olist()"]["preserves whitespace prefix"] = function()
  eq(converters.obox_to_olist("  1. [ ] content"), "  1. content")
  eq(converters.obox_to_olist("    2. [x] content"), "    2. content")
end

T["obox_to_olist()"]["preserves quote prefix"] = function()
  eq(converters.obox_to_olist("> 1. [ ] content"), "> 1. content")
  eq(converters.obox_to_olist(">> 2. [x] content"), ">> 2. content")
end

-- ========== List -> Olist/Checkbox ==========

T["list_to_olist()"] = new_set()

T["list_to_olist()"]["converts list to ordered list"] = function()
  eq(converters.list_to_olist("- content"), "1. content")
  eq(converters.list_to_olist("* content"), "1. content")
  eq(converters.list_to_olist("+ content"), "1. content")
end

T["list_to_olist()"]["preserves whitespace prefix"] = function()
  eq(converters.list_to_olist("  - content"), "  1. content")
  eq(converters.list_to_olist("    * content"), "    1. content")
end

T["list_to_olist()"]["preserves quote prefix"] = function()
  eq(converters.list_to_olist("> - content"), "> 1. content")
  eq(converters.list_to_olist(">> * content"), ">> 1. content")
end

T["list_to_box()"] = new_set()

T["list_to_box()"]["converts list to checkbox"] = function()
  eq(converters.list_to_box("- content"), "- [ ] content")
  eq(converters.list_to_box("* content"), "- [ ] content")
  eq(converters.list_to_box("+ content"), "- [ ] content")
end

T["list_to_box()"]["preserves whitespace prefix"] = function()
  eq(converters.list_to_box("  - content"), "  - [ ] content")
  eq(converters.list_to_box("    * content"), "    - [ ] content")
end

T["list_to_box()"]["preserves quote prefix"] = function()
  eq(converters.list_to_box("> - content"), "> - [ ] content")
  eq(converters.list_to_box(">> * content"), ">> - [ ] content")
end

-- ========== Olist -> List/Checkbox ==========

T["olist_to_list()"] = new_set()

T["olist_to_list()"]["converts ordered list to list"] = function()
  eq(converters.olist_to_list("1. content"), "- content")
  eq(converters.olist_to_list("2. content"), "- content")
  eq(converters.olist_to_list("10. content"), "- content")
  eq(converters.olist_to_list("99. content"), "- content")
end

T["olist_to_list()"]["preserves whitespace prefix"] = function()
  eq(converters.olist_to_list("  1. content"), "  - content")
  eq(converters.olist_to_list("    2. content"), "    - content")
end

T["olist_to_list()"]["preserves quote prefix"] = function()
  eq(converters.olist_to_list("> 1. content"), "> - content")
  eq(converters.olist_to_list(">> 2. content"), ">> - content")
end

T["olist_to_box()"] = new_set()

T["olist_to_box()"]["converts ordered list to checkbox"] = function()
  eq(converters.olist_to_box("1. content"), "- [ ] content")
  eq(converters.olist_to_box("2. content"), "- [ ] content")
  eq(converters.olist_to_box("10. content"), "- [ ] content")
  eq(converters.olist_to_box("99. content"), "- [ ] content")
end

T["olist_to_box()"]["preserves whitespace prefix"] = function()
  eq(converters.olist_to_box("  1. content"), "  - [ ] content")
  eq(converters.olist_to_box("    2. content"), "    - [ ] content")
end

T["olist_to_box()"]["preserves quote prefix"] = function()
  eq(converters.olist_to_box("> 1. content"), "> - [ ] content")
  eq(converters.olist_to_box(">> 2. content"), ">> - [ ] content")
end

T["olist_to_obox()"] = new_set()

T["olist_to_obox()"]["converts ordered list to ordered checkbox"] = function()
  eq(converters.olist_to_obox("1. content"), "1. [ ] content")
  eq(converters.olist_to_obox("2. content"), "2. [ ] content")
  eq(converters.olist_to_obox("10. content"), "10. [ ] content")
  eq(converters.olist_to_obox("99. content"), "99. [ ] content")
end

T["olist_to_obox()"]["preserves whitespace prefix"] = function()
  eq(converters.olist_to_obox("  1. content"), "  1. [ ] content")
  eq(converters.olist_to_obox("    2. content"), "    2. [ ] content")
end

T["olist_to_obox()"]["preserves quote prefix"] = function()
  eq(converters.olist_to_obox("> 1. content"), "> 1. [ ] content")
  eq(converters.olist_to_obox(">> 2. content"), ">> 2. [ ] content")
end

return T
