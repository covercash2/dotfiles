local chat_keys = {
  toggle = "<leader>at",
}

local copilot_chat = {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "zbirenbaum/copilot.lua" },
    { "nvim-lua/plenary.nvim", branch = "master" },
  },
  keys = {
    {
      chat_keys.toggle,
      function()
        require("CopilotChat").toggle()
      end,
      desc = "toggle Copilot chat",
    },
  },
  build = "make tiktoken",
  opts = {
    model = "claude-sonnet-4",
  },
}

return {
  {
    "zbirenbaum/copilot.lua",
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
        panel = {
          auto_refresh = true,
        },
        filetypes = {
          markdown = true,
          text = true,
        },
      })
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
    build = "npm install -g mcp-hub@latest",
    opts = {
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
    build = function() return "make" end,
    event = "VeryLazy",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
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
      }
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
  }
}
