# Changelog

## [v0.3.2](https://github.com/roodolv/markdown-toggle.nvim/compare/v0.3.1...v0.3.2) (2025-12-03)

### Improvements
- **api**: added config-switch for `obox_as_olist` ([#31](https://github.com/roodolv/markdown-toggle.nvim/pull/31))
- **autolist**: smart continuation for empty list items ([#37](https://github.com/roodolv/markdown-toggle.nvim/pull/37))

### Bug Fixes
- **autolist**: prevent olist auto-recalc inside code blocks ([#35](https://github.com/roodolv/markdown-toggle.nvim/pull/35))

### Refactoring
- **toggle**: remove mark parameters and use cached variables ([c33b9bd](https://github.com/roodolv/markdown-toggle.nvim/commit/c33b9bd61962412b4712eb0c17e7eea80539104c))

## [v0.3.1](https://github.com/roodolv/markdown-toggle.nvim/compare/v0.3.0...v0.3.1) (2025-11-14)

### Bug Fixes
- **checkbox**: supported dynamic regex patterns for box_table ([#27](https://github.com/roodolv/markdown-toggle.nvim/pull/27))
- **toggle**: rewrote hard-coded regex patterns ([#28](https://github.com/roodolv/markdown-toggle.nvim/pull/28))
- **olist**: fixed a bug that `obox_as_olist` was ignored in Visual mode ([#29](https://github.com/roodolv/markdown-toggle.nvim/pull/29))

### Refactoring
- **toggle**: simplified fallback expressions in cycled_XXX functions ([540708d](https://github.com/roodolv/markdown-toggle.nvim/commit/540708d65b89a8d1d17589159e4bbd1914957b07))
- **autolist**: removed redundant target_line variable ([b4aa636](https://github.com/roodolv/markdown-toggle.nvim/commit/b4aa636aca4c4d4f044fffd90a5e40a675bfae21))

### Performance
- **checkbox**: now caches frequently used config values ([4ee5b8e](https://github.com/roodolv/markdown-toggle.nvim/commit/4ee5b8e203f7933975a0bda31bb8047ec87b864c))
- **toggle**: removed redundant has_XXX checks in has_mark() ([16d383a](https://github.com/roodolv/markdown-toggle.nvim/commit/16d383a276536912b5cbc1620a28340f5c361177))

## [v0.3.0](https://github.com/roodolv/markdown-toggle.nvim/compare/v0.2.0...v0.3.0) (2025-11-13)

### Features
- **api**: added Vim commands like MarkdownToggleXXX ([#21](https://github.com/roodolv/markdown-toggle.nvim/pull/21))
- **toggle**: supported vim.v.count for headings, list-cycle, and box-cycle ([#22](https://github.com/roodolv/markdown-toggle.nvim/pull/22))
- **api**: added `heading_toggle` function to api ([#24](https://github.com/roodolv/markdown-toggle.nvim/pull/24))

### Improvements
- **keymap**: added setup_all_keymaps() ([#23](https://github.com/roodolv/markdown-toggle.nvim/pull/23))

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

