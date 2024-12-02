local locate_config = require("matt/util/locate_config")

local project_file_names = {
	"dev",
	"test",
	"build",
	"default",
}

for i, name in ipairs(project_file_names) do
	project_file_names[i] = name .. ".project.json"
end

return function()
	return locate_config(project_file_names)
end
