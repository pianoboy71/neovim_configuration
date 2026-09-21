return {
    {
        "epwalsh/obsidian.nvim",
        version = "*",
        lazy = true,
        ft = "markdown",
        cmd = {
            "ObsidianOpen",
            "ObsidianNew",
            "ObsidianQuickSwitch",
            "ObsidianFollowLink",
            "ObsidianBacklinks",
            "ObsidianTags",
            "ObsidianToday",
            "ObsidianRename",
            "ObsidianSearch",
            "ObsidianWorkspace",
        },
        keys = {
            { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "Obsidian New Note" },
            { "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "Obsidian Today (Daily Note)" },
            { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Obsidian Search (Grep Vault)" },
            { "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>", desc = "Obsidian Quick Switch File" },
            { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Obsidian Open in App" },
            { "<leader>of", "<cmd>ObsidianFollowLink<cr>", desc = "Obsidian Follow Link" },
            { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Obsidian Backlinks" },
            { "<leader>og", "<cmd>ObsidianTags<cr>", desc = "Obsidian Search Tags" },
            { "<leader>or", "<cmd>ObsidianRename<cr>", desc = "Obsidian Rename Note" },
            { "<leader>ow", "<cmd>ObsidianWorkspace<cr>", desc = "Obsidian Switch Workspace" },
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        init = function()
            -- Enable conceal level for markdown buffers
            vim.opt.conceallevel = 2
        end,
        opts = {
            workspaces = {
                {
                    name = "vault",
                    path = vim.fn.expand("~/Documents/Obsidian Vault"),
                },
            },
            notes_subdir = "notes",
            daily_notes = {
                folder = "",
                date_format = "%Y-%m-%d",
            },
        },
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
    },
}
