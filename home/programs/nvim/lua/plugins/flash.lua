return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
	opts = {
		---@type table<string, Flash.Config>
		modes = {
			search = {
				enabled = true,
				jump = { nohlsearch = false },
			},
		},
		label = {
			rainbow = {
				enabled = true,
				shade = 5, -- 1-9
			},
		},
	},
  -- stylua: ignore
  keys = {
    {
      "<leader>fs",
      mode = { "n", "x", "o" },
      function() require("flash").jump() end,
      desc = "flash",
    },
    {
      "<leader>fS",
      mode = { "n", "x", "o" },
      function() require("flash").treesitter() end,
      desc = "flash Treesitter",
    },
    {
      "<leader>fr",
      mode = "o",
      function() require("flash").remote() end,
      desc = "remote Flash"
    },
    {
      "<leader>fR",
      mode = { "o", "x" },
      function() require("flash").treesitter_search() end,
      desc = "treesitter Search",
    },
    {
      "<c-s>",
      mode = { "c" },
      function() require("flash").toggle() end,
      desc = "toggle Flash Search",
    },
    {
      "<leader>fw",
      mode = { "n", "x", "o" },
      function()
        require("flash")
            .jump({
              pattern = vim.fn.expand("<cword>")
            })
      end,
      desc = "flash Word Under Cursor",
    },
  },
}
