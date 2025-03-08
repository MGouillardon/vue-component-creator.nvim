local M = {}

M.values = {
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

M.setup = function(opts)
	if not opts then
		return
	end

	for key, value in pairs(opts) do
		if key == "templates" and type(value) == "table" then
			for template_key, template_value in pairs(value) do
				M.values.templates[template_key] = template_value
			end
		else
			M.values[key] = value
		end
	end
end

return M
