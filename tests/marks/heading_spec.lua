-- Helper aliases
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local heading = require('markdown-toggle.marks.heading')

-- Main test set
local T = new_set()

-- Setup: Set default config before each test
T = new_set({
  hooks = {
    pre_case = function()
      heading.set_config('#', { '#', '##', '###', '####', '#####' })
    end,
  },
})

-- has_heading()
T['has_heading()'] = new_set()

T['has_heading()']['detects single # heading'] = function()
  eq(heading.has_heading('# Heading'), true)
  eq(heading.has_heading('  # Heading'), true)
end

T['has_heading()']['detects multiple # headings'] = function()
  eq(heading.has_heading('## Heading'), true)
  eq(heading.has_heading('### Heading'), true)
end

T['has_heading()']['detects headings with quote marks'] = function()
  eq(heading.has_heading('> # Heading'), true)
  eq(heading.has_heading('> > ## Heading'), true)
end

T['has_heading()']['returns false for non-heading lines'] = function()
  eq(heading.has_heading('content'), false)
  eq(heading.has_heading('#heading'), false)
  eq(heading.has_heading(''), false)
end

-- create_heading()
T['create_heading()'] = new_set()

T['create_heading()']['adds heading mark to plain text'] = function()
  eq(heading.create_heading('content'), '# content')
end

T['create_heading()']['adds heading mark to empty line'] = function()
  eq(heading.create_heading(''), '# ')
end

T['create_heading()']['preserves leading whitespace'] = function()
  eq(heading.create_heading('  content'), '  # content')
end

T['create_heading()']['preserves quote marks'] = function()
  eq(heading.create_heading('> content'), '> # content')
end

T['create_heading()']['uses configured heading mark'] = function()
  heading.set_config('##', { '#', '##', '###' })
  eq(heading.create_heading('content'), '## content')
end

-- remove_heading()
T['remove_heading()'] = new_set()

T['remove_heading()']['removes single # heading'] = function()
  eq(heading.remove_heading('# content'), 'content')
end

T['remove_heading()']['removes multiple # headings'] = function()
  eq(heading.remove_heading('## content'), 'content')
  eq(heading.remove_heading('### content'), 'content')
end

T['remove_heading()']['preserves leading whitespace'] = function()
  eq(heading.remove_heading('  # content'), '  content')
end

T['remove_heading()']['preserves quote marks'] = function()
  eq(heading.remove_heading('> # content'), '> content')
end

-- cycle_heading()
T['cycle_heading()'] = new_set()

T['cycle_heading()']['cycles from # to ##'] = function()
  eq(heading.cycle_heading('# content'), '## content')
end

T['cycle_heading()']['cycles through all levels'] = function()
  eq(heading.cycle_heading('# content'), '## content')
  eq(heading.cycle_heading('## content'), '### content')
  eq(heading.cycle_heading('### content'), '#### content')
  eq(heading.cycle_heading('#### content'), '##### content')
end

T['cycle_heading()']['removes heading at end of cycle'] = function()
  eq(heading.cycle_heading('##### content'), 'content')
end

T['cycle_heading()']['respects custom heading table'] = function()
  heading.set_config('#', { '#', '###' })
  eq(heading.cycle_heading('# content'), '### content')
  eq(heading.cycle_heading('### content'), 'content')
end

return T
