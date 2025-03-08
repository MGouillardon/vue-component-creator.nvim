local M = {}

M.ensure_directory = function(dir_path)
	if vim.fn.isdirectory(dir_path) == 0 then
		local success, error_msg = pcall(function()
			vim.fn.mkdir(dir_path, "p")
		end)

		if not success then
			error("Failed to create directory: " .. error_msg)
		end

		vim.notify("Directory created: " .. dir_path, vim.log.levels.INFO)
	end
	return true
end

M.safe_write_file = function(path, content)
	local success, error_msg = pcall(function()
		vim.fn.writefile(vim.split(content, "\n"), path)
	end)

	if not success then
		error("Failed to write file: " .. error_msg)
	end
	return true
end

M.file_exists = function(path)
	return vim.fn.filereadable(path) == 1
end

return M
