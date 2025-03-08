local config = require("vue-component-creator.config")
local utils = require("vue-component-creator.utils")
local file_ops = require("vue-component-creator.file_ops")
local templates = require("vue-component-creator.templates")
local ts_detector = require("vue-component-creator.ts_detector")

local M = {}

M.create_component = function(path, template_type, selected_text)
	if not path or path == "" then
		vim.notify("Component path is required", vim.log.levels.ERROR)
		return
	end

	local ts_project = ts_detector.is_typescript_project()
	local force_ts = config.values.force_typescript or false

	if ts_project or force_ts then
		vim.notify("TypeScript project detected or forced in config", vim.log.levels.INFO)

		if template_type == "default" and config.values.templates.typescript then
			template_type = "typescript"
		end
	end

	local template_type_str = template_type or "default"
	vim.notify("Using template type: " .. template_type_str, vim.log.levels.INFO)

	local content
	local success, err = pcall(function()
		content = templates.apply_template(template_type_str, selected_text or "")
	end)

	if not success then
		vim.notify(err, vim.log.levels.ERROR)
		return
	end

	local components_base = config.values.components_dir
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

	if file_ops.file_exists(full_file_path) then
		vim.notify("Component " .. full_file_path .. " already exists", vim.log.levels.WARN)
		return
	end

	local write_success, error_msg = pcall(function()
		file_ops.ensure_directory(full_dir_path)
		file_ops.safe_write_file(full_file_path, content)
	end)

	if not write_success then
		vim.notify(error_msg, vim.log.levels.ERROR)
		return
	end

	vim.cmd("edit " .. full_file_path)

	vim.cmd("normal! gg")

	if selected_text and selected_text ~= "" then
		vim.cmd([[silent! /\v\<template\>\s*$]])
		vim.cmd("normal! j" .. string.rep("l", config.values.indent_size))
	else
		vim.cmd([[silent! /\v\<template\>\s*$]])
		vim.cmd("normal! j" .. string.rep("l", config.values.indent_size))

		local line_num = vim.fn.line(".")
		local line = vim.fn.getline(line_num)
		if line:match("^%s*$") then
			vim.fn.setline(line_num, string.rep(" ", config.values.indent_size))
		end
	end

	vim.notify("Component successfully created: " .. full_file_path, vim.log.levels.INFO)
end

M.select_path_and_create = function(template_type, stored_text)
	local template_type_str = template_type or "default"
	stored_text = stored_text or ""

	vim.ui.input({
		prompt = "Component path: ",
	}, function(input)
		if input and input ~= "" then
			M.create_component(input, template_type_str, stored_text)
		end
	end)
end

return M
