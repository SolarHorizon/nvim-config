local get_rojo_projects = require("matt/util/get_rojo_projects")
local locate_config = require("matt/util/locate_config")

local function setup_luau_lsp(capabilities)
	local project_file = get_rojo_projects()[1]

	local roblox_mode = project_file ~= nil

	local definition_files = {}

	local spec_files = vim.fs.find(function(name)
		return name:match(".*%.spec.luau$")
	end, {
		upward = false,
		path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
	})

	if spec_files[1] then
		table.insert(
			definition_files,
			vim.fs.normalize("~/.local/share/luau-lsp/types/testez.d.luau")
		)
	end

	local directoryAliases = {
		-- TODO: make this grab the version currently in use and set it up if it isnt found
		["@lune/"] = vim.fs.normalize("~/.lune/.typedefs/0.7.11/"),
	}

	local darklua_config = locate_config({
		".darklua.json",
		".darklua.json5",
	})[1]

	local string_require_mode = darklua_config ~= nil

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

			if content.bundle then
				sources = vim.tbl_extend(
					"keep",
					sources,
					content.bundle.require_mode.sources
				)
			elseif content.rules then
				for _, rule in ipairs(content.rules) do
					if type(rule) == "table" then
						if rule.rule == "convert_require" then
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
					directoryAliases[alias .. "/"] = vim.fs.normalize(dir)
				end
			end
		end
	end

	if not roblox_mode then
		vim.api.nvim_create_autocmd("InsertLeave", {
			pattern = {
				"*.luau",
				"*.lua",
			},
			callback = function()
				local fd = io.open("./sourcemap.json", "w+")

				if fd then
					local content = vim.json.encode({
						name = tostring(os.clock()),
					})

					fd:write(content)
					fd:flush()
					fd:close()
				end

				return true
			end,
		})
	end

	require("luau-lsp").setup({
		sourcemap = roblox_mode
				and {
					enabled = true,
					--enabled = darklua_config == nil,
					select_project_file = function()
						return project_file
					end,
				}
			or {
				enabled = false,
			},
		types = {
			definition_files = definition_files,
			roblox = roblox_mode,
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
			settings = {
				["luau-lsp"] = {
					require = {
						mode = "relativeToFile",
						directoryAliases = directoryAliases,
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
			},
		},
	})
end

return setup_luau_lsp
