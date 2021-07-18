local sumneko_root = vim.fn.expand("$HOME") .. "/.config/nvim/lua-language-server"
local os_string = ""

if vim.fn.has("mac") == 1 then
	os_string = "macOS"
elseif vim.fn.has("unix") == 1 then
	os_string = "Linux"
else
	print("Unsupported OS detected")
end

