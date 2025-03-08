local config = require("vue-component-creator.config")

local M = {}

M.format_text = function(text)
	if not text or text == "" then
		return ""
	end

	local indent_size = config.values.indent_size
	local lines = vim.split(text, "\n")
	local formatted_lines = {}

	for _, line in ipairs(lines) do
		if line:match("^%s*$") then
			table.insert(formatted_lines, "")
		else
			local trimmed = line:match("^%s*(.*)$") or ""
			table.insert(formatted_lines, string.rep(" ", indent_size) .. trimmed)
		end
	end

	while #formatted_lines > 0 and formatted_lines[#formatted_lines] == "" do
		table.remove(formatted_lines)
	end

	return table.concat(formatted_lines, "\n")
end

M.normalize_path = function(path)
	if not path:match("/$") then
		return path .. "/"
	end
	return path
end

return M
