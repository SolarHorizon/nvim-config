return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local parser_configs =
			require("nvim-treesitter.parsers").get_parser_configs()

		parser_configs.just = {
			install_info = {
				url = "https://github.com/IndianBoy42/tree-sitter-just",
				files = { "src/parser.c", "src/scanner.cc" },
				branch = "main",
			},
		}

		local luau_path = vim.fs.normalize("~/.local/src/tree-sitter-luau")

		parser_configs.luau = {
			install_info = {
				url = luau_path,
				files = { "src/parser.c", "src/scanner.c" },
			},
		}

		for _, v in pairs({
			"highlights",
			"indents",
			"folds",
			"injections",
			"locals",
		}) do
			local fd = io.open(luau_path .. "/nvim-queries/" .. v .. ".scm")

			assert(
				fd,
				"Could not find any .scm files under "
					.. luau_path
					.. "/nvim-queries/"
			)

			local txt = fd:read("*a")
			fd:close()
			vim.treesitter.query.set("luau", v, txt)
		end

		require("nvim-treesitter.configs").setup({
			highlight = {
				enable = true,
			},
		})
	end,
	dependencies = {
		"nvim-treesitter/playground",
		"IndianBoy42/tree-sitter-just",
	},
}
