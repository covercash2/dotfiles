local opts = {
	model = "mistral-nemo",
	url = "http://192.168.2.136:11434",
	show_prompt = true,
	show_model = true,
	prompts = {
		generate_comment = {
			prompt = "Generate a docstring for the following code:\n" ..
			"```$ftype\n$sel```"
		}
	}
}

local keys = {
	mode = { 'n', 'v' },
	{
		"<leader>ar",
		function()
			require('ollama').prompt("Explain_Code")
		end,
		desc = "review selected code",
	},
	{
		"<leader>ai",
		function()
			require('ollama').prompt()
		end,
		desc = "pick a prompt"
	},
}

local plugin = {
	"nomnivore/ollama.nvim",
	cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },
	opts = opts
	-- 	gen.prompts['function_comment_add'] = {
	-- 		prompt = "I want to generate documentation for my $filetype code. " ..
	-- 				"The documentation should be rendered with the standard documentation tooling, " ..
	-- 				"for example rustdoc for Rust or javadoc for Java. " ..
	-- 				"Note that in rust, block comments (like `/** */`) are considered bad practice. " ..
	-- 				"Here is the code I would like to document:\n\n" ..
	-- 				"```$filetype\n$text\n```" ..
	-- 				"In Rust, to be very fucking clear: docstrings begin with `///`. " ..
	-- 				"Generate a valid docstring. " ..
	-- 				"The only output should be the documenation in a code block in the following format:" ..
	-- 				"\n\n```$filetype\n...\n```",
	-- 		replace = false,
	-- 	}
}

return {
	spec = plugin,
	keys = keys,
	opts = opts,
}
