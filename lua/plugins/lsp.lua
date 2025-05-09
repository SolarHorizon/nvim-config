local setup_luau_lsp = require("matt/util/setup_luau_lsp")

local dependencies = {
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
		"williamboman/mason-lspconfig",
		opts = {
			ensure_installed = {
				"luau_lsp",
				"ts_ls",
				"rust_analyzer",
			},
		},
		config = function()
			require("neoconf").setup()
			require("lazydev").setup()

			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities(),
				{
					workspace = {
						didChangeWatchedFiles = {
							dynamicRegistration = true,
						},
					},
				}
			)

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
			"folke/lazydev.nvim",
			"lopi-py/luau-lsp.nvim",
		},
	},
}

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPost", "BufWritePost", "BufNewFile" },
	init = function()
		local wk = require("which-key")

		local function open_float()
			vim.diagnostic.open_float({ scope = "line" })
		end

		local function register_keymap(ev)
			wk.add({
				buffer = ev.buf,

				{ "<leader>e", open_float, desc = "Show diagnostic" },

				{ "<leader>c", group = "Code Actions" },
				{
					"<leader>ca",
					vim.lsp.buf.code_action,
					desc = "Code action",
				},

				{ "<leader>d", group = "Diagnostics" },
				{
					"<leader>dj",
					vim.diagnostic.goto_next,
					desc = "Next message",
				},
				{
					"<leader>dk",
					vim.diagnostic.goto_prev,
					desc = "Previous message",
				},
				{
					"<leader>dl",
					cmd = "<cmd>Telescope diagnostics<cr>",
					desc = "List diagnostics",
				},

				{ "<leader>g", group = "Go to" },
				{
					"<leader>gd",
					vim.lsp.buf.definition,
					desc = "Go to definition",
				},
				{
					"<leader>gi",
					vim.lsp.buf.implementation,
					desc = "Go to implementation",
				},
				{
					"<leader>gt",
					vim.lsp.buf.type_definition,
					desc = "Go to type definition",
				},

				{ "K", vim.lsp.buf.hover, desc = "Hover" },
			})
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspKeymap", {}),
			callback = register_keymap,
		})
	end,
	dependencies = dependencies,
}
