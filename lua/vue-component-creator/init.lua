local M = {}

M.config = {
	components_dir = "components/",
	templates = {
		default = [[<script setup>

</script>

<template>
%s
</template>]],

		template_only = [[<template>
%s
</template>]],
	},
	indent_size = 2,
	auto_format = true,
}

local utils = {
	format_text = function(text, indent_size)
		if not text or text == "" then
			return ""
		end

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
	end,

	ensure_directory = function(dir_path)
		if vim.fn.isdirectory(dir_path) == 0 then
			local success, error_msg = pcall(function()
				vim.fn.mkdir(dir_path, "p")
			end)

			if not success then
				error("Failed to create directory: " .. error_msg)
			end

			vim.notify("Dossier créé: " .. dir_path, vim.log.levels.INFO)
		end
		return true
	end,

	normalize_path = function(path)
		if not path:match("/$") then
			return path .. "/"
		end
		return path
	end,

	safe_write_file = function(path, content)
		local success, error_msg = pcall(function()
			vim.fn.writefile(vim.split(content, "\n"), path)
		end)

		if not success then
			error("Failed to write file: " .. error_msg)
		end
		return true
	end,
}

M.create_component = function(path, template_type, selected_text)
	if not path or path == "" then
		vim.notify("Le chemin du composant est requis", vim.log.levels.ERROR)
		return
	end

	local template_base = M.config.templates[template_type or "default"]
	if not template_base then
		vim.notify("Type de template invalide: " .. tostring(template_type), vim.log.levels.ERROR)
		return
	end

	local formatted_text = ""
	if selected_text and selected_text ~= "" then
		if M.config.auto_format then
			formatted_text = utils.format_text(selected_text, M.config.indent_size)
		else
			formatted_text = selected_text
		end
	end

	local template = string.format(template_base, formatted_text)

	local components_base = M.config.components_dir
	local path_utils = vim.fn.fnamemodify

	local dir_path = path_utils(path, ":h")
	local file_name = path_utils(path, ":t")

	if dir_path == "." then
		dir_path = ""
	end

	local full_dir_path = components_base
	if dir_path and dir_path ~= "" then
		full_dir_path = full_dir_path .. dir_path
	end

	if not file_name:match("%.vue$") then
		file_name = file_name .. ".vue"
	end

	local full_dir_path_normalized = utils.normalize_path(full_dir_path)
	local full_file_path = full_dir_path_normalized .. file_name

	if vim.fn.filereadable(full_file_path) == 1 then
		vim.notify("Le composant " .. full_file_path .. " existe déjà", vim.log.levels.WARN)
		return
	end

	local success, error_msg = pcall(function()
		utils.ensure_directory(full_dir_path)
		utils.safe_write_file(full_file_path, template)
	end)

	if not success then
		vim.notify(error_msg, vim.log.levels.ERROR)
		return
	end

	vim.cmd("edit " .. full_file_path)

	vim.cmd("normal! gg")

	if selected_text and selected_text ~= "" then
		vim.cmd([[silent! /\v\<template\>\s*$]])
		vim.cmd("normal! j" .. string.rep("l", M.config.indent_size))
	else
		vim.cmd([[silent! /\v\<template\>\s*$]])
		vim.cmd("normal! j" .. string.rep("l", M.config.indent_size))

		local line_num = vim.fn.line(".")
		local line = vim.fn.getline(line_num)
		if line:match("^%s*$") then
			vim.fn.setline(line_num, string.rep(" ", M.config.indent_size))
		end
	end

	vim.notify("Composant créé avec succès: " .. full_file_path, vim.log.levels.INFO)
end

M.select_path_and_create = function(template_type, stored_text)
	stored_text = stored_text or ""

	vim.ui.input({
		prompt = "Chemin du composant: ",
	}, function(input)
		if input and input ~= "" then
			M.create_component(input, template_type, stored_text)
		end
	end)
end

M.setup = function(opts)
	if opts then
		for key, value in pairs(opts) do
			if key == "templates" and type(value) == "table" then
				for template_key, template_value in pairs(value) do
					M.config.templates[template_key] = template_value
				end
			else
				M.config[key] = value
			end
		end
	end

	local execute_command = function(cmd_opts, template_type)
		local selected_text = ""

		if cmd_opts.range > 0 then
			local old_reg = vim.fn.getreg('"')
			local old_regtype = vim.fn.getregtype('"')

			vim.cmd("normal! gvd")

			selected_text = vim.fn.getreg('"')

			vim.fn.setreg('"', old_reg, old_regtype)
		end

		if cmd_opts.args and cmd_opts.args ~= "" then
			M.create_component(cmd_opts.args, template_type, selected_text)
		else
			M.select_path_and_create(template_type, selected_text)
		end
	end

	local commands = {
		{ name = "VueComponent", type = "default", desc = "Crée un nouveau composant Vue avec script et template" },
		{
			name = "VueTemplate",
			type = "template_only",
			desc = "Crée un nouveau composant Vue avec template seulement",
		},
	}

	for _, cmd in ipairs(commands) do
		vim.api.nvim_create_user_command(cmd.name, function(cmd_opts)
			execute_command(cmd_opts, cmd.type)
		end, {
			nargs = "?",
			desc = cmd.desc,
			range = true,
		})
	end

	return M
end

return M
