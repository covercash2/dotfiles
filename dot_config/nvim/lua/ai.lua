-- local plugin = {
-- 	"github/copilot.vim",
--   config = function()
--     vim.g.copilot_workspace_folders = {"~/nuenv/"}
--   end
-- }

local copilot = {
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
}

local mcp = {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "bun install -g mcp-hub@latest",
  opts = {
    port = 373737,
    config = vim.fn.expand("~/.config/mcphub/servers.json"),
  }
}

local copilot_chat = {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "zbirenbaum/copilot.lua" },
    { "nvim-lua/plenary.nvim", branch = "master" },
  },
  keys = {
    {
      "<leader>ac",
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

local avante = {
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
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = "copilot",
  },
}

return {
  copilot = copilot,
  mcp = mcp,
  chat = copilot_chat,
}
