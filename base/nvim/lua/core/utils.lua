local M = {}

--- Simplify the mapping of keys.
--- @param mode string|table The mode(s) under which the key mapping will be active. A single mode as a
--- string or a table of modes.
--- @param lhs string The left-hand side of the map, i.e., the key combination that triggers the action.
--- @param rhs string|function The right-hand side of the map, i.e., the command or Lua function to execute when the
--- key combination is pressed.
--- @param opts table? An optional table of options that will override the default mapping options. These options are
--- passed directly to `vim.keymap.set`.
function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  mode = mode or "n"
  if opts then options = vim.tbl_extend("force", options, opts) end
  vim.keymap.set(mode, lhs, rhs, options)
end

--- Check if a lua plugin can be required without causing an error.
--- @param name string The plugin name to check for availability.
--- @return boolean `true` if the module can be loaded, `false` otherwise.
function M.is_available(name)
  local ok, _ = pcall(require, name)
  return ok
end

--- Sets highlight groups based on a provided table.
--- @param highlightGroups table: A table with highlight group names as keys and tables of style attributes as values.
function M.setHighlightGroups(highlightGroups)
  for groupName, styles in pairs(highlightGroups) do
    vim.api.nvim_set_hl(0, groupName, styles)
  end
end

--- Function to set highlights for a given plugin.
--- @param pluginName string: The name of the plugin. Note: the name is arbitrary and needs to exist in "core.highlights".
function M.setPluginHighlights(pluginName)
  local hl = require("core.highlights")[pluginName]
  if hl then
    M.setHighlightGroups(hl)
  else
    M.notify("No highlight definitions found for plugin: " .. pluginName, "WARN")
  end
end

--- Sends a notification message with a specified log level.
--- This function abstracts over Neovim's vim.notify and the fidget plugin's notify function,
--- automatically choosing the available method. It allows specifying the log level as a simple string.
--- @param message string: The notification message to be displayed.
--- @param level string: A string representing the log level (e.g., "WARN", "INFO", "ERROR"). Defaults to "WARN" if an unrecognized string is provided.
function M.notify(message, level)
  local log_levels = {
    TRACE = vim.log.levels.TRACE,
    DEBUG = vim.log.levels.DEBUG,
    INFO = vim.log.levels.INFO,
    WARN = vim.log.levels.WARN,
    ERROR = vim.log.levels.ERROR,
  }
  local log_level = log_levels[level] or vim.log.levels.WARN
  if M.is_available "fidget" then
    require("fidget").notify(message, log_level)
  else
    vim.notify(message, log_level)
  end
end

--- Generates a rounded border.
--- @param hl_name string: The name of the highlight group to be applied to the border.
--- @return table: A table where each element represents a part of the border with its character and highlight.
function M.rounded_border(hl_name)
  return {
    { "╭", hl_name },
    { "─", hl_name },
    { "╮", hl_name },
    { "│", hl_name },
    { "╯", hl_name },
    { "─", hl_name },
    { "╰", hl_name },
    { "│", hl_name },
  }
end

--- Generates a box border style.
--- @param hl_name string: The name of the highlight group to be applied to the border.
--- @return table: A table where each element represents a part of the border with its character and highlight.
function M.box_boarder(hl_name)
  return {
    { "╔", hl_name },
    { "═", hl_name },
    { "╗", hl_name },
    { "║", hl_name },
    { "╝", hl_name },
    { "═", hl_name },
    { "╚", hl_name },
    { "║", hl_name },
  }
end

--- Generates a straight border style.
--- @param hl_name string: The name of the highlight group to be applied to the border.
--- @return table: A table where each element represents a part of the border with its character and highlight.
function M.straight_boarder(hl_name)
  return {
    { "┌", hl_name }, -- Top-left corner
    { "─", hl_name }, -- Top and bottom sides
    { "┐", hl_name }, -- Top-right corner
    { "│", hl_name }, -- Left and right sides
    { "┘", hl_name }, -- Bottom-right corner
    { "─", hl_name }, -- Top and bottom sides (repeated for clarity)
    { "└", hl_name }, -- Bottom-left corner
    { "│", hl_name }, -- Left and right sides (repeated for clarity)
  }
end

--- get the bufnr of all opened buffers
---@author kikito
---@see https://codereview.stackexchange.com/questions/268130/get-list-of-buffers-from-current-neovim-instance
function M.get_listed_buffers()
  local buffers = {}
  local len = 0
  for buffer = 1, vim.fn.bufnr "$" do
    if vim.fn.buflisted(buffer) == 1 then
      len = len + 1
      buffers[len] = buffer
    end
  end
  return buffers
end

-- Copied from LazyVim
---@alias lsp.Client.filter {id?: number, bufnr?: number, name?: string, method?: string, filter?:fun(client: lsp.Client):boolean}
---@param opts? lsp.Client.filter
function M.get_clients(opts)
  local ret = {} ---@type lsp.Client[]
  if vim.lsp.get_clients then
    ret = vim.lsp.get_clients(opts)
  else
    ---@diagnostic disable-next-line: deprecated
    ret = vim.lsp.get_active_clients(opts)
    if opts and opts.method then
      ---@param client lsp.Client
      ret = vim.tbl_filter(function(client) return client.supports_method(opts.method, { bufnr = opts.bufnr }) end, ret)
    end
  end
  return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

--- Copied from Astronvim
--- Check if a buffer is valid
---@param bufnr number? The buffer to check, default to current buffer
---@return boolean # Whether the buffer is valid or not
function M.is_valid(bufnr)
  if not bufnr then bufnr = 0 end
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
end

-- Copied from Astronvim
--- Get the first worktree that a file belongs to
---@param file string? the file to check, defaults to the current file
---@param worktrees table<string, string>[]? an array like table of worktrees with entries `toplevel` and `gitdir`, default retrieves from `vim.g.git_worktrees`
---@return table<string, string>|nil # a table specifying the `toplevel` and `gitdir` of a worktree or nil if not found
function M.file_worktree(file, worktrees)
  worktrees = worktrees or vim.g.git_worktrees
  if not worktrees then return end
  file = file or vim.fn.expand "%"
  for _, worktree in ipairs(worktrees) do
    if
      M.cmd({
        "git",
        "--work-tree",
        worktree.toplevel,
        "--git-dir",
        worktree.gitdir,
        "ls-files",
        "--error-unmatch",
        file,
      }, false)
    then
      return worktree
    end
  end
end

-- Copied from Astronvim
--- Run a shell command and capture the output and if the command succeeded or failed
---@param cmd string|string[] The terminal command to execute
---@param show_error? boolean Whether or not to show an unsuccessful command as an error to the user
---@return string|nil # The result of a successfully executed command or nil
function M.cmd(cmd, show_error)
  if type(cmd) == "string" then cmd = { cmd } end
  if vim.fn.has "win32" == 1 then cmd = vim.list_extend({ "cmd.exe", "/C" }, cmd) end
  local result = vim.fn.system(cmd)
  local success = vim.api.nvim_get_vvar "shell_error" == 0
  if not success and (show_error == nil or show_error) then
    vim.api.nvim_err_writeln(("Error running command %s\nError message:\n%s"):format(table.concat(cmd, " "), result))
  end
  return success and result:gsub("[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "") or nil
end

-- Copied from Astronvim
--- Helper function to check if any active LSP clients given a filter provide a specific capability
---@param capability string The server capability to check for (example: "documentFormattingProvider")
---@param filter vim.lsp.get_active_clients.filter|nil (table|nil) A table with
---              key-value pairs used to filter the returned clients.
---              The available keys are:
---               - id (number): Only return clients with the given id
---               - bufnr (number): Only return clients attached to this buffer
---               - name (string): Only return clients with the given name
---@return boolean # Whether or not any of the clients provide the capability
function M.has_capability(capability, filter)
  for _, client in ipairs(vim.lsp.get_clients(filter)) do
    if client.supports_method(capability) then return true end
  end
  return false
end

function M.add_buffer_autocmd(augroup, bufnr, autocmds)
  if not vim.tbl_islist(autocmds) then autocmds = { autocmds } end
  local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })
  if not cmds_found or vim.tbl_isempty(cmds) then
    vim.api.nvim_create_augroup(augroup, { clear = false })
    for _, autocmd in ipairs(autocmds) do
      local events = autocmd.events
      autocmd.events = nil
      autocmd.group = augroup
      autocmd.buffer = bufnr
      vim.api.nvim_create_autocmd(events, autocmd)
    end
  end
end

function M.del_buffer_autocmd(augroup, bufnr)
  local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })
  if cmds_found then vim.tbl_map(function(cmd) vim.api.nvim_del_autocmd(cmd.id) end, cmds) end
end

function M.on_attach(client, bufnr)
  local map = require("core.utils").map
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  -- lsp globals
  map("n", "[d", function() vim.diagnostic.goto_prev() end, { desc = "Prev diagnostic" })
  map("n", "]d", function() vim.diagnostic.goto_next() end, { desc = "Next diagnostic" })
  map("n", "gh", function() vim.diagnostic.open_float() end, { desc = "Floating diagnostic" })

  if client.supports_method "textDocument/codeAction" then
    map({ "n", "v" }, "<leader>la", function() vim.lsp.buf.code_action() end, { desc = "LSP code action" })
  end

  if client.supports_method "textDocument/codeLens" then
    vim.g.codelens_enabled = true
    M.add_buffer_autocmd("lsp_codelens_refresh", bufnr, {
      events = { "InsertLeave", "BufEnter" },
      desc = "Refresh codelens",
      callback = function()
        if not M.has_capability("textDocument/codeLens", { bufnr = bufnr }) then
          M.del_buffer_autocmd("lsp_codelens_refresh", bufnr)
          return
        end
        if vim.g.codelens_enabled then vim.lsp.codelens.refresh() end
      end,
    })
    if vim.g.codelens_enabled then vim.lsp.codelens.refresh() end
    map("n", "<leader>lC", function() vim.lsp.codelens.refresh() end, { desc = "LSP CodeLens refresh" })

    map("n", "<leader>lL", function() vim.lsp.codelens.run() end, { desc = "LSP CodeLens run" })
  end

  if client.supports_method "textDocument/declaration" then
    map("n", "gD", function() vim.lsp.buf.declaration() end, { desc = "LSP declaration" })
  end

  if client.supports_method "textDocument/definition" then
    map("n", "gd", function() require("telescope.builtin").lsp_definitions() end, { desc = "LSP definition" })
  end

  if client.supports_method "textDocument/formatting" then
    map("n", "<leader>lf", function() vim.lsp.buf.format(M.format_opts) end, { desc = "Format buffer" })
    map("v", "<leader>lf", function() vim.lsp.buf.format(M.format_opts) end, { desc = "Format buffer" })
  end

  if client.supports_method "textDocument/implementation" then
    map("n", "gi", function() require("telescope.builtin").lsp_implementations() end, { desc = "LSP implementation" })
  end

  if client.supports_method "textDocument/references" then
    map("n", "gr", function() require("telescope.builtin").lsp_references() end, { desc = "LSP references" })
  end

  if client.supports_method "textDocument/rename" then
    require("inc_rename").setup()
    map("n", "<leader>lr", function() return ":IncRename " .. vim.fn.expand "<cword>" end, { desc = "LSP rename" })
  end

  if client.supports_method "textDocument/signatureHelp" then
    map("n", "<leader>lh", function() vim.lsp.buf.signature_help() end, { desc = "Signature help" })
  end

  if client.supports_method "textDocument/typeDefinition" then
    map("n", "gy", function() require("telescope.builtin").lsp_type_definitions() end, { desc = "LSP type definition" })
  end

  if client.supports_method "workspace/symbol" then
    map("n", "<leader>ls", function()
      vim.ui.input({ prompt = "Symbol Query: (leave empty for word under cursor)" }, function(query)
        if query then
          -- word under cursor if given query is empty
          if query == "" then query = vim.fn.expand "<cword>" end
          require("telescope.builtin").lsp_workspace_symbols {
            query = query,
            prompt_title = ("Find word (%s)"):format(query),
          }
        end
      end)
    end, { desc = "Search workspace symbols" })
  end

  if client.supports_method "textDocument/documentHighlight" then
    M.add_buffer_autocmd("lsp_document_highlight", bufnr, {
      {
        events = { "CursorHold", "CursorHoldI" },
        desc = "highlight references when cursor holds",
        callback = function()
          if not M.has_capability("textDocument/documentHighlight", { bufnr = bufnr }) then
            M.del_buffer_autocmd("lsp_document_highlight", bufnr)
            return
          end
          vim.lsp.buf.document_highlight()
        end,
      },
      {
        events = { "CursorMoved", "CursorMovedI", "BufLeave" },
        desc = "clear references when cursor moves",
        callback = function() vim.lsp.buf.clear_references() end,
      },
    })
  end

  -- enable inlay hints
  if client.supports_method "textDocument/inlayHint" then
    vim.g.inlay_hints_visible = true
    vim.lsp.inlay_hint.enable(bufnr, true)
  else
    M.notify(client.name .. " does not support inlay hints", "WARN")
  end

  if client.name == "clangd" then
    map("n", "<Leader>lR", "<CMD>ClangdSwitchSourceHeader<CR>", { desc = "Switch Source/Header (C/C++)" })
  end
end

return M
