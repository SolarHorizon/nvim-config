local get_rojo_projects = require("matt/util/get_rojo_projects")
local locate_config = require("matt/util/locate_config")
local roblox_lsp_mode = require("matt/util/roblox_lsp_mode")

return {
	"williamboman/mason.nvim",
	config = function()
		if not roblox_lsp_mode() then
			require("neodev").setup()
		end

		require("neoconf").setup()

		local configs = require("lspconfig.configs")
		local lsp = require("lspconfig")

		if not configs.robloxlsp then
			configs.robloxlsp = {
				default_config = {
					cmd = {
						"/home/matt/.local/src/roblox-lsp/server/bin/Linux/lua-language-server",
					},
					filetypes = { "lua", "luau" },
					root_dir = lsp.util.find_git_ancestor,
					single_file_support = true,
					log_level = vim.lsp.protocol.MessageType.Warning,
					settings = {
						robloxLsp = {
							telemetry = {
								enable = false,
							},
							runtime = {
								plugin = ".vscode/lua/plugin.lua",
							},
							diagnostics = {
								disable = {
									"unused-local",
								},
							},
						},
					},
				},
				docs = {
					package_json = "https://raw.githubusercontent.com/NightrainsRbx/RobloxLsp/master/package.json",
					description = "https://github.com/nightrainsrbx/robloxlsp",
				},
			}
		end

		require("mason").setup()

		require("mason-lspconfig").setup({
			ensure_installed = {
				"luau_lsp",
				"rust_analyzer",
			},
		})

		require("mason-null-ls").setup({
			automatic_installation = { exclude = { "rustfmt" } },
		})

		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		capabilities.workspace = {
			didChangeWatchedFiles = {
				dynamicRegistration = true,
			},
		}

		local lspconfig = require("lspconfig")

		local function set_keymap(ev)
			local function map_key(key, callback)
				vim.keymap.set("n", key, callback, { buffer = ev.buf })
			end

			map_key("K", vim.lsp.buf.hover)
			map_key("gd", vim.lsp.buf.definition)
			map_key("gt", vim.lsp.buf.type_definition)
			map_key("gi", vim.lsp.buf.implementation)
			map_key("<leader>r", vim.lsp.buf.rename)
			map_key("<leader>dj", vim.diagnostic.goto_next)
			map_key("<leader>dk", vim.diagnostic.goto_prev)
			map_key("<leader>ca", vim.lsp.buf.code_action)
			map_key("<leader>dl", "<cmd>Telescope diagnostics<cr>")

			map_key("<leader>e", function()
				vim.diagnostic.open_float({ scope = "line" })
			end)
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspKeymap", {}),
			callback = set_keymap,
		})

		local function setup(name, config)
			config = config or {}
			config.capabilities = capabilities
			lspconfig[name].setup(config)
		end

		if roblox_lsp_mode() then
			setup("robloxlsp")
			-- might break next update
			require("luau-lsp").treesitter()
		end

		require("mason-lspconfig").setup_handlers({
			function(server_name)
				setup(server_name)
			end,
			["lua_ls"] = function()
				if not roblox_lsp_mode() then
					setup("lua_ls")
				end
			end,
			["luau_lsp"] = function()
				if roblox_lsp_mode() then
					return
				end

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
						vim.fs.normalize(
							"~/.local/share/luau-lsp/types/testez.d.luau"
						)
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
								directoryAliases[alias .. "/"] =
									vim.fs.normalize(dir)
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
					sourcemap = roblox_mode and {
						enabled = darklua_config == nil,
						select_project_file = function()
							return project_file
						end,
					} or {
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
			end,
		})
	end,
	dependencies = {
		"folke/neodev.nvim",
		"neovim/nvim-lspconfig",
		"jose-elias-alvarez/null-ls.nvim",
		"jay-babu/mason-null-ls.nvim",
		"williamboman/mason-lspconfig",
		"hrsh7th/cmp-nvim-lsp",
		"lopi-py/luau-lsp.nvim",
	},
}
