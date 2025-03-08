local core = require("vue-component-creator.core")

local M = {}

M.setup = function()
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
			core.create_component(cmd_opts.args, template_type, selected_text)
		else
			core.select_path_and_create(template_type, selected_text)
		end
	end

	local commands = {
		{ name = "VueComponent", type = "default", desc = "Create a new Vue component with script and template" },
		{
			name = "VueTemplate",
			type = "template_only",
			desc = "Create a new Vue component with template only",
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
end

return M
