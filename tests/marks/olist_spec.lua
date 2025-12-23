-- Helper aliases
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local olist = require('markdown-toggle.marks.olist')

-- Main test set
local T = new_set()

-- matched_olist()
T['matched_olist()'] = new_set()

T['matched_olist()']['matches ordered list mark'] = function()
  local ws, mark, text, trailing = olist.matched_olist('1. content')
  eq(ws, '')
  eq(mark, '1')
  eq(text, 'content')
  eq(trailing, '')
end

T['matched_olist()']['matches with leading whitespace'] = function()
  local ws, mark, text, trailing = olist.matched_olist('  2. content')
  eq(ws, '  ')
  eq(mark, '2')
  eq(text, 'content')
end

T['matched_olist()']['matches with quote marks'] = function()
  local ws, mark, text, trailing = olist.matched_olist('> 3. content')
  eq(ws, '> ')
  eq(mark, '3')
  eq(text, 'content')
end

T['matched_olist()']['matches different numbers'] = function()
  local _, mark1 = olist.matched_olist('1. content')
  local _, mark2 = olist.matched_olist('10. content')
  local _, mark3 = olist.matched_olist('99. content')
  eq(mark1, '1')
  eq(mark2, '10')
  eq(mark3, '99')
end

T['matched_olist()']['returns nil for non-olist lines'] = function()
  local ws, mark = olist.matched_olist('content')
  eq(ws, nil)
  eq(mark, nil)
end

-- has_olist()
T['has_olist()'] = new_set()

T['has_olist()']['detects ordered list mark'] = function()
  eq(olist.has_olist('1. content'), true)
  eq(olist.has_olist('2. content'), true)
  eq(olist.has_olist('10. content'), true)
end

T['has_olist()']['detects olist with leading whitespace'] = function()
  eq(olist.has_olist('  1. content'), true)
end

T['has_olist()']['detects olist with quote marks'] = function()
  eq(olist.has_olist('> 1. content'), true)
end

T['has_olist()']['returns false for non-olist lines'] = function()
  eq(olist.has_olist('content'), false)
  eq(olist.has_olist('1.content'), false) -- No space after dot
  eq(olist.has_olist(''), false)
end

-- create_olist()
T['create_olist()'] = new_set()

T['create_olist()']['adds ordered list mark to plain text'] = function()
  eq(olist.create_olist('content'), '1. content')
end

T['create_olist()']['adds ordered list mark to empty line'] = function()
  eq(olist.create_olist(''), '1. ')
end

T['create_olist()']['preserves leading whitespace'] = function()
  eq(olist.create_olist('  content'), '  1. content')
end

T['create_olist()']['preserves quote marks'] = function()
  eq(olist.create_olist('> content'), '> 1. content')
end

-- remove_olist()
T['remove_olist()'] = new_set()

T['remove_olist()']['removes ordered list mark'] = function()
  eq(olist.remove_olist('1. content'), 'content')
  eq(olist.remove_olist('2. content'), 'content')
  eq(olist.remove_olist('10. content'), 'content')
end

T['remove_olist()']['preserves leading whitespace'] = function()
  eq(olist.remove_olist('  1. content'), '  content')
end

T['remove_olist()']['preserves quote marks'] = function()
  eq(olist.remove_olist('> 1. content'), '> content')
end

-- increment_olist()
T['increment_olist()'] = new_set()

T['increment_olist()']['increments number'] = function()
  eq(olist.increment_olist('1'), '2. ')
  eq(olist.increment_olist('5'), '6. ')
  eq(olist.increment_olist('99'), '100. ')
end

-- decrement_olist()
T['decrement_olist()'] = new_set()

T['decrement_olist()']['decrements number'] = function()
  eq(olist.decrement_olist('2'), '1. ')
  eq(olist.decrement_olist('10'), '9. ')
  eq(olist.decrement_olist('100'), '99. ')
end

return T
