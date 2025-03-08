local M = {}

M.is_typescript_project = function()
	local ts_config_files = {
		"tsconfig.json",
		"vite.config.ts",
		"package.json",
	}

	for _, file in ipairs(ts_config_files) do
		if vim.fn.filereadable(file) == 1 then
			if file == "package.json" then
				local content = vim.fn.readfile(file)
				local package_json = table.concat(content, "\n")

				if
					package_json:match('"typescript"')
					or package_json:match('"@vue/typescript"')
					or package_json:match('"ts%-node"')
					or package_json:match('"vue%-tsc"')
				then
					return true
				end
			else
				return true
			end
		end
	end

	if vim.fn.isdirectory("src") == 1 then
		local ts_files = vim.fn.glob("src/**/*.ts", true, true)
		if #ts_files > 0 then
			return true
		end
	end

	return false
end

M.get_best_template_type = function(requested_type)
	local config = require("vue-component-creator.config")

	if requested_type and config.values.templates[requested_type] then
		return requested_type
	end

	local has_ts_template = config.values.templates.typescript ~= nil

	if config.values.force_typescript and has_ts_template then
		if requested_type == "template_only" then
			return "template_only"
		end
		return "typescript"
	end

	if M.is_typescript_project() and has_ts_template then
		if requested_type == "default" then
			return "typescript"
		elseif requested_type == "template_only" then
			return "template_only"
		end

		return "typescript"
	end

	return requested_type or "default"
end

return M
