-- Minimal init.lua for testing with mini.test

-- Add current plugin to runtimepath
local root = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")
vim.opt.runtimepath:prepend(root)

-- Add lua directory to package.path for require() to work
package.path = root .. "lua/?.lua;" .. root .. "lua/?/init.lua;" .. package.path

-- Add mini.nvim to runtimepath (assumes it's in tests/deps/mini.nvim)
local mini_path = root .. "tests/deps/mini.nvim"
if vim.fn.isdirectory(mini_path) == 1 then
  vim.opt.runtimepath:prepend(mini_path)
else
  print("Warning: mini.nvim not found at " .. mini_path)
  print("Run: git clone https://github.com/echasnovski/mini.nvim tests/deps/mini.nvim")
end

-- Minimal settings
vim.opt.swapfile = false

-- Load the plugin
vim.cmd("runtime! plugin/**/*.vim")
vim.cmd("runtime! plugin/**/*.lua")

-- Load mini.test globally
_G.MiniTest = require('mini.test')
