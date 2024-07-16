local get_rojo_projects = require("matt/util/get_rojo_projects")
local locate_config = require("matt/util/locate_config")

local function get_darklua_sources()
	local darklua_config = locate_config({
		"darklua.json",
		".darklua.json",
	})[1]

	local aliases = {}

	if darklua_config then
		local fd = io.open(darklua_config)

		local content

		if fd then
			content = vim.json.decode(fd:read("*a"), {
				luanil = {
					object = true,
					array = true,
				},
			})

			fd:close()
		end

		if content then
			local sources = {}

			if
				content.bundle
				and content.bundle.require_mode
				and content.bundle.require_mode.sources
			then
				sources = vim.tbl_extend(
					"keep",
					sources,
					content.bundle.require_mode.sources
				)
			end

			if content.rules then
				for _, rule in ipairs(content.rules) do
					if type(rule) == "table" then
						if
							rule.rule == "convert_require"
							and rule.current
							and rule.current.sources
						then
							sources = vim.tbl_extend(
								"keep",
								sources,
								rule.current.sources
							)
							break
						end
					end
				end
			end

			if sources then
				for alias, dir in pairs(sources) do
					dir = dir:gsub("^./", "$PWD/")
					aliases[alias .. "/"] = vim.fs.normalize(dir)
				end
			end
		end
	end

	return aliases
end

local function get_luaurc_sources()
	local aliases = {}

	local luau_config = locate_config(".luaurc")[1]

	if luau_config then
		local fd = io.open(luau_config)

		local content

		if fd then
			content = vim.json.decode(fd:read("*a"), {
				luanil = {
					object = true,
					array = true,
				},
			})

			fd:close()
		end

		if content and content.aliases then
			for alias, dir in pairs(content.aliases) do
				dir = dir:gsub("^./", "$PWD/")
				aliases["@" .. alias] = vim.fs.normalize(dir)
			end
		end
	end

	return aliases
end

local function organize_sources(sources)
	local files = {}
	local directories = {}

	for alias, path in pairs(sources) do
		path = vim.fs.normalize(path)

		if vim.fn.isdirectory(path) == 1 then
			local formatted = path

			if string.sub(path, -1) ~= "/" then
				formatted = path .. "/"
			end

			directories[alias] = formatted
		elseif vim.fn.filereadable(path) == 1 then
			local formatted = path

			if string.sub(path, -1) == "/" then
				formatted = string.sub(path, 1, #path - 1)
			end

			files[alias] = formatted
		else
			vim.notify(
				string.format(
					"Alias %s does not point to a directory or readable file\n\tPath: %s",
					alias,
					path
				),
				vim.log.levels.WARN
			)
		end
	end

	if next(files) == nil then
		files = nil
	end

	if next(directories) == nil then
		directories = nil
	end

	return {
		files = files,
		directories = directories,
	}
end

local function get_string_require_aliases()
	local sources =
		vim.tbl_extend("force", get_darklua_sources(), get_luaurc_sources())

	if next(sources) == nil then
		return false, {}
	end

	if sources["@lune"] == nil then
		local output = vim.system({ "lune", "--version" }, { text = true })
			:wait()

		if output.stdout then
			sources["@lune"] = string.format(
				"~/.lune/.typedefs/%s/",
				string.sub(output.stdout, 6, #output.stdout - 1)
			)
		end
	end

	local aliases = organize_sources(sources)

	return true, aliases
end

local function setup_luau_lsp(capabilities)
	local projects = get_rojo_projects()
	local project_file = projects[1]

	local roblox_mode = project_file ~= nil

	local definition_files = {
		vim.fs.normalize("~/.local/share/luau-lsp/types/roblox.d.lua"),
	}

	local spec_files = vim.fs.find(function(name)
		return name:match(".*%.spec%.lua[u]?$")
	end, {
		upward = false,
		path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
	})

	if #spec_files > 0 then
		table.insert(
			definition_files,
			vim.fs.normalize("~/.local/share/luau-lsp/types/testez.d.luau")
		)
	end

	vim.filetype.add({
		extension = {
			lua = "luau",
		},
	})

	local string_require_mode, aliases = get_string_require_aliases()

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
		server = {
			capabilities = capabilities,
			root_dir = function(path)
				local util = require("lspconfig.util")
				return util.root_pattern(
					"*.project.json",
					".luaurc",
					"selene.toml",
					"stylua.toml",
					"wally.toml"
				)(path) or util.find_git_ancestor(path)
			end,
			filetypes = { "lua", "luau" },
			settings = {
				["luau-lsp"] = {
					require = {
						mode = "relativeToFile",
						directoryAliases = aliases.directories,
						fileAliases = aliases.files,
					},
					completion = {
						autocompleteEnd = true,
						addParentheses = false,
						imports = {
							enabled = true,
							suggestServices = roblox_mode,
							suggestRequires = roblox_mode
								and not string_require_mode,
							separateGroupsWithLine = true,
						},
					},
					ignoreGlobs = {
						"**/_Index/**",
					},
				},
				fflags = {
					sync = true,
				},
			},
		},
	})
end

return setup_luau_lsp
