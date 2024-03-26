local setup_luau_lsp = require("matt/util/setup_luau_lsp")

return {
	{
		"williamboman/mason.nvim",
		cmd = { "Mason" },
		opts = {
			ensure_installed = {
				"stylua",
				"selene",
			},
		},
	},

	{
		"mfussenegger/nvim-lint",
		init = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				lua = { "selene" },
				luau = { "selene" },
			}

			vim.api.nvim_create_autocmd({
				"BufEnter",
				"BufWritePost",
				"TextChanged",
				"InsertLeave",
			}, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		init = function()
			local wk = require("which-key")

			local function open_float()
				vim.diagnostic.open_float({ scope = "line" })
			end

			local function register_keymap(ev)
				wk.register({
					-- stylua: ignore
					["<leader>"] = {
						e = { open_float, "Show diagnostic" },
						c = {
							name = "Code actions",
							a = { vim.lsp.buf.code_action, "Code action" },
						},
						d = {
							name = "Diagnostics",
							j = { vim.diagnostic.goto_next, "Next message" },
							k = { vim.diagnostic.goto_prev, "Previous message" },
							l = { "<cmd>Telescope diagnostics<cr>", "List diagnostics" },
						},
						g = {
							name = "Go to",
							d = { vim.lsp.buf.definition, "Go to definition" },
							i = { vim.lsp.buf.implementation, "Go to implementation" },
							t = { vim.lsp.buf.type_definition, "Go to type definition" },
						},
					},
					K = { vim.lsp.buf.hover, "Hover" },
				}, {
					buffer = ev.buf,
				})
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspKeymap", {}),
				callback = register_keymap,
			})
		end,
	},
	{
		"williamboman/mason-lspconfig",
		opts = {
			ensure_installed = {
				"luau_lsp",
				"rust_analyzer",
			},
		},
		config = function()
			require("neoconf").setup()
			require("neodev").setup()

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			capabilities.workspace = {
				didChangeWatchedFiles = {
					dynamicRegistration = true,
				},
			}

			local lspconfig = require("lspconfig")

			local function setup_server(name, config)
				config = config or {}
				config.capabilities = capabilities
				lspconfig[name].setup(config)
			end

			require("mason-lspconfig").setup_handlers({
				setup_server,
				yamlls = function(name)
					setup_server(name, {
						settings = {
							yaml = {
								validate = true,
								schemaStore = {
									enable = true,
								},
								schemas = {
									["https://mantledeploy.vercel.app/schemas/v0.11.13/schema.json"] = "mantle.yml",
								},
							},
						},
					})
				end,
				luau_lsp = function()
					setup_luau_lsp(capabilities)
				end,
			})
		end,
		dependencies = {
			"folke/neoconf.nvim",
			"folke/neodev.nvim",
			"lopi-py/luau-lsp.nvim",
		},
	},
}
