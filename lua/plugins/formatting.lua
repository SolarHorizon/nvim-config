return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				luau = { "stylua" },
				javascript = {
					"prettierd",
					"prettier",
					stop_after_first = true,
				},
				typescript = {
					"prettierd",
					"prettier",
					stop_after_first = true,
				},
				json = {
					"prettierd",
					"prettier",
					stop_after_first = true,
				},
				rust = { "rustfmt" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},
}
