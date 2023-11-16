return {
  { "folke/neodev.nvim", opts = {} },
  { "echasnovski/mini.bufremove" },
  { "max397574/better-escape.nvim", event = "InsertCharPre", opts = { timeout = 300 } },
  { "karb94/neoscroll.nvim", event = "VeryLazy", opts = {} },
  { "NvChad/nvim-colorizer.lua", event = { "BufReadPre", "BufNewFile" }, config = true },
  { "folke/todo-comments.nvim", { "nvim-lua/plenary.nvim" }, config = true },
  { "b0o/schemastore.nvim", enabled = false }, -- TODO try this out when setting up projects
  { "smjonas/inc-rename.nvim", config = true }, -- LSP renaming with immediate visual feedback
}
