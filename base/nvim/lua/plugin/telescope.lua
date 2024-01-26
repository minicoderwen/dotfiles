local M = {
  "nvim-telescope/telescope.nvim",
  version = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "debugloop/telescope-undo.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-telescope/telescope-frecency.nvim",
    { "2kabhishek/nerdy.nvim", cmd = "Nerdy" },
    { "nvim-telescope/telescope-fzf-native.nvim", enabled = vim.fn.executable "make" == 1, build = "make" },
  },
  event = "VimEnter",
  init = function() require("core.utils").load_mappings "telescope" end,
}

function M.config()
  local actions = require "telescope.actions"
  local telescope = require "telescope"
  local trouble = require "trouble.providers.telescope"
  local icons = require "core.icons"

  telescope.setup {
    defaults = {
      git_worktrees = vim.g.git_worktrees,
      prompt_prefix = icons.Search .. "  ",
      selection_caret = icons.Selected .. "  ",
      layout_config = {
        horizontal = {
          preview_width = 0.55,
          results_width = 0.8,
        },
        vertical = {
          mirror = false,
        },
        width = 0.95,
        height = 0.90,
        preview_cutoff = 120,
      },
      winblend = 0,
      color_devicons = true,
      path_display = { "truncate" },
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      vimgrep_arguments = {
        "rg",
        "-L",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--trim",
        "--hidden",
        -- I don't want to search in the `.git` directory.
        "--glob",
        "!**/.git/*",
      },
      file_ignore_patterns = {
        "node_modules/",
        "%.git/",
        "%.DS_Store$",
        "target/",
        "build/",
        "%.o$",
      },
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      mappings = {
        i = {
          ["<C-k>"] = actions.move_selection_previous, -- move to prev result
          ["<C-j>"] = actions.move_selection_next, -- move to next result
          ["<C-e>"] = actions.close, -- close telescope
          ["<C-n>"] = actions.cycle_history_next, -- cycle previewer next
          ["<C-p>"] = actions.cycle_history_prev, -- cycle previewer prev
          ["<C-t>"] = trouble.open_with_trouble,
        },
        n = {
          ["q"] = actions.close, -- close telescope
          ["<C-t>"] = trouble.open_with_trouble,
        },
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
      undo = {},
      ["ui-select"] = { require("telescope.themes").get_dropdown {} },
    },
  }
  telescope.load_extension "fzf"
  telescope.load_extension "undo"
  telescope.load_extension "ui-select"
  telescope.load_extension "frecency" -- intelligent prioritization when selecting files from your editing history
end

return M