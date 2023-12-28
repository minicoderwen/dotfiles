return function()
  -- set an empty statusline till lualine loads
  -- hide the statusline on the starter page
  vim.g.lualine_laststatus = vim.o.laststatus
  if vim.fn.argc(-1) > 0 then
    vim.o.statusline = " "
  else
    vim.o.laststatus = 0
  end

  -- colors for highlights
  local colors = {
    bg = "#202328",
    fg = "#bbc2cf",
    yellow = "#ECBE7B",
    cyan = "#008080",
    darkblue = "#081633",
    green = "#98be65",
    orange = "#FF8800",
    violet = "#a9a1e1",
    magenta = "#c678dd",
    blue = "#51afef",
    red = "#ec5f67",
  }

  -- lsp client
  local LSP_status = function()
    local clients = vim.lsp.get_clients()
    local msg = "No Active Lsp"
    if next(clients) == nil then return msg end
    if rawget(vim, "lsp") then
      for _, client in ipairs(vim.lsp.get_clients()) do
        if
          client.attached_buffers[vim.api.nvim_win_get_buf(0)]
          and client.name ~= "null-ls"
          and client.name ~= "copilot"
        then
          return client.name
        else
          return msg
        end
      end
    end
  end

  -- lazy status
  local lazy_status = require "lazy.status"
  local lazy = function() return lazy_status.updates() end

  -- conditions for components to show
  local conditions = {
    buffer_not_empty = function() return vim.fn.empty(vim.fn.expand "%:t") ~= 1 end,
    hide_in_width = function() return vim.fn.winwidth(0) > 80 end,
    lazy_status = lazy_status.has_updates,
    is_copilot = function()
      local utils = require "core.utils"
      if not package.loaded["copilot"] then return end
      local ok, clients = pcall(utils.get_clients, { name = "copilot", bufnr = 0 })
      if not ok then return false end
      return ok and #clients > 0
    end,
  }

  require("lualine").setup {
    extensions = { "quickfix", "lazy", "mason", "nvim-dap-ui", "neo-tree", "toggleterm", "quickfix" },
    options = {
      theme = "ayu_dark",
      globalstatus = true,
      component_separators = "",
      section_separators = "",
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {},
      lualine_c = {
        {
          "branch",
          color = { fg = "#ffffff", gui = "bold" },
        },
        {
          "diff",
          cond = conditions.hide_in_width,
          symbols = { added = " ", modified = "󰝤 ", removed = " " },
          diff_color = {
            added = { fg = colors.green },
            modified = { fg = colors.orange },
            removed = { fg = colors.red },
          },
        },
        {
          lazy,
          cond = conditions.lazy_status,
          color = { fg = colors.orange },
        },
        {
          "copilot",
          cond = conditions.is_copilot,
          symbols = {
            status = {
              icons = {
                enabled = "",
                disabled = "",
                warning = "",
                unknown = "",
              },
              hl = {
                enabled = "#50FA7B",
                disabled = "#6272A4",
                warning = "#FFB86C",
                unknown = "#FF5555",
              },
            },
            spinners = require("copilot-lualine.spinners").dots,
            spinner_color = "#6272A4",
          },
          show_colors = true,
          show_loading = true,
        },
        { function() return "%=" end },
        {
          LSP_status,
          icon = "  LSP:",
          color = { fg = "#ffffff", gui = "bold" },
        },
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = { error = " ", warn = " ", info = " " },
          diagnostics_color = {
            color_error = { fg = colors.red },
            color_warn = { fg = colors.yellow },
            color_info = { fg = colors.cyan },
          },
        },
      },
      lualine_x = {
        {
          "filename",
          cond = conditions.buffer_not_empty,
          color = function()
            -- auto change color according to neovims mode
            local mode_color = {
              n = colors.red,
              i = colors.green,
              v = colors.blue,
              V = colors.blue,
              c = colors.magenta,
              no = colors.red,
              s = colors.orange,
              S = colors.orange,
              [""] = colors.orange,
              ic = colors.yellow,
              R = colors.violet,
              Rv = colors.violet,
              cv = colors.red,
              ce = colors.red,
              r = colors.cyan,
              rm = colors.cyan,
              ["r?"] = colors.cyan,
              ["!"] = colors.red,
              t = colors.red,
            }
            return { fg = mode_color[vim.fn.mode()] }
          end,
        },
        {
          "filetype",
          color = { fg = colors.fg, gui = "bold" },
        },
        {
          "encoding",
          fmt = string.upper,
          cond = conditions.hide_in_width,
          color = { fg = colors.fg, gui = "bold" },
        },
        {
          "progress",
          color = { fg = colors.fg, gui = "bold" },
        },
      },
      lualine_y = {},
      lualine_z = { "location" },
    },
  }
end
