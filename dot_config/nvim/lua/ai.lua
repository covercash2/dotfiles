local plugin = {
	"github/copilot.vim",
  config = function()
    vim.g.copilot_workspace_folders = {"~/nuenv/"}
  end
}

return {
	spec = plugin,
}
