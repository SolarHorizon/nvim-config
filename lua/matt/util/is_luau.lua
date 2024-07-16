local function is_luau()
	local found = vim.fs.find(function(name)
		return name == ".luaurc"
			or name == "wally.toml"
			or name:match(".*%.project%.json$")
			or name:match(".*%.luau$")
	end, {
		upward = true,
		stop = vim.loop.os_homedir(),
		path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
	})

	return #found > 0
end

return is_luau
