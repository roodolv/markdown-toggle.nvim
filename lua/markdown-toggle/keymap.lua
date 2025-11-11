local M = {}

-- Setup Vim commands for all API functions (buffer-local)
local setup_vim_commands = function(bufnr)
  local toggle = require("markdown-toggle")

  -- Toggle commands with range support and dot-repeat capability
  local toggle_commands = {
    { name = "Quote", mode = "quote", desc = "Toggle quote marks" },
    { name = "List", mode = "list", desc = "Toggle list marks" },
    { name = "ListCycle", mode = "list_cycle", desc = "Cycle list marks" },
    { name = "Olist", mode = "olist", desc = "Toggle ordered list marks" },
    { name = "Checkbox", mode = "checkbox", desc = "Toggle checkbox marks" },
    { name = "CheckboxCycle", mode = "checkbox_cycle", desc = "Cycle checkbox marks" },
    { name = "Heading", mode = "heading", desc = "Toggle heading marks" },
  }

  for _, cmd in ipairs(toggle_commands) do
    vim.api.nvim_buf_create_user_command(bufnr, "MarkdownToggle" .. cmd.name, function(opts)
      if opts.range > 0 then
        -- Visual mode: call the function directly
        toggle[cmd.mode]()
      else
        -- Normal mode: use operatorfunc for dot-repeat support
        vim.go.operatorfunc = string.format("v:lua.require'markdown-toggle'.%s", cmd.mode)
        vim.api.nvim_feedkeys("g@l", "n", false)
      end
    end, {
      range = true,
      desc = cmd.desc,
    })
  end

  -- Config switch commands
  local switch_commands = {
    { name = "SwitchUnmarked", func = toggle.switch_unmarked_only, desc = "Switch unmarked-only" },
    { name = "SwitchBlankline", func = toggle.switch_blankline_skip, desc = "Switch blankline-skip" },
    { name = "SwitchHeading", func = toggle.switch_heading_skip, desc = "Switch heading-skip" },
    { name = "SwitchSamestate", func = toggle.switch_auto_samestate, desc = "Switch auto-samestate" },
    { name = "SwitchCycleList", func = toggle.switch_cycle_list_table, desc = "Switch cycle-list-table" },
    { name = "SwitchCycleBox", func = toggle.switch_cycle_box_table, desc = "Switch cycle-box-table" },
    { name = "SwitchListBeforeBox", func = toggle.switch_list_before_box, desc = "Switch list-before-box" },
  }

  for _, cmd in ipairs(switch_commands) do
    vim.api.nvim_buf_create_user_command(bufnr, "MarkdownToggle" .. cmd.name, cmd.func, {
      desc = cmd.desc,
    })
  end
end

---@param config MarkdownToggleConfig
M.set = function(config)
  local opts = { silent = true, noremap = true }
  local toggle = require("markdown-toggle")

  vim.api.nvim_create_autocmd("FileType", {
    desc = "markdown-toggle.nvim keymaps",
    pattern = config.filetypes or { "markdown", "markdown.mdx" },
    callback = function(args)
      opts.buffer = args.buf

      setup_vim_commands(args.buf)

      local keymaps = {
        ["<C-q>"] = {
          n = { callback = toggle.quote, desc = "MarkdownToggle Quote" },
          x = { callback = toggle.quote, desc = "MarkdownToggle Quote" },
        },
        ["<C-l>"] = {
          n = { callback = toggle.list, desc = "MarkdownToggle List" },
          x = { callback = toggle.list, desc = "MarkdownToggle List" },
        },
        ["<Leader><C-l>"] = {
          n = { callback = toggle.list_cycle, desc = "MarkdownToggle List-Cycle" },
          x = { callback = toggle.list_cycle, desc = "MarkdownToggle List-Cycle" },
        },
        ["<C-n>"] = {
          n = { callback = toggle.olist, desc = "MarkdownToggle Ordered List" },
          x = { callback = toggle.olist, desc = "MarkdownToggle Ordered List" },
        },
        ["<M-x>"] = {
          n = { callback = toggle.checkbox, desc = "MarkdownToggle Checkbox" },
          x = { callback = toggle.checkbox, desc = "MarkdownToggle Checkbox" },
        },
        ["<Leader><M-x>"] = {
          n = { callback = toggle.checkbox_cycle, desc = "MarkdownToggle Checkbox-Cycle" },
          x = { callback = toggle.checkbox_cycle, desc = "MarkdownToggle Checkbox-Cycle" },
        },
        ["<C-h>"] = {
          n = { callback = toggle.heading, desc = "MarkdownToggle Heading" },
          x = { callback = toggle.heading, desc = "MarkdownToggle Heading" },
        },
        ["<Leader>mU"] = {
          n = { callback = toggle.switch_unmarked_only, desc = "MarkdownToggle Switch unmarked-only" },
        },
        ["<Leader>mB"] = {
          n = { callback = toggle.switch_blankline_skip, desc = "MarkdownToggle Switch blankline-skip" },
        },
        ["<Leader>mH"] = {
          n = { callback = toggle.switch_heading_skip, desc = "MarkdownToggle Switch heading-skip" },
        },
        ["<Leader>mS"] = {
          n = { callback = toggle.switch_auto_samestate, desc = "MarkdownToggle Switch auto-samestate" },
        },
        ["<Leader>mL"] = {
          n = { callback = toggle.switch_cycle_list_table, desc = "MarkdownToggle Switch cycle-list-table" },
        },
        ["<Leader>mX"] = {
          n = { callback = toggle.switch_cycle_box_table, desc = "MarkdownToggle Switch cycle-box-table" },
        },
        ["<Leader>mC"] = {
          n = { callback = toggle.switch_list_before_box, desc = "MarkdownToggle Switch list-before-box" },
        },
      }

      if config.enable_dot_repeat then
        keymaps["<C-q>"].n = { callback = toggle.quote_dot, expr = true, desc = "MarkdownToggle Quote Dot-repeat" }
        keymaps["<C-l>"].n = { callback = toggle.list_dot, expr = true, desc = "MarkdownToggle List Dot-repeat" }
        keymaps["<Leader><C-l>"].n =
          { callback = toggle.list_cycle_dot, expr = true, desc = "MarkdownToggle List-Cycle Dot-repeat" }
        keymaps["<C-n>"].n =
          { callback = toggle.olist_dot, expr = true, desc = "MarkdownToggle Ordered List Dot-repeat" }
        keymaps["<M-x>"].n =
          { callback = toggle.checkbox_dot, expr = true, desc = "MarkdownToggle Checkbox Dot-repeat" }
        keymaps["<Leader><M-x>"].n =
          { callback = toggle.checkbox_cycle_dot, expr = true, desc = "MarkdownToggle Checkbox-Cycle Dot-repeat" }
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
