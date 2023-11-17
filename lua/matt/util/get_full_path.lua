return function(path, opts)
	path = path:gsub("^./", "$PWD/")
	return vim.fs.normalize(path, opts)
end
