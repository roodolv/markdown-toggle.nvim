# Testing with mini.test

This directory contains tests for markdown-toggle.nvim using the [mini.test](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-test.md) testing framework.

## Prerequisites

- Neovim v0.10.0+
- Git (for cloning mini.nvim)

## Setup

mini.nvim will be automatically cloned when you run tests for the first time.

## Running Tests

### Run all tests
```bash
make test
```

### Run a specific test file
```bash
make test-file FILE=tests/marks/quote_spec.lua
```

### Clean dependencies
```bash
make clean-deps
```

## Test Structure

```
tests/
├── deps/               # Test dependencies (auto-generated)
│   └── mini.nvim/     # mini.nvim cloned here
├── marks/             # Tests for basic mark detection/manipulation
├── features/          # Tests for high-level features
├── shared/            # Tests for utility functions
└── minimal_init.lua   # Minimal Neovim configuration for testing
```

## Writing Tests

Tests use the mini.test syntax:

```lua
local MiniTest = require('mini.test')
local new_set = MiniTest.new_set

local T = new_set()

T['module_name'] = new_set()

T['module_name']['function_name'] = function()
  local actual = some_function()
  MiniTest.expect.equality(actual, expected)
end

return T
```

## Coverage Goals

- **Core Functions**: 95-100% coverage
- **Complex Features**: Incremental improvement with ongoing test additions
