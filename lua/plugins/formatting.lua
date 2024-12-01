local prettier = {
	"prettierd",
	"prettier",
	stop_after_first = true,
}

return {
	{
		"stevearc/conform.nvim",
		---@module "conform"
		---@type conform.setupOpts
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				luau = { "stylua" },
				rust = { "rustfmt" },
				nix = { "alejandra" },

				javascript = prettier,
				typescript = prettier,
				javascriptreact = prettier,
				typescriptreact = prettier,
				json = prettier,
			},
			format_on_save = {
				timeout_ms = 500,
			},
		},
	},
	{
		"nmac427/guess-indent.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = {},
	},
}
