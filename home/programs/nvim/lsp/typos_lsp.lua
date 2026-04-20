-- https://github.com/tekumara/typos-lsp/blob/main/docs/neovim-lsp-config.md
return {
	cmd_env = { RUST_LOG = "error" },
	init_options = {
		diagnoseSeverity = "Error",
	},
}
