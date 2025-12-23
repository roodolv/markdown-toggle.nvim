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

-- ========== Known Bugs (Manual Testing Required) ==========
-- The following bugs require manual testing in interactive Neovim:
--
-- 1. Dot-repeat with autolist_up/down generates "0."
--    Steps to reproduce:
--      1. Start with: "1. hoge"
--      2. Press O (autolist_up) → creates "1. " above, renumbers to "2. hoge"
--      3. Press Escape to return to Normal mode
--      4. Press . (dot-repeat) → BUG: creates "0. " instead of proper number
--    Expected: Should create "1. " and renumber properly
--    Actual: Creates "0. " because recalculation is not triggered correctly
--
-- 2. Autolist doesn't generate Ordered Checkboxes
--    Steps to reproduce:
--      1. Start with: "1. [ ] task"
--      2. Press o (autolist_down)
--    Expected: Should create "2. [ ] "
--    Actual: Creates "2. " (ordered list without checkbox)
--
-- 3. Autolist indentation bug - indent doubles incorrectly
--    Steps to reproduce:
--      1. Start with nested list:
--         - hoge
--             - abc
--             - bcd  <- cursor here
--      2. Press o (autolist_down)
--    Expected: New line with same indentation "            - "
--    Actual: New line with doubled indentation "                - "
--    Note: This happens when cursor is not at line end
--
-- 4. Ordered List <CR> near line start generates duplicate marks
--    Steps to reproduce:
--      1. Start with: "1. hoge"
--      2. Move cursor near beginning of line
--      3. Press <CR>
--    Expected: Proper line split
--    Actual: Duplicate olist marks appear

-- ========== Autolist Behavior Test Patterns ==========
-- These patterns document expected autolist behavior for various scenarios.
-- Use these for manual testing.
--
-- Pattern 1: Plain text or blank line above
--   Before: "a" (or blank line)
--           "    > - hoge|"  (cursor at |)
--   After:  "a"
--           "    > - hoge"
--           "    > - |"      (same indent, quote+list preserved)
--
-- Pattern 2: Quote+list without text above
--   Before: "> - "
--           "    > - hoge|"
--   After:  "> - "
--           "    > - hoge"
--           "        > - |"  (indent increases due to parent)
--
-- Pattern 3: Quote with text above
--   Before: "> a"
--           "    > - hoge|"
--   After:  "> a"
--           "    > - hoge"
--           "        > - |"
--
-- Pattern 4: List with text above
--   Before: "- a"
--           "    > - hoge|"
--   After:  "- a"
--           "    > - hoge"
--           "        > - |"
--
-- Pattern 5: Quote+list with text above
--   Before: "> - a"
--           "    > - hoge|"
--   After:  "> - a"
--           "    > - hoge"
--           "        > - |"
--
-- Note: Patterns 2-5 show increased indentation when parent line has marks.
-- This may or may not be the desired behavior depending on use case.

return T
