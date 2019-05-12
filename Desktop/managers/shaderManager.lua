
local M = {}

-- COLORIZE SHADER

-- How to use:
-- 1. local shaderManager = require "managers/shaderManager"
-- 2. in game object designer set 'colorize' as sprite material
-- 3. set blue color: "shaderManager.freezeEffect("#sprite")"
-- 4. reset color: "shaderManager.resetColorizeFilter("#sprite")"

function M.plainHitEffect(spriteId)
	sprite.set_constant(spriteId, "colorize", vmath.vector4(1.5, 0.3, 0.3, 1))
	sprite.set_constant(spriteId, "brightness", vmath.vector4(2, 1, 1, 1))
end

function M.freezeEffect(spriteId)
	sprite.set_constant(spriteId, "colorize", vmath.vector4(0.3, 0.3, 1.5, 1))
	sprite.set_constant(spriteId, "brightness", vmath.vector4(2, 1, 1, 1))
end

function M.resetColorizeFilter(spriteId)
	sprite.set_constant(spriteId, "colorize", vmath.vector4(1, 1, 1, 1))
	sprite.set_constant(spriteId, "brightness", vmath.vector4(1, 1, 1, 1))
end

function M.invisibilityEffect(spriteId)
	sprite.set_constant(spriteId, "colorize", vmath.vector4(1, 1, 1, 1))
	sprite.set_constant(spriteId, "brightness", vmath.vector4(0.3, 0.3, 0.3, .3))
end
-- END OF COLORIZE SHADER

return M