local get_git_root = require("matt/util/get_git_root")

local function is_luau()
	local found = vim.fs.find(function(name)
		return name == ".luaurc"
			or name == "pesde.toml"
			or name == "wally.toml"
			or name:match(".*%.project%.json$")
			or name:match(".*%.luau$")
	end, {
		limit = 1,
		path = get_git_root(),
		upward = false,
	})

	return #found > 0
end

return is_luau
