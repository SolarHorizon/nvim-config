return {
	--{
	--	"stevearc/resession.nvim",
	--	opt = {
	--		autosave = {
	--			enabled = true,
	--			interval = 60,
	--			notify = true,
	--		},
	--		extensions = {
	--			overseer = {},
	--		},
	--	},
	--	init = function()
	--		local resession = require("resession")

	--		-- Save current session as "last" when exiting
	--		vim.api.nvim_create_autocmd("VimLeavePre", {
	--			callback = function()
	--				resession.save("last")
	--			end,
	--		})

	--		-- Load "last" session when opening nvim with no arguments
	--		vim.api.nvim_create_autocmd("VimEnter", {
	--			callback = function()
	--				if vim.fn.argc(-1) == 0 then
	--					resession.load("last")
	--				end
	--			end,
	--		})

	--		local wk = require("which-key")

	--		wk.add({
	--			{ "<leader>s", group = "Session" },
	--			{ "<leader>ss", resession.save, desc = "Save session" },
	--			{ "<leader>sl", resession.load, desc = "Save session" },
	--			{ "<leader>sd", resession.delete, desc = "Save session" },
	--		})
	--	end,
	--},
}
