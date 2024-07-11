local M = {}

---@param config MarkdownToggleConfig
M.set = function(config)
  local opts = { silent = true, noremap = true }
  local toggle = require("markdown-toggle")

  vim.api.nvim_create_autocmd("FileType", {
    desc = "markdown-toggle.nvim keymaps",
    pattern = config.filetypes or { "markdown", "markdown.mdx" },
    callback = function(args)
      opts.buffer = args.buf

      local keymaps = {
        ["<C-q>"] = {
          n = { callback = toggle.quote, desc = "MarkdownToggle Quote" },
          x = { callback = toggle.quote, desc = "MarkdownToggle Quote" },
        },
        ["<C-l>"] = {
          n = { callback = toggle.list, desc = "MarkdownToggle List" },
          x = { callback = toggle.list, desc = "MarkdownToggle List" },
        },
        ["<C-n>"] = {
          n = { callback = toggle.olist, desc = "MarkdownToggle Ordered List" },
          x = { callback = toggle.olist, desc = "MarkdownToggle Ordered List" },
        },
        ["<Leader><C-x>"] = {
          n = { callback = toggle.checkbox, desc = "MarkdownToggle Checkbox" },
          x = { callback = toggle.checkbox, desc = "MarkdownToggle Checkbox" },
        },
        ["<C-h>"] = {
          n = { callback = toggle.heading, desc = "MarkdownToggle Heading" },
          x = { callback = toggle.heading, desc = "MarkdownToggle Heading" },
        },
        ["<Leader>mU"] = {
          n = { callback = toggle.switch_unmarked_only, desc = "MarkdownToggle Switch unmarked-only" },
        },
        ["<Leader>mB"] = {
          n = { callback = toggle.switch_blankhead_skip, desc = "MarkdownToggle Switch blankhead-skip" },
        },
        ["<Leader>mI"] = {
          n = { callback = toggle.switch_inner_indent, desc = "MarkdownToggle Switch inner-indent" },
        },
        ["<Leader>mS"] = {
          n = { callback = toggle.switch_auto_samestate, desc = "MarkdownToggle Switch auto-samestate" },
        },
        ["<Leader>mL"] = {
          n = { callback = toggle.switch_list_cycle, desc = "MarkdownToggle Switch list-cycle" },
        },
        ["<Leader>mX"] = {
          n = { callback = toggle.switch_box_cycle, desc = "MarkdownToggle Switch box-cycle" },
        },
      }

      if config.enable_dot_repeat then
        keymaps["<C-q>"].n = { callback = toggle.quote_dot, expr = true, desc = "MarkdownToggle Quote Dot-repeat" }
        keymaps["<C-l>"].n = { callback = toggle.list_dot, expr = true, desc = "MarkdownToggle List Dot-repeat" }
        keymaps["<C-n>"].n =
          { callback = toggle.olist_dot, expr = true, desc = "MarkdownToggle Ordered List Dot-repeat" }
        keymaps["<Leader><C-x>"].n =
          { callback = toggle.checkbox_dot, expr = true, desc = "MarkdownToggle Checkbox Dot-repeat" }
        keymaps["<C-h>"].n = { callback = toggle.heading_dot, expr = true, desc = "MarkdownToggle Heading Dot-repeat" }
      end

      if config.enable_autolist then
        keymaps["O"] = { n = { callback = toggle.autolist_up, expr = false, desc = "MarkdownToggle Autolist upward" } }
        keymaps["o"] =
          { n = { callback = toggle.autolist_down, expr = false, desc = "MarkdownToggle Autolist downward" } }
        keymaps["<CR>"] = { i = { callback = toggle.autolist_cr, expr = false, desc = "MarkdownToggle Autolist <CR>" } }
      end

      for key, modes in pairs(keymaps) do
        for mode, mapping in pairs(modes) do
          local mode_opts = vim.tbl_extend("force", opts, mapping)
          vim.keymap.set(mode, key, mapping.callback, mode_opts)
        end
      end
    end, -- callback
  }) -- nvim_create_autocmd
end

return M
