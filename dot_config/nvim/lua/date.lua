-- NOTE: source neovim Lua files with `luafile <file>`

local function insert_date()
	local date_raw = vim.fn.system({ "date" })
	-- remove null char from the end -> `date = date[0..-1]`
	local date = string.sub(date_raw, 1, string.len(date_raw) - 1)
	vim.api.nvim_put({ date }, "b", true, true)
end

vim.api.nvim_create_user_command("InsertDate", insert_date, {})

vim.keymap.set("n", "<leader>idd", insert_date, { desc = "insert the current date with default formatting" })

local M = {
	insert_date = insert_date,
}

return M
