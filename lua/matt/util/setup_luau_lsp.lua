local get_rojo_projects = require("matt/util/get_rojo_projects")
local get_git_root = require("matt/util/get_git_root")

local PROJECT_AUTO_SELECTION_ORDER = {
	"sync",
	"dev",
	"default",
}

local function read_file(file)
	local fd = io.open(file)

	if not fd then
		return nil
	end

	return fd:read("*a")
end
--
-- local function has_darklua_string_require_rule()
-- 	local darklua_config = vim.fs.find(function(name)
-- 		return name:match("^%.darklua%.json[5]?$")
-- 	end, {
-- 		limit = 1,
-- 		path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
-- 	})
--
-- 	if not darklua_config[1] then
-- 		return false
-- 	end
--
-- 	local file = read_file(darklua_config[1])
--
-- 	if not file then
-- 		return false
-- 	end
--
-- 	local content = vim.json.decode(file)
--
-- 	if not content.rules then
-- 		return false
-- 	end
--
-- 	for _, rule in ipairs(content.rules) do
-- 		if
-- 			type(rule) == "table"
-- 			and rule.rule == "convert_require"
-- 			and rule.current.name == "path"
-- 		then
-- 			return true
-- 		end
-- 	end
--
-- 	return false
-- end

local function create_roblox_tasks()
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
end

local function has_luaurc_aliases(opts)
	local luaurc = vim.fs.find(function(name, path)
		return not path:match("[/\\\\]%.?lune$") and name:match("^%.luaurc$")
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
	local project_file

	for _, name in ipairs(PROJECT_AUTO_SELECTION_ORDER) do
		if
			vim.tbl_contains(projects, function(v)
				return string.match(v, name .. "%.project%.json$") ~= nil
			end, { predicate = true })
		then
			project_file = name
			break
		end
	end

	if not project_file then
		project_file = projects[1]
	end

	local roblox_mode = project_file ~= nil

	local definition_files = vim.fs.find(function(name)
		return name:match(".*%.d%.lua[u]?$")
	end, {
		upward = false,
		path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
	})

	create_roblox_tasks()

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
			filetypes = { "luau" },
			settings = {
				["luau-lsp"] = {
					require = {
						mode = "relativeToFile",
					},
					completion = {
						imports = {
							enabled = true,
							suggestServices = roblox_mode,
							separateGroupsWithLine = true,
							ignoreGlobs = {
								"**/_Index/**",
								"**/.pesde/**",
								"*.server.luau",
								"*.client.luau",
								"*.plugin.luau",
							},
							stringRequires = {
								enabled = roblox_mode and has_luaurc_aliases({
									excludes = { "@lune" },
								}),
							},
						},
					},
					ignoreGlobs = {
						"**/_Index/**",
						"**/.pesde/**",
					},
				},
			},
		},
		plugin = {},
	})
end

return setup_luau_lsp
