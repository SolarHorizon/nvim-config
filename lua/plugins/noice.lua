return {
	{
		"rcarriga/nvim-notify",
		config = function()
			local colors = require("tokyonight.colors").setup()

			require("notify").setup({
				background_colour = colors.bg_dark,
			})

			require("telescope").load_extension("notify")
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim",
			"folke/tokyonight.nvim",
		},
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			cmdline = {
				enabled = false,
			},
			messages = {
				enabled = false,
			},
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
			presets = {
				bottom_search = true,
				command_palette = false,
				long_message_to_split = true,
				lsp_doc_border = true,
			},
			views = {
				mini = {
					position = { row = -3 },
					win_options = {
						winblend = 0,
					},
				},
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
			"nvim-treesitter/nvim-treesitter",
		},
	},
}
