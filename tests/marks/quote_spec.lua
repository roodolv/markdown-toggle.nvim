-- Helper aliases
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local quote = require('markdown-toggle.marks.quote')

-- Main test set
local T = new_set()

-- has_quote()
T['has_quote()'] = new_set()

T['has_quote()']['detects quote mark at beginning'] = function()
  eq(quote.has_quote('> content'), true)
  eq(quote.has_quote('  > content'), true)
end

T['has_quote()']['detects nested quote marks'] = function()
  eq(quote.has_quote('>> content'), true)
  eq(quote.has_quote('> > content'), true)
end

T['has_quote()']['returns false for non-quote lines'] = function()
  eq(quote.has_quote('content'), false)
  eq(quote.has_quote('  content'), false)
  eq(quote.has_quote(''), false)
end

-- create_quote()
T['create_quote()'] = new_set()

T['create_quote()']['adds quote mark to plain text'] = function()
  eq(quote.create_quote('content'), '> content')
end

T['create_quote()']['adds quote mark to empty line'] = function()
  eq(quote.create_quote(''), '> ')
end

-- remove_quote()
T['remove_quote()'] = new_set()

T['remove_quote()']['removes quote mark with space'] = function()
  eq(quote.remove_quote('> content'), 'content')
end

T['remove_quote()']['removes quote mark without space'] = function()
  eq(quote.remove_quote('>content'), 'content')
end

T['remove_quote()']['removes one level from nested quotes'] = function()
  eq(quote.remove_quote('>> content'), '> content')
  eq(quote.remove_quote('> > content'), '> content')
end

T['remove_quote()']['handles leading whitespace'] = function()
  eq(quote.remove_quote('  > content'), '  content')
end

-- extract_quote_marks()
T['extract_quote_marks()'] = new_set()

T['extract_quote_marks()']['extracts single quote mark'] = function()
  eq(quote.extract_quote_marks('> content'), '> ')
end

T['extract_quote_marks()']['extracts nested quote marks with spaces'] = function()
  eq(quote.extract_quote_marks('> > content'), '> > ')
end

T['extract_quote_marks()']['extracts nested quote marks without spaces'] = function()
  eq(quote.extract_quote_marks('>>content'), '>>')
end

T['extract_quote_marks()']['returns empty string for non-quote lines'] = function()
  eq(quote.extract_quote_marks('content'), '')
end

-- separate_quote()
T['separate_quote()'] = new_set()

T['separate_quote()']['separates quote mark from body'] = function()
  local result = quote.separate_quote('> content')
  eq(result.whitespace, '')
  eq(result.mark, '> ')
  eq(result.body, 'content')
end

T['separate_quote()']['handles nested quotes'] = function()
  local result = quote.separate_quote('> > content')
  eq(result.whitespace, '')
  eq(result.mark, '> > ')
  eq(result.body, 'content')
end

T['separate_quote()']['handles non-quote lines'] = function()
  local result = quote.separate_quote('content')
  eq(result.whitespace, '')
  eq(result.mark, '')
  eq(result.body, 'content')
end

T['separate_quote()']['handles empty lines'] = function()
  local result = quote.separate_quote('')
  eq(result.whitespace, '')
  eq(result.mark, '')
  eq(result.body, '')
end

return T
