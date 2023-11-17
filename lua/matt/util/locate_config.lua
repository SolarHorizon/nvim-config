local function locate_config(names)
	return vim.fs.find(names, {
		upward = true,
		stop = vim.loop.os_homedir(),
		path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
	})
end

return locate_config
