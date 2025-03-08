local config = require("vue-component-creator.config")
local commands = require("vue-component-creator.commands")
local core = require("vue-component-creator.core")

local M = {}

M.create_component = core.create_component
M.select_path_and_create = core.select_path_and_create

M.setup = function(opts)
	config.setup(opts)
	commands.setup()
	return M
end

return M
