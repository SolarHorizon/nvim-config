return {
	"stevearc/overseer.nvim",
	opts = {},
	init = function()
		local wk = require("which-key")

		wk.add({
			{ "<leader>o", group = "Overseer" },
			{
				"<leader>ot",
				cmd = "<cmd>OverseerToggle<cr>",
				desc = "Toggle Overseer",
			},
			{
				"<leader>or",
				cmd = "<cmd>OverseerRun<cr>",
				desc = "Overseer Run",
			},
			{
				"<leader>oi",
				cmd = "<cmd>OverseerInfo<cr>",
				desc = "Overseer Info",
			},
		})
	end,
}
