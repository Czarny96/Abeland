-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "main.globals"
-- in any script using the functions.

local M = {}

-- Get hash as string
function M.unhash(hash)
	return string.sub(tostring(hash), 8, #tostring(hash)-1)
end

return M