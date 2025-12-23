local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local autolist = require("markdown-toggle.features.autolist")

-- Test suite
local T = new_set()

-- ========== Configuration ==========

T["set_config()"] = new_set()

T["set_config()"]["stores configuration"] = function()
  local config = {
    enable_auto_samestate = true,
    enable_olist_recalc = false,
  }

  -- Should not error
  autolist.set_config(config)

  -- We can't directly test the internal state, but we can verify it doesn't error
  eq(true, true)
end

-- ========== Note ==========
-- Most of autolist.lua functionality requires Vim API (nvim_feedkeys, nvim_set_current_line, etc.)
-- and is better suited for integration tests rather than unit tests.
--
-- Future work:
-- - Create integration tests for autolist behavior
-- - Test checkbox auto-continuation
-- - Test list auto-continuation
-- - Test ordered list auto-continuation with increment/decrement
-- - Test quote preservation in autolist
-- - Test enable_auto_samestate configuration

return T
