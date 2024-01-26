local M = {
  "mfussenegger/nvim-dap",
  enabled = vim.fn.has "win32" == 0,
  dependencies = {
    "rcarriga/nvim-dap-ui",
    { "rcarriga/cmp-dap", dependencies = { "nvim-cmp" } },
    { "theHamsta/nvim-dap-virtual-text", config = true },
  },
  event = { "BufReadPre", "BufNewFile" },
  init = function() require("core.utils").load_mappings "dap" end,
}

function M.config()
  local dap, dapui = require "dap", require "dapui"

  require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
    sources = {
      { name = "dap" },
    },
  })

  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
  dapui.setup {
    floating = {
      border = "rounded",
    },
  }

  require("dap").adapters["codelldb"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "codelldb",
      args = {
        "--port",
        "${port}",
      },
    },
  }
  for _, lang in ipairs { "c", "cpp", "objc", "cuda", "proto" } do
    dap.configurations[lang] = {
      {
        type = "codelldb",
        request = "launch",
        name = "Launch file",
        program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
        cwd = "${workspaceFolder}",
      },
      {
        type = "codelldb",
        request = "attach",
        name = "Attach to process",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
      },
    }
  end
  -- for c/c++ debugging end
end
return M