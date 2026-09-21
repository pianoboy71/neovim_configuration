return {
    {
        "lervag/vimtex",
        lazy = false,
        init = function()
            -- Set Skim as the default PDF viewer on macOS
            vim.g.vimtex_view_method = "skim"

            -- Enable continuous compilation on save via latexmk
            vim.g.vimtex_compiler_method = "latexmk"

            -- Configure latexmk options
            vim.g.vimtex_compiler_latexmk = {
                aux_dir = "",
                out_dir = "build", -- Optional: keeps root folder clean
                callback = 1,
                continuous = 1,
                executable = "latexmk",
                options = {
                    "-verbose",
                    "-file-line-error",
                    "-synctex=1",
                    "-interaction=nonstopmode",
                },
            }
        end,
    },
}
