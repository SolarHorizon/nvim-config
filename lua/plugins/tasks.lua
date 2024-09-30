local get_rojo_projects = require("matt/util/get_rojo_projects")

return {
	"stevearc/overseer.nvim",
	opts = {},
	init = function()
		local overseer = require("overseer")

		if #get_rojo_projects() > 0 then
			overseer.register_template({
				name = "Start Rojo Server",
				priority = 0,
				builder = function()
					return {
						cmd = { "rojo" },
						args = { "serve" },
						name = "Rojo Server",
					}
				end,
			})
		end

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
