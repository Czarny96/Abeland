
local M = {}

-- COLORIZE SHADER

-- How to use:
-- 1. local shaderManager = require "managers/shaderManager"
-- 2. in game object designer set 'colorize' as sprite material
-- 3. set blue color: "shaderManager.freezeEffect("#sprite")"
-- 4. reset color: "shaderManager.resetColorizeFilter("#sprite")"

function M.plainHitEffect(spriteId)
	sprite.set_constant(spriteId, "colorize", vmath.vector4(1.5, 0.3, 0.3, 1))

	local url = msg.url(nil,go.get_id(),"sprite")
	go.animate(url, "colorize", go.PLAYBACK_ONCE_FORWARD, vmath.vector4(1, 1, 1, 1) , go.EASING_OUTSINE, 0.5)
end

function M.freezeEffect(spriteId, time)
	sprite.set_constant(spriteId, "colorize", vmath.vector4(0.3, 0.3, 1.5, 1))
	sprite.set_constant(spriteId, "brightness", vmath.vector4(2, 1, 1, 1))

	local url = msg.url(nil,go.get_id(),"sprite")
	go.animate(url, "colorize", go.PLAYBACK_ONCE_FORWARD, vmath.vector4(1, 1, 1, 1) , go.EASING_INCIRC, time)
	go.animate(url, "brightness", go.PLAYBACK_ONCE_FORWARD, vmath.vector4(1, 1, 1, 1) , go.EASING_INCIRC, time)
end

function M.freezeHitEffect(spriteId, time)
	sprite.set_constant(spriteId, "colorize", vmath.vector4(0.3, 0.3, 1.5, 1))
	sprite.set_constant(spriteId, "brightness", vmath.vector4(2, 1, 1, 1))

	local url = msg.url(nil,go.get_id(),"sprite")
	go.animate(url, "colorize", go.PLAYBACK_ONCE_FORWARD, vmath.vector4(1, 1, 1, 1) , go.EASING_OUTSINE, 0.5)
	go.animate(url, "brightness", go.PLAYBACK_ONCE_FORWARD, vmath.vector4(1, 1, 1, 1) , go.EASING_OUTSINE, 0.5)
end

function M.poisonHitEffect(spriteId)
	sprite.set_constant(spriteId, "colorize", vmath.vector4(0, 0.5, 0, 1))
	sprite.set_constant(spriteId, "brightness", vmath.vector4(1, 1, 1, 1))

	local url = msg.url(nil,go.get_id(),"sprite")
	go.animate(url, "colorize", go.PLAYBACK_ONCE_FORWARD, vmath.vector4(1, 1, 1, 1) , go.EASING_OUTSINE, 0.5)
	go.animate(url, "brightness", go.PLAYBACK_ONCE_FORWARD, vmath.vector4(1, 1, 1, 1) , go.EASING_OUTSINE, 0.5)
end

function M.resetShader(spriteId)
	sprite.set_constant(spriteId, "colorize", vmath.vector4(1, 1, 1, 1))
	sprite.set_constant(spriteId, "brightness", vmath.vector4(1, 1, 1, 1))
	local url = msg.url(nil,go.get_id(),"sprite")
	go.cancel_animations(url, "colorize")
	go.cancel_animations(url, "brightness")
end

function M.invisibilityEffect(spriteId, time)
	sprite.set_constant(spriteId, "colorize", vmath.vector4(1, 1, 1, 1))
	sprite.set_constant(spriteId, "brightness", vmath.vector4(0.3, 0.3, 0.3, .3))
end

function M.endOfInvisibilityEffect(spriteId)
	local url = msg.url(nil,go.get_id(),"sprite")
	go.animate(url, "colorize", go.PLAYBACK_LOOP_PINGPONG, vmath.vector4(1, 1, 1, 1) , go.EASING_INOUTSINE, 0.5)
	go.animate(url, "brightness", go.PLAYBACK_LOOP_PINGPONG, vmath.vector4(1, 1, 1, 1) , go.EASING_INOUTSINE, 0.5)
end
-- END OF COLORIZE SHADER

return M