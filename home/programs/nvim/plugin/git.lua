require("gitsigns").setup({})

vim.keymap.set("n", "<leader>vB", "<cmd>GitBlameToggle<cr>", { desc = "toggle git blame" })
