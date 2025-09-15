-- edit_section.lua - Ephemeral buffer editing for nested/embedded code sections
-- Allows editing code sections in isolation with proper filetype support

local M = {}

-- Default configuration
local config = {
	-- Window configuration for the ephemeral buffer
	window = {
		width = 0.8,
		height = 0.8,
		border = "rounded",
		title = " Edit Section ",
		title_pos = "center",
	},
	-- Auto-detection patterns for common embedded code scenarios
	patterns = {
		-- YAML with embedded XML/HTML
		{ pattern = "^%s*%w+:%s*|%s*$", filetype = "xml", context_lines = 1 },
		-- JSON with embedded SQL
		{ pattern = '"sql":%s*"', filetype = "sql", context_lines = 0 },
		-- Markdown code blocks
		{ pattern = "^```(%w+)", filetype = "%1", context_lines = 0 },
		-- HTML script tags
		{ pattern = "<script[^>]*>", filetype = "javascript", context_lines = 0 },
		-- CSS in HTML
		{ pattern = "<style[^>]*>", filetype = "css", context_lines = 0 },
	},
	-- Keymaps for the ephemeral buffer
	keymaps = {
		save_and_close = "<C-s>",
		close_without_save = "<Esc>",
		toggle_original = "<C-o>",
	},
}

-- Internal state to track edit sessions
local sessions = {}

---@class EditSectionOpts
---@field range? {start_line: number, end_line: number} | "visual" | "auto"
---@field filetype? string Target filetype for the ephemeral buffer
---@field title? string Custom title for the window
---@field detect_filetype? boolean Whether to auto-detect filetype (default: true)
---@field preserve_indent? boolean Whether to preserve original indentation (default: true)

---@class EditSession
---@field original_bufnr number
---@field original_range {start_line: number, end_line: number}
---@field ephemeral_bufnr number
---@field ephemeral_winnr number
---@field original_content string[]
---@field base_indent string
---@field filetype string

-- Helper function to detect filetype based on context
local function detect_filetype_from_context(bufnr, start_line, end_line)
	local lines = vim.api.nvim_buf_get_lines(bufnr, math.max(0, start_line - 3), end_line + 3, false)

	for _, pattern_config in ipairs(config.patterns) do
		for _, line in ipairs(lines) do
			local match = line:match(pattern_config.pattern)
			if match then
				if pattern_config.filetype:find("%%1") then
					return pattern_config.filetype:gsub("%%1", match)
				else
					return pattern_config.filetype
				end
			end
		end
	end

	return nil
end

-- Helper function to get visual selection range
local function get_visual_range()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	return {
		start_line = start_pos[2] - 1, -- Convert to 0-based indexing
		end_line = end_pos[2] - 1,
	}
end

-- Helper function to detect range around cursor
local function detect_range_from_cursor()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-based
	local bufnr = vim.api.nvim_get_current_buf()
	local total_lines = vim.api.nvim_buf_line_count(bufnr)

	-- Simple heuristic: find blank lines or indentation changes
	local start_line = cursor_line
	local end_line = cursor_line

	-- Expand backwards
	while start_line > 0 do
		local line = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1]
		if not line or line:match("^%s*$") then
			break
		end
		start_line = start_line - 1
	end

	-- Expand forwards
	while end_line < total_lines - 1 do
		local line = vim.api.nvim_buf_get_lines(bufnr, end_line + 1, end_line + 2, false)[1]
		if not line or line:match("^%s*$") then
			break
		end
		end_line = end_line + 1
	end

	return {
		start_line = start_line,
		end_line = end_line,
	}
end

-- Helper function to calculate base indentation
local function get_base_indent(lines)
	local min_indent = math.huge
	local indent_char = " "

	for _, line in ipairs(lines) do
		if not line:match("^%s*$") then -- Skip empty lines
			local indent = line:match("^(%s*)")
			if #indent < min_indent then
				min_indent = #indent
				if #indent > 0 then
					indent_char = indent:sub(1, 1) -- Get first char (space or tab)
				end
			end
		end
	end

	return string.rep(indent_char, min_indent == math.huge and 0 or min_indent)
end

-- Helper function to remove base indentation
local function remove_base_indent(lines, base_indent)
	local result = {}
	local indent_len = #base_indent

	for _, line in ipairs(lines) do
		if line:match("^%s*$") then
			table.insert(result, "")
		elseif line:sub(1, indent_len) == base_indent then
			table.insert(result, line:sub(indent_len + 1))
		else
			table.insert(result, line)
		end
	end

	return result
end

-- Helper function to restore base indentation
local function restore_base_indent(lines, base_indent)
	local result = {}

	for _, line in ipairs(lines) do
		if line:match("^%s*$") then
			table.insert(result, "")
		else
			table.insert(result, base_indent .. line)
		end
	end

	return result
end

-- Create and configure the ephemeral buffer
local function create_ephemeral_buffer(session)
	local bufnr = vim.api.nvim_create_buf(false, true) -- nofile, scratch buffer

	-- Set buffer options
	vim.bo[bufnr].filetype = session.filetype
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].bufhidden = "wipe"

	-- Calculate window dimensions
	local ui = vim.api.nvim_list_uis()[1]
	local width = math.floor(ui.width * config.window.width)
	local height = math.floor(ui.height * config.window.height)
	local row = math.floor((ui.height - height) / 2)
	local col = math.floor((ui.width - width) / 2)

	-- Create floating window
	local winnr = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = config.window.border,
		title = config.window.title .. "(" .. session.filetype .. ")",
		title_pos = config.window.title_pos,
		style = "minimal",
	})

	return bufnr, winnr
end

-- Set up keymaps for the ephemeral buffer
local function setup_ephemeral_keymaps(session)
	local bufnr = session.ephemeral_bufnr
	local opts = { buffer = bufnr, noremap = true, silent = true }

	-- Save and close
	vim.keymap.set("n", config.keymaps.save_and_close, function()
		M.save_and_close_session(session)
	end, opts)

	-- Close without saving
	vim.keymap.set("n", config.keymaps.close_without_save, function()
		M.close_session(session)
	end, opts)

	-- Toggle between original and ephemeral buffer
	vim.keymap.set("n", config.keymaps.toggle_original, function()
		M.toggle_original_buffer(session)
	end, opts)
end

-- Save ephemeral buffer content back to original
function M.save_and_close_session(session)
	if not vim.api.nvim_buf_is_valid(session.ephemeral_bufnr) then
		return
	end

	-- Get modified content from ephemeral buffer
	local modified_lines = vim.api.nvim_buf_get_lines(session.ephemeral_bufnr, 0, -1, false)

	-- Restore indentation if preserve_indent is enabled
	if session.preserve_indent and session.base_indent and #session.base_indent > 0 then
		modified_lines = restore_base_indent(modified_lines, session.base_indent)
	end

	-- Replace content in original buffer
	vim.api.nvim_buf_set_lines(
		session.original_bufnr,
		session.original_range.start_line,
		session.original_range.end_line + 1,
		false,
		modified_lines
	)

	-- Close the session
	M.close_session(session)

	print("Section saved and closed")
end

-- Close session without saving
function M.close_session(session)
	if vim.api.nvim_win_is_valid(session.ephemeral_winnr) then
		vim.api.nvim_win_close(session.ephemeral_winnr, true)
	end

	if vim.api.nvim_buf_is_valid(session.ephemeral_bufnr) then
		vim.api.nvim_buf_delete(session.ephemeral_bufnr, { force = true })
	end

	-- Remove from sessions table
	sessions[session.ephemeral_bufnr] = nil

	-- Return to original buffer
	if vim.api.nvim_buf_is_valid(session.original_bufnr) then
		vim.api.nvim_set_current_buf(session.original_bufnr)
	end
end

-- Toggle between original and ephemeral buffer
function M.toggle_original_buffer(session)
	local current_buf = vim.api.nvim_get_current_buf()

	if current_buf == session.ephemeral_bufnr then
		-- Switch to original
		if vim.api.nvim_buf_is_valid(session.original_bufnr) then
			vim.api.nvim_set_current_buf(session.original_bufnr)
			-- Position cursor at the edited section
			vim.api.nvim_win_set_cursor(0, { session.original_range.start_line + 1, 0 })
		end
	else
		-- Switch back to ephemeral
		if vim.api.nvim_win_is_valid(session.ephemeral_winnr) then
			vim.api.nvim_set_current_win(session.ephemeral_winnr)
		end
	end
end

-- Main function to edit a section
function M.edit_section(opts)
	opts = opts or {}

	local original_bufnr = vim.api.nvim_get_current_buf()
	local range

	-- Determine range
	if opts.range == "visual" then
		range = get_visual_range()
	elseif opts.range == "auto" or not opts.range then
		range = detect_range_from_cursor()
	elseif type(opts.range) == "table" then
		range = opts.range
	else
		error("Invalid range specification")
	end

	-- Get content
	local original_content = vim.api.nvim_buf_get_lines(original_bufnr, range.start_line, range.end_line + 1, false)

	if #original_content == 0 then
		print("No content to edit")
		return
	end

	-- Determine filetype
	local filetype = opts.filetype
	if not filetype and opts.detect_filetype ~= false then
		filetype = detect_filetype_from_context(original_bufnr, range.start_line, range.end_line)
	end

	if not filetype then
		filetype = vim.bo[original_bufnr].filetype or "text"
	end

	-- Calculate base indentation
	local base_indent = ""
	local content_for_editing = original_content

	if opts.preserve_indent ~= false then
		base_indent = get_base_indent(original_content)
		if #base_indent > 0 then
			content_for_editing = remove_base_indent(original_content, base_indent)
		end
	end

	-- Create session
	local session = {
		original_bufnr = original_bufnr,
		original_range = range,
		original_content = original_content,
		base_indent = base_indent,
		filetype = filetype,
		preserve_indent = opts.preserve_indent ~= false,
	}

	-- Create ephemeral buffer and window
	session.ephemeral_bufnr, session.ephemeral_winnr = create_ephemeral_buffer(session)

	-- Set content in ephemeral buffer
	vim.api.nvim_buf_set_lines(session.ephemeral_bufnr, 0, -1, false, content_for_editing)

	-- Store session
	sessions[session.ephemeral_bufnr] = session

	-- Set up keymaps
	setup_ephemeral_keymaps(session)

	-- Set up autocmd to clean up if buffer is deleted unexpectedly
	vim.api.nvim_create_autocmd("BufDelete", {
		buffer = session.ephemeral_bufnr,
		callback = function()
			sessions[session.ephemeral_bufnr] = nil
		end,
		once = true,
	})

	print(
		"Editing section as "
			.. filetype
			.. " (Use "
			.. config.keymaps.save_and_close
			.. " to save, "
			.. config.keymaps.close_without_save
			.. " to cancel)"
	)
end

-- Command interface
function M.edit_section_command(args)
	local opts = {}

	-- Parse command arguments
	if args.range == 2 then
		-- Range was provided
		opts.range = {
			start_line = args.line1 - 1, -- Convert to 0-based
			end_line = args.line2 - 1,
		}
	else
		-- Check if we're in visual mode
		local mode = vim.fn.mode()
		if mode == "v" or mode == "V" or mode == "\22" then -- \22 is Ctrl-V
			opts.range = "visual"
		else
			opts.range = "auto"
		end
	end

	-- Parse filetype argument
	if args.args and #args.args > 0 then
		opts.filetype = args.args
	end

	M.edit_section(opts)
end

-- Setup function to configure the plugin
function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})

	-- Create user command
	vim.api.nvim_create_user_command("EditSection", function(args)
		M.edit_section_command(args)
	end, {
		range = true,
		nargs = "?",
		desc = "Edit section in ephemeral buffer with specified filetype",
	})

	-- Set up default keymaps if desired
	-- if config.global_keymaps then
	vim.keymap.set("v", "<leader>es", ":EditSection<CR>", { desc = "Edit selection in ephemeral buffer" })
	vim.keymap.set("n", "<leader>es", ":EditSection<CR>", { desc = "Edit section in ephemeral buffer" })
	-- end
end

-- API for getting active sessions (useful for debugging)
function M.get_active_sessions()
	return sessions
end

-- API for configuring patterns
function M.add_pattern(pattern_config)
	table.insert(config.patterns, pattern_config)
end

return M
