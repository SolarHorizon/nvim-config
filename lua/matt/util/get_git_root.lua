local function get_git_root(buf)
	return vim.fs.root(buf or 0, ".git")
end

return get_git_root
