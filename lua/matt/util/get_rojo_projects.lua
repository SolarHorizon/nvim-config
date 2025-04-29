local get_git_root = require("matt/util/get_git_root")

local function get_rojo_projects()
	return vim.fs.find(function(name)
		return name:match(".*%.project%.json$")
	end, {
		type = "file",
		limit = math.huge,
		path = get_git_root(),
	})
end

return get_rojo_projects
