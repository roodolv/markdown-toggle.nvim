local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local autolist = require("markdown-toggle.features.autolist")

-- Integration test suite for autolist
local T = new_set()

-- ========== Module Loading ==========

T["autolist module"] = new_set()

T["autolist module"]["loads without error"] = function()
  eq(type(autolist), "table")
  eq(type(autolist.autolist), "function")
  eq(type(autolist.set_config), "function")
end

-- ========== Note ==========
-- Full integration testing for autolist is not feasible in headless mode
-- because autolist() relies heavily on nvim_feedkeys() which requires
-- an active event loop and user interaction to complete.
--
-- In headless test mode, calling nvim_feedkeys() causes the test to hang
-- indefinitely waiting for the keys to be processed.
--
-- Recommended testing approach for autolist:
-- 1. Unit tests for helper functions (if extracted)
-- 2. Manual testing in interactive Neovim
-- 3. End-to-end tests with a real Neovim instance (not headless)
--
-- The current tests verify that the module loads correctly and its
-- functions are accessible, which is sufficient for basic validation.

return T
