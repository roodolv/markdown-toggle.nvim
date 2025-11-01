# Changelog

## [v0.2.0](https://github.com/roodolv/markdown-toggle.nvim/compare/v0.1.2...v0.2.0) (2025-11-02)

### Features
- **olist**: supported ordered list recalculation ([#19](https://github.com/roodolv/markdown-toggle.nvim/pull/19))

### Improvements
- **config**: split enable-blankhead config into two configs ([#14](https://github.com/roodolv/markdown-toggle.nvim/pull/14))
- **checkbox**: supported ordered checkboxes and added obox_as_olist config ([#16](https://github.com/roodolv/markdown-toggle.nvim/pull/16))

### Bug Fixes
- **quote**: fixed detection of successive quotes ([#17](https://github.com/roodolv/markdown-toggle.nvim/pull/17))
- **autolist**: fixed indentation bug on autolist() ([#18](https://github.com/roodolv/markdown-toggle.nvim/pull/18))

## [v0.1.2](https://github.com/roodolv/markdown-toggle.nvim/compare/v0.1.1...v0.1.2) (2025-09-17)

### Improvements
- **heading**: `heading()` no longer skips headings ([#7](https://github.com/roodolv/markdown-toggle.nvim/pull/7))
- **config**: removed inner-indent config ([#10](https://github.com/roodolv/markdown-toggle.nvim/pull/10))
- **toggle**: toggle functions now detect consecutive quotation marks ([#12](https://github.com/roodolv/markdown-toggle.nvim/pull/12))
- **quote**: `quote()` now behaves based on the indentation depth ([#12](https://github.com/roodolv/markdown-toggle.nvim/pull/12))

### Bug Fixes
- **autolist**: fixed incorrect indentation ([#9](https://github.com/roodolv/markdown-toggle.nvim/pull/9))

### Reverts
- **config**: removed inner-indent config ([93a729f](https://github.com/roodolv/markdown-toggle.nvim/commit/93a729fd0a034cfed53241c29e06c175c11e1366))

### Refactoring
- **olist**: olist returns a space right after a number on `autolist()` ([aecd05f](https://github.com/roodolv/markdown-toggle.nvim/commit/aecd05f6a7e66a766267c0d0389297bbaefe45e4))
- **autolist**: rewrote if-conditions etc ([88af8ef](https://github.com/roodolv/markdown-toggle.nvim/commit/88af8ef850b039344787d5fed0484d1387fa69dd))
- **checkbox**: changed the global variable to the returned variable ([86087ca](https://github.com/roodolv/markdown-toggle.nvim/commit/86087cab606c8073389dcb6f1ecc900139eb5785))

### Performance
- **other**: removed redundant expression from `is_marked()` ([81ffaa0](https://github.com/roodolv/markdown-toggle.nvim/commit/81ffaa04af0aa80e14af970438a64e5303eb22b4))

