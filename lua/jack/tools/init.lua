-- lua/jack/tools/init.lua
local M = {}

function M.setup()
	local group = vim.api.nvim_create_augroup("JackIncludeFormatter", { clear = true })

	-- C/C++ include formatter
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		pattern = { "*.h", "*.hpp", "*.hh", "*.hxx", "*.c", "*.cc", "*.cpp", "*.cxx" },
		callback = function(args)
			local ft = vim.bo[args.buf].filetype
			if ft == "typst" then return end
			require("jack.tools.include_formatter").format(args.buf)
		end,
	})

	-- Typst auto-compile
	local typst_job = nil

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		pattern = "*.typ",
		callback = function(args)
			local file = vim.api.nvim_buf_get_name(args.buf)
			local pdf = file:gsub("%.typ$", ".pdf")

			if typst_job then
				vim.fn.jobstop(typst_job)
			end

			typst_job = vim.fn.jobstart({ "typst", "compile", file, pdf })
		end,
	})

	-- :Skel command
	vim.api.nvim_create_user_command("Skel", function()
		require("jack.tools.skeleton").insert()
	end, {})

	-- :TypstPreview command
	vim.api.nvim_create_user_command("TypstPreview", function()
		local file = vim.fn.expand("%")
		local pdf = file:gsub("%.typ$", ".pdf")
		if vim.ui.open then
			vim.ui.open(pdf)
		elseif vim.fn.has("win32") == 1 then
			vim.fn.jobstart({ "cmd.exe", "/c", "start", "", pdf }, { detach = true })
		elseif vim.fn.has("macunix") == 1 then
			vim.fn.jobstart({ "open", pdf }, { detach = true })
		else
			vim.fn.jobstart({ "xdg-open", pdf }, { detach = true })
		end
	end, {})

	require("jack.tools.cpp_extract").setup()
end

return M
