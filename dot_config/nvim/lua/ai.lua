-- local plugin = {
-- 	"github/copilot.vim",
--   config = function()
--     vim.g.copilot_workspace_folders = {"~/nuenv/"}
--   end
-- }

local plugin = {
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
        ["*"] = false,
        markdown = true,
        text = true,
      },
    })
  end,
}

return {
	spec = plugin,
}
