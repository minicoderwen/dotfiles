return function(_, opts)
	dofile(vim.g.base46_cache .. "mason")
	require("mason").setup(opts)

	require("mason-lspconfig").setup({
		ensure_installed = {
			"html",
			"cssls",
			"emmet_ls", -- html, css
			"lua_ls", -- lua
			"pyright", -- python
			"marksman", -- markdown
			"yamlls", -- yaml
			"jsonls", -- json
			"ansiblels", -- ansible
			"docker_compose_language_service", -- docker compose
			"dockerls", -- docker
			"jdtls", -- java
			"lemminx", -- xml
			"clangd", -- c/c++
		},
		automatic_installation = true,
	})

	require("mason-null-ls").setup({
		ensure_installed = {
			"stylua", -- lua formatter
			"black", -- python formatter
			"isort", -- python formatter
			"pylint", -- python linter
			"eslint_d", -- js linter
			"markdownlint", -- markdownlinter
			"prettierd", -- prettier formatter
			"ansiblelint", -- ansible linter
			"hadolint", -- dockerfile linter
			"google_java_format", -- java formatter
			"shfmt", -- shell formatter
		},
	})

	require("mason-nvim-dap").setup({
		ensure_installed = {
			"javadbg", -- java debugger
			"javatest", -- java test runner
			"codelldb", -- c/c++ debugger
		},
	})
end
