local chat_keys = {
	toggle = "<leader>at",
}

return {
	{
		"zbirenbaum/copilot.lua",
    dependencies = {
      "copilotlsp-nvim/copilot-lsp",
    },
		keys = {
			{
				"<leader>ap",
				function()
					require("copilot.panel").toggle()
				end,
				desc = "toggle Copilot panel",
			},
		},
		event = "InsertEnter",
		cmd = { "Copilot" },
		config = function()
			require("copilot").setup({
				copilot_model = "", -- set to "" to use the default model
				suggestion = {
					auto_trigger = true,
					debounce = 75,
					keymap = {
						-- use tab to accept suggestions
						accept = "<Tab>",
					},
				},
        nes = {
          enabled = false,
          keymap = {
            accept_and_goto = "<leader>p",
            accept = false,
            dismiss = "<Esc>",
          },
        },
				panel = {
					auto_refresh = true,
				},
				filetypes = {
					markdown = true,
					text = true,
          ["*"] = true,
				},
			})

      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuOpen",
        callback = function()
          vim.b.copilot_suggestion_hidden = true
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuClose",
        callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
      })
		end,
	},
  {
    "copilotlsp-nvim/copilot-lsp",
    enabled = false,
    init = function()
      vim.g.copilot_nes_debounce = 500
      vim.lsp.enable("copilot_ls")

      local complete = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local state = vim.b[bufnr].nes_state
        if state then
            -- Try to jump to the start of the suggestion edit.
            -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
            local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
                or (
                    require("copilot-lsp.nes").apply_pending_nes()
                    and require("copilot-lsp.nes").walk_cursor_end_edit()
                )
            return nil
        else
            -- Resolving the terminal's inability to distinguish between `TAB` and `<C-i>` in normal mode
            return "<C-i>"
        end
      end

      vim.keymap.set("n", "<tab>", complete, { desc = "accept copilot suggestion", expr = true })

    end,
  },
	{
		"ravitemer/mcphub.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"zbirenbaum/copilot.lua",
		},
		keys = {
			{
				"<leader>am",
				function()
					vim.cmd([[MCPHub]])
				end,
				desc = "toggle MCP Hub",
			},
		},
		build = "bundled_build.lua",
		opts = {
			use_bundled_binary = true,
			port = 37373,
			config = vim.fn.expand("~/.config/mcphub/servers.json"),
			extensions = {
				avante = {
					make_slash_commands = true,
				},
			},
		},
		config = function(_, opts)
			require("mcphub").setup(opts)
		end,
	},
	{
		"yetone/avante.nvim",
		build = function()
			return "make"
		end,
		event = "VeryLazy",
		version = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-telescope/telescope.nvim",
			"stevearc/dressing.nvim",
			"folke/snacks.nvim",
			"nvim-tree/nvim-web-devicons",
			"zbirenbaum/copilot.lua",
			"ravitemer/mcphub.nvim",
			{
				-- image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						use_absolute_file_path = true,
					},
				},
			},
			{
				"meanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
		keys = {
			{
				chat_keys.toggle,
				function()
					vim.cmd("AvanteToggle")
				end,
			},
		},
		---@module 'avante'
		---@type avante.Config
		opts = {
			provider = "copilot",
			system_prompt = function()
				local hub = require("mcphub").get_hub_instance()
				return hub and hub:get_active_servers_prompt() or ""
			end,
			custom_tools = function()
				return {
					require("mcphub.extensions.avante").mcp_tool(),
				}
			end,
		},
	},
}
