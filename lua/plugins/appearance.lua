return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			scope = {
				enabled = false,
			},
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		name = "lualine",
		opts = {
			options = {
				component_separators = { left = "", right = "" },
				globalstatus = true,
				section_separators = { left = "", right = "" },
				theme = "tokyonight",
			},
			sections = {
				lualine_c = {
					{ "filename", path = 1 },
				},
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = {
					enable = true,
				},
			})
		end,
		dependencies = {
			"nvim-treesitter/playground",
		},
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "storm",
				transparent = true,
				styles = {
					sidebars = "transparent",
					floats = "transparent",
				},
				on_highlights = function(highlights, colors)
					highlights["@comment"] = {
						fg = colors.comment,
						italic = true,
					}
					highlights["@parameter"] = {
						fg = colors.yellow,
						italic = true,
					}
				end,
			})

			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		"goolord/alpha-nvim",
		config = function()
			require("alpha").setup(require("alpha.themes.theta").config)
		end,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-lua/plenary.nvim",
		},
	},
}
