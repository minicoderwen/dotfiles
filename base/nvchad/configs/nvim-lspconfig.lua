return function()
	local lspconfig = require("lspconfig")
	local cmp_nvim_lsp = require("cmp_nvim_lsp")

	local on_attach = function(client, bufnr)
		-- enable inlay hints
		if client.server_capabilities.inlayHintProvider then
			vim.g.inlay_hints_visible = true
			vim.lsp.inlay_hint.enable(bufnr, true)
		else
			print("no inlay hints available")
		end
		require("core.utils").load_mappings("lspconfig")
	end

	-- local on_attach_cpp = function()
	-- 	require("core.utils").load_mappings("lspconfig")
	-- end

	-- used to enable autocompletion (assign to every lsp server config)
	local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

	-- Change the Diagnostic symbols in the sign column (gutter)
	local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	end

	-- configure html server
	lspconfig["html"].setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	-- configure css server
	lspconfig["cssls"].setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	-- configure emmet language server
	lspconfig["emmet_ls"].setup({
		capabilities = capabilities,
		on_attach = on_attach,
		filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
	})

	-- configure lua server (with special settings)
	lspconfig["lua_ls"].setup({
		capabilities = capabilities,
		on_attach = on_attach,
		settings = { -- custom settings for lua
			Lua = {
				-- make the language server recognize "vim" global
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					-- make language server aware of runtime files
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
						[vim.fn.stdpath("config") .. "/lua"] = true,
						[vim.fn.stdpath("data") .. "/lazy/ui/nvchad_types"] = true,
						[vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
					},
				},
			},
		},
	})
	lspconfig["pyright"].setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	lspconfig["marksman"].setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	lspconfig["yamlls"].setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	lspconfig["jsonls"].setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	lspconfig["ansiblels"].setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	lspconfig["docker_compose_language_service"].setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	lspconfig["dockerls"].setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	lspconfig["lemminx"].setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})

	-- lspconfig["clangd"].setup({
	-- 	on_attach = on_attach_cpp,
	-- 	root_dir = function(fname)
	-- 		return require("lspconfig.util").root_pattern(
	-- 			"Makefile",
	-- 			"configure.ac",
	-- 			"configure.in",
	-- 			"config.h.in",
	-- 			"meson.build",
	-- 			"meson_options.txt",
	-- 			"build.ninja"
	-- 		)(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(fname) or require(
	-- 			"lspconfig.util"
	-- 		).find_git_ancestor(fname)
	-- 	end,
	-- 	capabilities = {
	-- 		offsetEncoding = { "utf-16" },
	-- 	},
	-- 	cmd = {
	-- 		"clangd",
	-- 		"--background-index",
	-- 		"--clang-tidy",
	-- 		"--header-insertion=iwyu",
	-- 		"--completion-style=detailed",
	-- 		"--function-arg-placeholders",
	-- 		"--fallback-style=llvm",
	-- 	},
	-- 	init_options = {
	-- 		usePlaceholders = true,
	-- 		completeUnimported = true,
	-- 		clangdFileStatus = true,
	-- 	},
	-- })
end
