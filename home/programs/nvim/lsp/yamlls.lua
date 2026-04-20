return {
	settings = {
		yaml = {
			schemaStore = {
				-- Disable built-in schemaStore support in favor of schemastore.nvim
				enable = false,
				url = "",
			},
			schemas = require("schemastore").yaml.schemas(),
			validate = true,
			hover = true,
			completion = true,
		},
	},
}
