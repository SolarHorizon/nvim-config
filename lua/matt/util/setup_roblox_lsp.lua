local function setup_roblox_lsp()
	local configs = require("lspconfig.configs")
	local lsp = require("lspconfig")

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

return setup_roblox_lsp
