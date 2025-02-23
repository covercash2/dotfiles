-- local opts = {
-- 	model = "mistral-nemo",
-- 	url = "http://192.168.2.136:11434",
-- 	show_prompt = true,
-- 	show_model = true,
-- 	prompts = {
-- 		generate_comment = {
-- 			prompt = "Generate a docstring for the following code:\n" ..
-- 			"```$ftype\n$sel```"
-- 		}
-- 	}
-- }
--
-- local keys = {
-- 	mode = { 'n', 'v' },
-- 	{
-- 		"<leader>ar",
-- 		function()
-- 			require('ollama').prompt("Explain_Code")
-- 		end,
-- 		desc = "review selected code",
-- 	},
-- 	{
-- 		"<leader>ai",
-- 		function()
-- 			require('ollama').prompt()
-- 		end,
-- 		desc = "pick a prompt"
-- 	},
-- }

local plugin = {
	"github/copilot.vim",
  config = function()
    vim.g.copilot_workspace_folders = {"~/nuenv/"}
  end
}

return {
	spec = plugin,
}
