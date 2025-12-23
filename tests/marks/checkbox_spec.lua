-- Helper aliases
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local checkbox = require('markdown-toggle.marks.checkbox')

-- Main test set
local T = new_set({
  hooks = {
    pre_case = function()
      -- Set default config: marks_pattern, states_pattern, default_mark, checked_state, box_table
      checkbox.set_config('%-+%*=', ' x~!>', '-', 'x', { 'x', '~', '!', '>' })
    end,
  },
})

-- empty_box()
T['empty_box()'] = new_set()

T['empty_box()']['returns empty box string'] = function()
  eq(checkbox.empty_box(), '[ ]')
end

-- ===== Normal Checkboxes =====

-- matched_box()
T['matched_box()'] = new_set()

T['matched_box()']['matches checkbox'] = function()
  local ws, mark, state, text, trailing = checkbox.matched_box('- [ ] content')
  eq(ws, '')
  eq(mark, '-')
  eq(state, ' ')
  eq(text, 'content')
  eq(trailing, '')
end

T['matched_box()']['matches checked checkbox'] = function()
  local _, _, state = checkbox.matched_box('- [x] content')
  eq(state, 'x')
end

T['matched_box()']['matches different box states'] = function()
  local _, _, state1 = checkbox.matched_box('- [ ] content')
  local _, _, state2 = checkbox.matched_box('- [x] content')
  local _, _, state3 = checkbox.matched_box('- [~] content')
  eq(state1, ' ')
  eq(state2, 'x')
  eq(state3, '~')
end

T['matched_box()']['matches with quote marks'] = function()
  local ws, mark, state = checkbox.matched_box('> - [ ] content')
  eq(ws, '> ')
  eq(mark, '-')
  eq(state, ' ')
end

T['matched_box()']['returns nil for non-checkbox lines'] = function()
  local ws, mark = checkbox.matched_box('content')
  eq(ws, nil)
  eq(mark, nil)
end

-- has_box()
T['has_box()'] = new_set()

T['has_box()']['detects checkbox'] = function()
  eq(checkbox.has_box('- [ ] content'), true)
  eq(checkbox.has_box('- [x] content'), true)
end

T['has_box()']['returns false for non-checkbox lines'] = function()
  eq(checkbox.has_box('- content'), false)
  eq(checkbox.has_box('content'), false)
end

-- check_box()
T['check_box()'] = new_set()

T['check_box()']['checks empty checkbox'] = function()
  eq(checkbox.check_box('- [ ] content'), '- [x] content')
end

-- uncheck_box()
T['uncheck_box()'] = new_set()

T['uncheck_box()']['unchecks checked checkbox'] = function()
  eq(checkbox.uncheck_box('- [x] content'), '- [ ] content')
  eq(checkbox.uncheck_box('- [~] content'), '- [ ] content')
end

-- create_box()
T['create_box()'] = new_set()

T['create_box()']['adds checkbox to plain text'] = function()
  eq(checkbox.create_box('content'), '- [ ] content')
end

T['create_box()']['preserves leading whitespace'] = function()
  eq(checkbox.create_box('  content'), '  - [ ] content')
end

T['create_box()']['preserves quote marks'] = function()
  eq(checkbox.create_box('> content'), '> - [ ] content')
end

-- remove_box()
T['remove_box()'] = new_set()

T['remove_box()']['removes checkbox'] = function()
  eq(checkbox.remove_box('- [ ] content'), 'content')
  eq(checkbox.remove_box('- [x] content'), 'content')
end

T['remove_box()']['preserves leading whitespace'] = function()
  eq(checkbox.remove_box('  - [ ] content'), '  content')
end

-- cycle_box()
T['cycle_box()'] = new_set()

T['cycle_box()']['cycles through box states'] = function()
  eq(checkbox.cycle_box('- [ ] content', false), '- [x] content')
  eq(checkbox.cycle_box('- [x] content', false), '- [~] content')
  eq(checkbox.cycle_box('- [~] content', false), '- [!] content')
  eq(checkbox.cycle_box('- [!] content', false), '- [>] content')
end

T['cycle_box()']['unchecks at end when list_before_box=false'] = function()
  eq(checkbox.cycle_box('- [>] content', false), '- [ ] content')
end

T['cycle_box()']['returns convert signal when list_before_box=true'] = function()
  eq(checkbox.cycle_box('- [>] content', true), 'convert_to_list')
end

-- ===== Ordered Checkboxes =====

-- matched_obox()
T['matched_obox()'] = new_set()

T['matched_obox()']['matches ordered checkbox'] = function()
  local ws, num, state = checkbox.matched_obox('1. [ ] content')
  eq(ws, '')
  eq(num, '1')
  eq(state, ' ')
end

T['matched_obox()']['matches checked ordered checkbox'] = function()
  local _, _, state = checkbox.matched_obox('1. [x] content')
  eq(state, 'x')
end

T['matched_obox()']['returns nil for non-obox lines'] = function()
  local ws, num = checkbox.matched_obox('content')
  eq(ws, nil)
  eq(num, nil)
end

-- has_obox()
T['has_obox()'] = new_set()

T['has_obox()']['detects ordered checkbox'] = function()
  eq(checkbox.has_obox('1. [ ] content'), true)
  eq(checkbox.has_obox('1. [x] content'), true)
end

T['has_obox()']['returns false for non-obox lines'] = function()
  eq(checkbox.has_obox('1. content'), false)
  eq(checkbox.has_obox('content'), false)
end

-- check_obox()
T['check_obox()'] = new_set()

T['check_obox()']['checks empty ordered checkbox'] = function()
  eq(checkbox.check_obox('1. [ ] content'), '1. [x] content')
end

-- uncheck_obox()
T['uncheck_obox()'] = new_set()

T['uncheck_obox()']['unchecks checked ordered checkbox'] = function()
  eq(checkbox.uncheck_obox('1. [x] content'), '1. [ ] content')
  eq(checkbox.uncheck_obox('1. [~] content'), '1. [ ] content')
end

-- create_obox()
T['create_obox()'] = new_set()

T['create_obox()']['adds ordered checkbox to plain text'] = function()
  eq(checkbox.create_obox('content'), '1. [ ] content')
end

T['create_obox()']['preserves leading whitespace'] = function()
  eq(checkbox.create_obox('  content'), '  1. [ ] content')
end

T['create_obox()']['preserves quote marks'] = function()
  eq(checkbox.create_obox('> content'), '> 1. [ ] content')
end

-- remove_obox()
T['remove_obox()'] = new_set()

T['remove_obox()']['removes ordered checkbox'] = function()
  eq(checkbox.remove_obox('1. [ ] content'), 'content')
  eq(checkbox.remove_obox('1. [x] content'), 'content')
end

T['remove_obox()']['preserves leading whitespace'] = function()
  eq(checkbox.remove_obox('  1. [ ] content'), '  content')
end

-- cycle_obox()
T['cycle_obox()'] = new_set()

T['cycle_obox()']['cycles through obox states'] = function()
  eq(checkbox.cycle_obox('1. [ ] content', false), '1. [x] content')
  eq(checkbox.cycle_obox('1. [x] content', false), '1. [~] content')
  eq(checkbox.cycle_obox('1. [~] content', false), '1. [!] content')
  eq(checkbox.cycle_obox('1. [!] content', false), '1. [>] content')
end

T['cycle_obox()']['unchecks at end when list_before_box=false'] = function()
  eq(checkbox.cycle_obox('1. [>] content', false), '1. [ ] content')
end

T['cycle_obox()']['returns convert signal when list_before_box=true'] = function()
  eq(checkbox.cycle_obox('1. [>] content', true), 'convert_to_olist')
end

-- ========== Custom box_table Configuration ==========

T['custom box_table'] = new_set()

T['custom box_table']['works with custom states'] = function()
  -- Custom config: box_table = { "p", "I", "t", "c" }, checked_state = "p"
  checkbox.set_config('%-+%*', ' pItc', '-', 'p', { 'p', 'I', 't', 'c' })

  -- Create checkbox should use custom default list mark and empty box
  eq(checkbox.create_box('content'), '- [ ] content')

  -- Cycle should go through custom states
  eq(checkbox.cycle_box('- [ ] content', false), '- [p] content')
  eq(checkbox.cycle_box('- [p] content', false), '- [I] content')
  eq(checkbox.cycle_box('- [I] content', false), '- [t] content')
  eq(checkbox.cycle_box('- [t] content', false), '- [c] content')
  eq(checkbox.cycle_box('- [c] content', false), '- [ ] content')  -- back to empty

  -- Restore default config
  checkbox.set_config('%-+%*=', ' x~!>', '-', 'x', { 'x', '~', '!', '>' })
end

return T
