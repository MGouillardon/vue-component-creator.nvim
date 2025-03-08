local config = require("vue-component-creator.config")
local ts_detector = require("vue-component-creator.ts_detector")

local M = {}

M.get_template = function(template_type)
	local best_template_type = ts_detector.get_best_template_type(template_type)

	local template = config.values.templates[best_template_type]
	if not template then
		error("Invalid template type: " .. tostring(template_type))
	end
	return template
end

M.apply_template = function(template_type, selected_text)
	local template_base = M.get_template(template_type)
	local formatted_text = ""

	if selected_text and selected_text ~= "" then
		if config.values.auto_format then
			local utils = require("vue-component-creator.utils")
			formatted_text = utils.format_text(selected_text)
		else
			formatted_text = selected_text
		end
	end

	return string.format(template_base, formatted_text)
end

return M
