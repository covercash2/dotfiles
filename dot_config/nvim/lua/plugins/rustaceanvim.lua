local auto_show_hover = function(bufnr)
	-- show a window when a doc is available
	vim.api.nvim_create_autocmd("CursorHold", {
		buffer = bufnr,
		callback = function()
			local opts = {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				border = "rounded",
				source = "always",
				prefix = " ",
				scope = "cursor",
			}
			vim.diagnostic.open_float(opts)
		end,
	})
end

return {
	"mrcjkb/rustaceanvim",
	dependencies = {
		"mfussenegger/nvim-dap",
	},
	version = "^6",
	ft = { "rust" },
	lazy = false,
	keys = {
		{
			"<leader>gX",
			"<cmd>RustLsp externalDocs<cr>",
			desc = "Open external docs",
		},
	},
	config = function()
		vim.g.rustaceanvim = {
			server = {
				on_attach = function(client, bufnr)
					auto_show_hover(bufnr)
				end,
			},
      -- TODO update to lspmux
      -- https://github.com/mrcjkb/rustaceanvim/issues/870
      ra_multiplex = {
        enable = true, -- enable autodiscovery for ra-multiplex
        -- default values marked here for docs
        host = '127.0.0.1',
        port = 27631,
      },
		}

		-- configure `dap` debugger
		-- https://github.com/helix-editor/helix/wiki/Debugger-Configurations#install-debuggers
		-- local dap = require("dap")
		-- local path = vim.fn.executable("lldb-dap")
		-- if path == nil then
		-- 	vim.print("could not find path to lldb-dap")
		-- else
		-- 	dap.adapters.lldb = {
		-- 		type = "executable",
		-- 		command = path,
		-- 		name = "lldb",
		-- 	}
		-- 	dap.configurations.rust = {
		-- 		initCommands = function()
		-- 			local rustc_sysroot = vim.fn.trim(vim.fn.system("rustc --print sysroot"))
		--
		-- 			local script_import = 'command script import "'
		-- 					.. rustc_sysroot
		-- 					.. "lib/rustlib/etc/lldb_lookup.py"
		-- 			local commands_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_commands"
		--
		-- 			local commands = {}
		-- 			local file = io.open(commands_file, "r")
		-- 			if file then
		-- 				for line in file:lines() do
		-- 					table.insert(commands, line)
		-- 				end
		-- 				file:close()
		-- 			end
		-- 			table.insert(commands, 1, script_import)
		--
		-- 			return commands
		-- 		end,
		-- 		env = function()
		-- 			local variables = {}
		-- 			for k, v in pairs(vim.fn.environ()) do
		-- 				table.insert(variables, string.format("%s=%s", k, v))
		-- 			end
		-- 			return variables
		-- 		end,
		-- 	}
		-- end
	end,
}
