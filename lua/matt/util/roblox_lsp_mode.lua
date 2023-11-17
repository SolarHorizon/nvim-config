local matches = {
	"projects/supersocial/",
}

local function roblox_lsp_mode()
	for _, match in ipairs(matches) do
		if string.match(vim.fn.getcwd(), match) then
			return true
		end
	end

	return false
end

return roblox_lsp_mode
