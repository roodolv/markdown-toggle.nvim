-- Helper aliases
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local list = require('markdown-toggle.marks.list')

-- Main test set
local T = new_set({
  hooks = {
    pre_case = function()
      -- Set default config: pattern, default mark, table
      list.set_config('%-+%*=', '-', { '-', '+', '*', '=' })
    end,
  },
})

-- matched_list()
T['matched_list()'] = new_set()

T['matched_list()']['matches list mark'] = function()
  local ws, mark, text, trailing = list.matched_list('- content')
  eq(ws, '')
  eq(mark, '-')
  eq(text, 'content')
  eq(trailing, '')
end

T['matched_list()']['matches with leading whitespace'] = function()
  local ws, mark, text, trailing = list.matched_list('  - content')
  eq(ws, '  ')
  eq(mark, '-')
  eq(text, 'content')
end

T['matched_list()']['matches with quote marks'] = function()
  local ws, mark, text, trailing = list.matched_list('> - content')
  eq(ws, '> ')
  eq(mark, '-')
  eq(text, 'content')
end

T['matched_list()']['matches different list marks'] = function()
  local _, mark1 = list.matched_list('- content')
  local _, mark2 = list.matched_list('+ content')
  local _, mark3 = list.matched_list('* content')
  eq(mark1, '-')
  eq(mark2, '+')
  eq(mark3, '*')
end

T['matched_list()']['returns nil for non-list lines'] = function()
  local ws, mark = list.matched_list('content')
  eq(ws, nil)
  eq(mark, nil)
end

-- has_list()
T['has_list()'] = new_set()

T['has_list()']['detects list mark'] = function()
  eq(list.has_list('- content'), true)
  eq(list.has_list('+ content'), true)
  eq(list.has_list('* content'), true)
end

T['has_list()']['detects list with leading whitespace'] = function()
  eq(list.has_list('  - content'), true)
end

T['has_list()']['detects list with quote marks'] = function()
  eq(list.has_list('> - content'), true)
end

T['has_list()']['returns false for non-list lines'] = function()
  eq(list.has_list('content'), false)
  eq(list.has_list(''), false)
end

-- create_list()
T['create_list()'] = new_set()

T['create_list()']['adds list mark to plain text'] = function()
  eq(list.create_list('content'), '- content')
end

T['create_list()']['adds list mark to empty line'] = function()
  eq(list.create_list(''), '- ')
end

T['create_list()']['preserves leading whitespace'] = function()
  eq(list.create_list('  content'), '  - content')
end

T['create_list()']['preserves quote marks'] = function()
  eq(list.create_list('> content'), '> - content')
end

T['create_list()']['uses configured default mark'] = function()
  list.set_config('%-+%*=', '+', { '-', '+', '*', '=' })
  eq(list.create_list('content'), '+ content')
end

-- remove_list()
T['remove_list()'] = new_set()

T['remove_list()']['removes list mark'] = function()
  eq(list.remove_list('- content'), 'content')
  eq(list.remove_list('+ content'), 'content')
  eq(list.remove_list('* content'), 'content')
end

T['remove_list()']['preserves leading whitespace'] = function()
  eq(list.remove_list('  - content'), '  content')
end

T['remove_list()']['preserves quote marks'] = function()
  eq(list.remove_list('> - content'), '> content')
end

-- cycle_list()
T['cycle_list()'] = new_set()

T['cycle_list()']['cycles from - to +'] = function()
  eq(list.cycle_list('- content'), '+ content')
end

T['cycle_list()']['cycles through all marks'] = function()
  eq(list.cycle_list('- content'), '+ content')
  eq(list.cycle_list('+ content'), '* content')
  eq(list.cycle_list('* content'), '= content')
end

T['cycle_list()']['removes list at end of cycle'] = function()
  eq(list.cycle_list('= content'), 'content')
end

T['cycle_list()']['respects custom list table'] = function()
  list.set_config('%-+', '-', { '-', '+' })
  eq(list.cycle_list('- content'), '+ content')
  eq(list.cycle_list('+ content'), 'content')
end

return T
