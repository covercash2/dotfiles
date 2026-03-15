-- C/C++ tools

return {
	{
		"p00f/clangd_extensions.nvim",
		dependencies = {
      "neovim/nvim-lspconfig",
			"mfussenegger/nvim-dap",
    },
		config = function()
			require("clangd_extensions").setup()
		end,
	},
	{
		"Civitasv/cmake-tools.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"mfussenegger/nvim-dap",
		},
		opts = {
			cmake_command = "cmake",
			cmake_build_directory = "build",
			cmake_generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1" },
			cmake_build_options = {},
			cmake_console_size = 10, -- cmake output window height
			cmake_show_console = "always", -- "always", "only_on_error"
			cmake_dap_configuration = { name = "cpp", type = "codelldb", request = "launch" }, -- dap configuration, optional
			cmake_dap_open_command = function()
        require("dap").repl.open()
      end, -- optional
			cmake_variants_message = {
				short = { show = true },
				long = { show = true, max_length = 40 },
			},
		},
	},
}
