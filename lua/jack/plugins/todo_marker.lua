return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			c = { "clang_format" },
			cpp = { "clang_format" },
			objc = { "clang_format" },
			objcpp = { "clang_format" },
			gdscript = { "gdscript-formatter", "gdformat" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			json = { "prettier" },
			lua = { "stylua" },
			markdown = { "prettier" },
			rust = { "rustfmt" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			typst = { "typstyle" },
		},
		formatters = {
			clang_format = {
				prepend_args = {
					"--style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never}",
				},
			},
			prettier = {
				prepend_args = { "--tab-width", "4", "--use-tabs", "false" },
			},
			stylua = {
				prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
			},
		},
	},
	config = function(_, opts)
		local conform = require("conform")

		conform.setup(opts)

		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("JackFormatOnSave", { clear = true }),
			callback = function(args)
				conform.format({
					bufnr = args.buf,
					async = false,
					timeout_ms = 3000,
					lsp_format = "fallback",
				})
			end,
		})
	end,
}
