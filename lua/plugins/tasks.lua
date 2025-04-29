local get_rojo_projects = require("matt/util/get_rojo_projects")

return {
	"stevearc/overseer.nvim",
	opts = {},
	init = function()
		local overseer = require("overseer")
		local projects = get_rojo_projects()
		local default_project = "default.project.json"

		if vim.fn.filereadable("./sync.project.json") == 1 then
			default_project = "sync.project.json"
		end

		overseer.register_template({
			name = "Start Rojo Server",
			params = function()
				return {
					project = {
						desc = "Project to sync",
						type = "enum",
						optional = true,
						default = default_project,
						choices = projects,
					},
				}
			end,
			builder = function(params)
				return {
					name = "Rojo Server",
					cmd = { "rojo", "serve" },
					args = { params.project },
				}
			end,
			condition = {
				callback = function()
					return #projects > 0
				end,
			},
		})

		if #projects > 0 then
			vim.api.nvim_create_user_command("RojoServe", function(opts)
				overseer.run_template({
					name = "Start Rojo Server",
					params = { project = opts.fargs[1] },
				})
			end, {
				complete = function()
					return projects
				end,
				nargs = "?",
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
