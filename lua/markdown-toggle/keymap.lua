local M = {}

-- Setup Vim commands for all API functions (buffer-local)
local setup_vim_commands = function(bufnr)
  local toggle = require("markdown-toggle")

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
M.setup_common_keymaps = function(config)
  vim.api.nvim_create_autocmd("FileType", {
    desc = "markdown-toggle.nvim common keymaps",
    pattern = config.filetypes or { "markdown", "markdown.mdx" },
    callback = function(args) setup_vim_commands(args.buf) end,
  })
end

---@param config MarkdownToggleConfig
M.setup_all_keymaps = function(config)
  local toggle = require("markdown-toggle")
  local config_module = require("markdown-toggle.config")
  local patterns = config.filetypes or { "markdown", "markdown.mdx" }

  -- Use user config or fallback to defaults
  local user_keymaps = config.keymaps or {}
  local toggle_keymaps = user_keymaps.toggle or config_module.default_keymaps.toggle
  local switch_keymaps = user_keymaps.switch or config_module.default_keymaps.switch
  local autolist_keymaps = user_keymaps.autolist or config_module.default_keymaps.autolist

  vim.api.nvim_create_autocmd("FileType", {
    desc = "markdown-toggle.nvim all keymaps",
    pattern = patterns,
    callback = function(args)
      -- Toggle keymaps (with dot-repeat support)
      for key, mode_name in pairs(toggle_keymaps) do
        if config.enable_dot_repeat then
          vim.keymap.set("n", key, toggle[mode_name .. "_dot"], {
            expr = true,
            silent = true,
            buffer = args.buf,
            desc = string.format("MarkdownToggle %s", mode_name),
          })
        else
          vim.keymap.set("n", key, toggle[mode_name], {
            silent = true,
            buffer = args.buf,
            desc = string.format("MarkdownToggle %s", mode_name),
          })
        end
        vim.keymap.set("x", key, toggle[mode_name], {
          silent = true,
          buffer = args.buf,
          desc = string.format("MarkdownToggle %s", mode_name),
        })
      end

      -- Switch keymaps (Normal mode only)
      for key, func_name in pairs(switch_keymaps) do
        vim.keymap.set("n", key, toggle[func_name], {
          silent = true,
          buffer = args.buf,
          desc = string.format("MarkdownToggle %s", func_name),
        })
      end

      -- Autolist keymaps (if enabled)
      if config.enable_autolist then
        for key, func_name in pairs(autolist_keymaps) do
          local mode = (func_name == "autolist_cr") and "i" or "n"
          vim.keymap.set(mode, key, toggle[func_name], {
            silent = true,
            buffer = args.buf,
            desc = string.format("MarkdownToggle %s", func_name),
          })
        end
      end
    end, -- callback
  }) -- nvim_create_autocmd
end

return M
