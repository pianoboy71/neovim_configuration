return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		local ensure_installed = {
			"ts_ls",
			"html",
			"cssls",
			"tailwindcss",
			"svelte",
			"lua_ls",
			"graphql",
			"emmet_ls",
			"pyright",
			"clangd",
			"rust_analyzer",
		}

		mason_lspconfig.setup({
			ensure_installed = ensure_installed,
			automatic_enable = {
				exclude = {
					"ts_ls",
					"clangd",
					"lua_ls",
					"pyright",
					"rust_analyzer",
					"tinymist",
					"hls",
					"gdscript",
					"gdshader_lsp",
				},
			},
		})
	end,
}
