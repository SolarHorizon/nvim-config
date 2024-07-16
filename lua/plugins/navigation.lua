return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		name = "neo-tree",
		branch = "v3.x",
		opts = {
			event_handlers = {
				{
					event = "file_opened",
					handler = function()
						require("neo-tree").close_all()
					end,
				},
			},
		},
		init = function()
			local wk = require("which-key")

			wk.add({
				{ "<leader>t", group = "Neo Tree" },
				{ "<leader>tt", cmd = "<cmd>Neotree toggle<cr>", desc = "Toggle File Tree" },
				{ "<leader>tb", cmd = "<cmd>Neotree toggle<cr>", desc = "Toggle Buffer Tree" },
				{ "T", cmd = "<cmd>Neotree toggle<cr>", desc = "Toggle File Tree" }
			})
		end,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"folke/which-key.nvim",
		},
	},
	{
		"nvim-telescope/telescope.nvim",
		init = function()
			-- enable syntax highlighting for unsupported filetypes in preview
			require("plenary.filetype").add_file("luau")
			require("plenary.filetype").add_file("just")

			local wk = require("which-key")
			local builtin = require("telescope.builtin")

			wk.add({
				{ "<leader>f", group = "Files" },
				{ "<leader>ff", builtin.find_files, desc = "Find File" },
				{ "<leader>fg", builtin.find_files, desc = "Live Grep" },
				{ "<leader>fr", builtin.old_files, desc = "Recent Files" },
				{"<c-p>", builtin.find_files, desc = "Find File" },
				{"<c-g>", builtin.live_grep, desc = "Live Grep" },
			})
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	-- {
	-- 	"ThePrimeagen/harpoon",
	-- 	branch = "harpoon2",
	-- 	opts = {},
	-- 	init = function()
	-- 		local ui = require("harpoon.ui")
	-- 		local mark = require("harpoon.mark")
	-- 		local term = require("harpoon.term")

	-- 		local function nav_file(number)
	-- 			return function()
	-- 				ui.nav_file(number)
	-- 			end
	-- 		end

	-- 		local function terminal(number)
	-- 			return function()
	-- 				term.gotoTerminal(number)
	-- 			end
	-- 		end

	-- 		local wk = require("which-key")
	-- 		wk.register({
	-- 			a = { mark.add_file, "Harpoon Mark File" },
	-- 			h = { ui.toggle_quick_menu, "Harpoon Quick Menu" },
	-- 			t = { terminal(1), "Harpoon Terminal" },
	-- 			[1] = { nav_file(1), "Harpoon File 1" },
	-- 			[2] = { nav_file(2), "Harpoon File 2" },
	-- 			[3] = { nav_file(3), "Harpoon File 3" },
	-- 			[4] = { nav_file(4), "Harpoon File 4" },
	-- 			[5] = { nav_file(5), "Harpoon File 5" },
	-- 		}, {
	-- 			prefix = "<leader>",
	-- 		})
	-- 	end,
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"folke/which-key.nvim",
	-- 	},
	-- },
}
