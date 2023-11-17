return {
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
}
