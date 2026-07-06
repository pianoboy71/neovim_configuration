return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim",                   opts = {} },
	},
	config = function()
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local capabilities = cmp_nvim_lsp.default_capabilities()
		local keymap = vim.keymap
		local qt_clangd_flag_pattern = "^Unknown argument:%s*['\"]?%-mno%-direct%-extern%-access['\"]?"

		local function cmd_from_path(command, ...)
			local executable = vim.fn.exepath(command)
			return { executable ~= "" and executable or command, ... }
		end

		local function python_path(root_dir)
			local function existing_python(base)
				local candidates = {
					base .. "/Scripts/python.exe",
					base .. "/bin/python",
					base .. "/bin/python3",
				}

				for _, candidate in ipairs(candidates) do
					if vim.uv.fs_stat(candidate) then
						return candidate
					end
				end
			end

			if vim.env.VIRTUAL_ENV then
				local python = existing_python(vim.env.VIRTUAL_ENV)
				if python then
					return python
				end
			end

			local roots = {
				root_dir,
				vim.fn.getcwd(),
			}

			for _, root in ipairs(roots) do
				if root and root ~= "" then
					for _, env_dir in ipairs({ ".venv", "venv", "env" }) do
						local python = existing_python(root .. "/" .. env_dir)
						if python then
							return python
						end
					end
				end
			end

			return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or vim.fn.exepath("python")
		end

		local default_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
		vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
			local client = ctx and vim.lsp.get_client_by_id(ctx.client_id)
			if client and client.name == "clangd" and result and result.diagnostics then
				result = vim.deepcopy(result)
				result.diagnostics = vim.tbl_filter(function(diagnostic)
					local message = diagnostic.message or ""
					return not message:match(qt_clangd_flag_pattern)
				end, result.diagnostics)
			end

			return default_publish_diagnostics(err, result, ctx, config)
		end


		-- setup keymaps when LSP attaches
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client and client.server_capabilities.semanticTokensProvider then
					client.server_capabilities.semanticTokensProvider = nil
				end

				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

				opts.desc = "Go to definition"
				keymap.set("n", "gd", vim.lsp.buf.definition, opts)

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

				opts.desc = "Show documentation under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

				-- Enable inlay hints if supported
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				local ft = vim.bo[ev.buf].filetype
				local path = vim.api.nvim_buf_get_name(ev.buf)
				local disable_inlay_hints = vim.tbl_contains({ "c", "cpp", "objc", "objcpp" }, ft)
				    or path:match("%.h$")
				    or path:match("%.hh$")
				    or path:match("%.hpp$")
				    or path:match("%.hxx$")
				    or path:match("%.inl$")

				if client and client.server_capabilities.inlayHintProvider and not disable_inlay_hints then
					vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
				end
			end,
		})

		-- inline diagnostics (virtual text)
		vim.diagnostic.config({
			virtual_text = {
				prefix = "●",
				spacing = 2,
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})

		-- ============================
		-- Language servers
		-- ============================

		-- ============================
		-- TypeScript / TSX (NEW API)
		-- ============================
		vim.lsp.config("ts_ls", {
			capabilities = capabilities,
			cmd = cmd_from_path("typescript-language-server", "--stdio"),
			filetypes = {
				"typescript",
				"typescriptreact",
				"javascript",
				"javascriptreact",
			},
		})

		vim.lsp.enable("ts_ls")

		-- ============================
		-- Clang
		-- ============================
		vim.lsp.config("clangd", {
			capabilities = capabilities,
			cmd = cmd_from_path(
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--query-driver=/usr/bin/c++,/usr/bin/g++"
			),
		})
		vim.lsp.enable("clangd")

		-- ============================
		-- Lua
		-- ============================
		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			cmd = cmd_from_path("lua-language-server"),
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						checkThirdParty = false,
						library = vim.api.nvim_get_runtime_file("", true),
					},
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})
		vim.lsp.enable("lua_ls")

		-- ============================
		-- Python
		-- ============================
		vim.lsp.config("pyright", {
			capabilities = capabilities,
			cmd = cmd_from_path("pyright-langserver", "--stdio"),
			root_markers = {
				"pyrightconfig.json",
				"pyproject.toml",
				"setup.py",
				"setup.cfg",
				"requirements.txt",
				"Pipfile",
				".git",
			},
			before_init = function(_, config)
				config.settings = config.settings or {}
				config.settings.python = config.settings.python or {}
				config.settings.python.pythonPath = python_path(config.root_dir)
			end,
			settings = {
				python = {
					analysis = {
						autoImportCompletions = true,
						autoSearchPaths = true,
						diagnosticMode = "workspace",
						typeCheckingMode = "basic",
						useLibraryCodeForTypes = true,
					},
				},
			},
		})

		vim.lsp.enable("pyright")

		-- ============================
		-- Rust
		-- ============================
		vim.lsp.config("rust_analyzer", {
			capabilities = capabilities,
			cmd = cmd_from_path("rust-analyzer"),
			settings = {
				["rust-analyzer"] = {
					inlayHints = {
						typeHints = { enable = true },

						parameterHints = { enable = false },
						chainingHints = { enable = false },
						bindingModeHints = { enable = false },
						closureReturnTypeHints = { enable = "never" },
						lifetimeElisionHints = { enable = "never" },
						reborrowHints = { enable = false },
						closingBraceHints = { enable = false },
					},
				},
			},
		})

		vim.lsp.enable("rust_analyzer")

		-- ============================
		-- Typst
		-- ============================
		vim.lsp.config("tinymist", {
			cmd = { "tinymist" },
			filetypes = { "typst" },
			root_markers = { ".git" },
			capabilities = capabilities,
		})

		vim.lsp.enable("tinymist")

		-- ============================
		-- Haskell
		-- ============================
		if vim.fn.executable("haskell-language-server-wrapper") == 1 then
			vim.lsp.config("hls", {
				capabilities = capabilities,
				cmd = { "haskell-language-server-wrapper", "--lsp" },
				filetypes = { "haskell", "lhaskell", "cabal" },
				root_markers = { "hie.yaml", "stack.yaml", "cabal.project", "package.yaml", "*.cabal", ".git" },
			})

			vim.lsp.enable("hls")
		end

		-- ============================
		-- Godot / GDScript
		-- ============================
		vim.lsp.config("gdscript", {
			capabilities = capabilities,
		})

		vim.lsp.enable("gdscript")

		if vim.fn.executable("gdshader-lsp") == 1 then
			vim.lsp.config("gdshader_lsp", {
				capabilities = capabilities,
			})

			vim.lsp.enable("gdshader_lsp")
		end
	end,


}
