-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "main.globals"
-- in any script using the functions.

local M = {}

--Wave counter for gameplay
local waveNumber = 1

--Pause indicator
local pause = false

--waveNumber getter
function M.getWaveNr()
	return waveNumber
end
--waveNumber setter
function M.setWaveNr(waveNr)
	waveNumber = waveNr
end

--pause getter
function M.getPause()
	return pause
end

--pause setter
function M.setPause(state)
	--state => boolean
	pause = state
end


-- Get hash as string
function M.unhash(hash)
	return string.sub(tostring(hash), 8, #tostring(hash)-1)
end

return M