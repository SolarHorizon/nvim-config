local get_git_root = require("matt/util/get_git_root")

local function is_roblox()
	local found = vim.fs.find(function(name)
		return name == "wally.toml"
			or name:match("^roblox_.*_?packages$")
			or name:match(".*%.project%.json$")
	end, {
		limit = 1,
		path = get_git_root(),
		upward = false,
	})

	return #found > 0
end

return is_roblox
