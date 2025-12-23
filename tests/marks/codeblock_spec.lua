-- Helper aliases
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local codeblock = require('markdown-toggle.marks.codeblock')

-- Main test set
local T = new_set()

-- matched_codeblock()
T['matched_codeblock()'] = new_set()

T['matched_codeblock()']['matches code block delimiter'] = function()
  eq(codeblock.matched_codeblock('```'), '```')
  eq(codeblock.matched_codeblock('```lua'), '```')
  eq(codeblock.matched_codeblock('```python'), '```')
end

T['matched_codeblock()']['returns nil for non-codeblock lines'] = function()
  eq(codeblock.matched_codeblock('content'), nil)
  eq(codeblock.matched_codeblock('``'), nil)
  eq(codeblock.matched_codeblock('  ```'), nil) -- With leading whitespace
end

-- has_codeblock()
T['has_codeblock()'] = new_set()

T['has_codeblock()']['detects code block delimiter'] = function()
  eq(codeblock.has_codeblock('```'), true)
  eq(codeblock.has_codeblock('```lua'), true)
  eq(codeblock.has_codeblock('```python'), true)
end

T['has_codeblock()']['returns false for non-codeblock lines'] = function()
  eq(codeblock.has_codeblock('content'), false)
  eq(codeblock.has_codeblock('``'), false)
  eq(codeblock.has_codeblock('  ```'), false)
end

return T
