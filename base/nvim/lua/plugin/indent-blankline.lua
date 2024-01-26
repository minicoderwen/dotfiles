local M = {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPre", "BufNewFile" },
}

function M.config()
  local hooks = require "ibl.hooks"
  hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
  require("ibl").setup {
    indent = { char = "│" },
    -- scope = { char = "│" },
    scope = { show_start = false, show_end = false },
    exclude = {
      buftypes = {
        "nofile",
        "terminal",
      },
      filetypes = {
        "help",
        "startify",
        "aerial",
        "alpha",
        "dashboard",
        "lazy",
        "neogitstatus",
        "NvimTree",
        "neo-tree",
        "Trouble",
      },
    },
  }
end

return M