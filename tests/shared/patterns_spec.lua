local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local patterns = require("markdown-toggle.shared.patterns")

-- Test suite
local T = new_set()

-- ========== generate_list_marks() ==========

T["generate_list_marks()"] = new_set()

T["generate_list_marks()"]["generates pattern from single mark"] = function()
  eq(patterns.generate_list_marks({ "-" }), "%-")
end

T["generate_list_marks()"]["generates pattern from multiple marks"] = function()
  eq(patterns.generate_list_marks({ "-", "+", "*" }), "%-%+%*")
  eq(patterns.generate_list_marks({ "-", "+", "*", "=" }), "%-%+%*%=")
end

T["generate_list_marks()"]["escapes special regex characters"] = function()
  -- All marks get % prefix for Lua pattern escaping
  eq(patterns.generate_list_marks({ ".", "*", "+" }), "%.%*%+")
end

T["generate_list_marks()"]["handles empty table"] = function()
  eq(patterns.generate_list_marks({}), "")
end

-- ========== generate_box_states() ==========

T["generate_box_states()"] = new_set()

T["generate_box_states()"]["starts with space"] = function()
  local result = patterns.generate_box_states({ "x" })
  eq(result:sub(1, 1), " ")
  eq(result, " x")
end

T["generate_box_states()"]["generates pattern from single state"] = function()
  eq(patterns.generate_box_states({ "x" }), " x")
end

T["generate_box_states()"]["generates pattern from multiple states"] = function()
  eq(patterns.generate_box_states({ "x", "~", "!", ">" }), " x~!>")
  eq(patterns.generate_box_states({ " ", "x", "X", "~" }), "  xX~")
end

T["generate_box_states()"]["preserves state characters as-is"] = function()
  -- Unlike list marks, box states are not escaped
  eq(patterns.generate_box_states({ ".", "*", "+" }), " .*+")
end

T["generate_box_states()"]["handles empty table"] = function()
  eq(patterns.generate_box_states({}), " ")
end

T["generate_box_states()"]["handles special characters"] = function()
  eq(patterns.generate_box_states({ "x", "X", "-", ">", "~", "!" }), " xX->~!")
end

return T
