local get_rojo_projects = require("matt/util/get_rojo_projects")

local function setup_luau_lsp(capabilities)
	local projects = get_rojo_projects()
	local project_file = projects[1]

	local roblox_mode = project_file ~= nil

	local definition_files = vim.fs.find(function(name)
		return name:match(".*%.d%.lua[u]?$")
	end, {
		upward = false,
		path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
	})

	vim.filetype.add({
		extension = {
			lua = "luau",
		},
	})

	require("luau-lsp").setup({
		sourcemap = {
			enabled = roblox_mode,
			rojo_project_file = project_file,
		},
		platform = {
			type = roblox_mode and "roblox" or "standard",
		},
		types = {
			definition_files = definition_files,
		},
		fflags = {
			sync = true,
			override = {
				LuauTarjanChildLimit = 0,
			},
		},
		server = {
			capabilities = capabilities,
			filetypes = { "lua", "luau" },
			settings = {
				["luau-lsp"] = {
					require = {
						mode = "relativeToFile",
					},
					completion = {
						imports = {
							enabled = true,
							suggestServices = roblox_mode,
							suggestRequires = true,
							separateGroupsWithLine = true,
						},
					},
					ignoreGlobs = {
						"**/_Index/**",
					},
				},
			},
		},
	})
end

return setup_luau_lsp
