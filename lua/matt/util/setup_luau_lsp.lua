local get_rojo_projects = require("matt/util/get_rojo_projects")
local get_git_root = require("matt/util/get_git_root")

local function read_file(file)
	local fd = io.open(file)

	if not fd then
		return nil
	end

	return fd:read("*a")
end

local function has_darklua_string_require_rule()
	local darklua_config = vim.fs.find(function(name)
		return name:match("^%.darklua%.json[5]?$")
	end, {
		limit = 1,
		path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
	})

	if not darklua_config[1] then
		return false
	end

	local file = read_file(darklua_config[1])

	if not file then
		return false
	end

	local content = vim.json.decode(file)

	if not content.rules then
		return false
	end

	for _, rule in ipairs(content.rules) do
		if
			type(rule) == "table"
			and rule.rule == "convert_require"
			and rule.current.name == "path"
		then
			return true
		end
	end

	return false
end

local function has_luaurc_aliases(opts)
	local luaurc = vim.fs.find(function(name)
		return name:match("^%.luaurc$")
	end, {
		path = get_git_root(),
		upward = false,
	})

	for _, path in ipairs(luaurc) do
		local file = read_file(path)

		if file then
			local content = vim.json.decode(file)

			if content.aliases then
				if opts.excludes then
					for _, excluded in ipairs(opts.excludes) do
						content.aliases[excluded] = nil
					end
				end

				if next(content.aliases) then
					return true
				end
			end
		end
	end

	return false
end

local function setup_luau_lsp(capabilities)
	local projects = get_rojo_projects()
	local project_file = projects[1]

	local roblox_mode = project_file ~= nil
	local string_require_mode = has_darklua_string_require_rule()
		or has_luaurc_aliases({
			excludes = { "@lune" },
		})

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

	vim.api.nvim_create_user_command("DebugPrint", function()
		print(
			has_darklua_string_require_rule(),
			has_luaurc_aliases({ excludes = { "@lune" } })
		)
	end, {})

	require("luau-lsp").setup({
		sourcemap = {
			enabled = roblox_mode and not string_require_mode,
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
						"**/.pesde/**",
					},
				},
			},
		},
	})
end

return setup_luau_lsp
