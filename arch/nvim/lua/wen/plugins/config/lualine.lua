local M = {}

M.init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = " "
    else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
    end
end

M.opts = {
    extensions = { "quickfix", "lazy", "mason", "nvim-dap-ui", "nvim-tree", "toggleterm", "trouble" },
    options = { theme = "catppuccin" },
}

M.config = function(_, opts) require("lualine").setup(opts) end

return M
