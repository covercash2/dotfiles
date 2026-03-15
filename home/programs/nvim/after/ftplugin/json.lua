if vim.fn.exists("+winbar") == 1 then
	vim.opt_local.winbar = "%{%v:lua.require'jsonpath'.get()%}"
end

local copy_json_path = function()
	vim.fn.setreg("+", require('jsonpath').get())
end

vim.keymap.set("n", "<leader>yj", copy_json_path,
	{ desc = "copy json path", buffer = true })
