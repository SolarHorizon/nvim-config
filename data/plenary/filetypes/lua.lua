local roblox_lsp_mode = require("matt/util/roblox_lsp_mode")

return {
	extension = {
		lua = roblox_lsp_mode() and "luau" or "lua",
	},
}
