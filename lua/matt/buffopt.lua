local buffopt = {}

function buffopt.tabsize(size)
	vim.bo.tabstop = size
	vim.bo.shiftwidth = size
	vim.bo.softtabstop = size
end

function buffopt.setup_ts()
	vim.bo.expandtab = false
	buffopt.tabsize(2)
end

return buffopt
