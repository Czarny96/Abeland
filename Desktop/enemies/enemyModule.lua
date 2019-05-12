local M = {} 

local shaderManager = require "managers/shaderManager"
local enemyManager = require "managers.enemyManager"
local bodyManager = require "managers/bodyManager.bodyManager"
local shaderManager = require "managers/shaderManager"
local globals = require "main.globals"
local playerManager = require "managers.playersManager"

local anims = {
	hash("player_prot_up_left"),			--1
	hash("player_prot_up_right"),
	hash("player_prot_down_left"),
	hash("player_prot_down_right"),
	hash("player_prot_up"),
	hash("player_prot_down"),
	hash("player_prot_left"),
	hash("player_prot_right"),
	hash("player_prot_down"),				--9
	hash("player_prot_up_left_attack"),		--10
	hash("player_prot_up_right_attack"),
	hash("player_prot_down_left_attack"),
	hash("player_prot_down_right_attack"),	
	hash("player_prot_up_attack"),
	hash("player_prot_down_attack"),
	hash("player_prot_left_attack"),
	hash("player_prot_right_attack"),
	hash("player_prot_down_attack")			--18

}

function M.setTarget(self)
	if self.tauntTarget == nil and self.tauntDuration <= 0 then
		self.targetId = playerManager.getClosestPlayerID(go.get_position())
	else
		self.targetId = self.tauntTarget
	end

	if self.targetId == 0 then
		return false
	else 
		return true
	end
end

function M.setDirection(self, moveVector)
	local idx = 1
	-- Look at anims table above
	if moveVector.x < -0.3 and moveVector.y > 0.3 then
		idx = 1
	elseif moveVector.x > 0.3 and moveVector.y > 0.3 then
		idx = 2
	elseif moveVector.x < -0.3 and moveVector.y < -0.3 then
		idx = 3
	elseif moveVector.x > 0.3 and moveVector.y < -0.3 then
		idx = 4
	elseif moveVector.y > 0.3  then
		idx = 5
	elseif moveVector.y < -0.3  then
		idx = 6
	elseif moveVector.x < -0.3  then
		idx = 7
	elseif moveVector.x > 0.3  then
		idx = 8
	else 
		idx = 9
	end

	-- if enemy is attacking, then show frames 10-18
	if self.attackTimer < 5 then
		idx = idx + 9
	end

	msg.post("#sprite", "play_animation", {id = anims[idx]})
end

function M.manageStates(self, dt)
	--Stun
	if self.stunDuration > 0 then
		self.stunDuration = self.stunDuration - dt
	end

	--Root
	if self.rootDuration > 0 then
		self.rootDuration = self.rootDuration - dt
	end

	--Slow
	if self.slowDuration > 0 then
		self.slowDuration = self.slowDuration - dt
	else
		shaderManager.resetColorizeFilter("#sprite")
		self.slowAmount = 0
	end

	--Taunt
	if self.tauntDuration > 0 then
		self.tauntDuration = self.tauntDuration - dt
	else
		self.tauntTarget = nil
	end
end

function M.handleDeath(self, dt)
	-- Handling death when health drops below 0
	if self.health <= 0 then
		-- Play death sound
		--msg.post("#death_sound", "play_sound", {gain = 0.5})
		enemyManager.removeEnemy(go.get_id())
		bodyManager.createTimedBody(go.get_position(), self.type, 5)
		go.delete()
	end
end

function M.move(self, dt)
	if self.stunDuration <= 0 and self.targetPosition  then
		if self.moveAfterAttCD > 0 then
			M.setDirection(self, self.lastHitVector)
		else
			local movement = self.targetPosition - go.get_position()
			self.targetPosition = vmath.normalize(movement)
			M.setDirection(self, vmath.normalize(movement))
			if self.rootDuration <= 0 then
				msg.post("#co", "apply_force", {force = vmath.normalize(movement) * (100 - self.slowAmount) * go.get("#co", "mass"), position = go.get_world_position()})
			end
		end
	end
end

function M.knockBack(self, message)
	local kickDir = vmath.vector3()
	if message.pos ~= nil then
		kickDir = vmath.normalize( go.get_position() - message.pos)
	end
	msg.post("#co", "apply_force", {force = kickDir * go.get("#co", "mass") * 1000, position = go.get_world_position()})
end

function M.collisionWithEntity(self, message_id, message, sender)
	if message.own_group == hash("enemy") and message.other_group ~= hash("attack") then
		M.knockBack(self, message)
	end
end

function M.handleMessage(self, message_id, message, sender)
	--Knockback
	if message_id == hash("knockback") then
		M.knockBack(self, message)
	end
	--Stun
	if message_id == hash("stun") then
		self.stunDuration = message.duration
	end
	--Taunt
	if message_id == hash("taunt") then
		self.tauntTarget = message.other_id
		self.tauntDuration = message.duration
	end
	--Slow
	if message_id == hash("slow") then
		shaderManager.freezeEffect("#sprite")
		self.slowAmount = message.amount
		self.slowDuration = message.duration
	end
	--Root
	if message_id == hash("root") then
		self.rootDuration = message.duration
	end

	--Deleting object	
	if message_id == hash("kill") then
		go.delete()
	end
end

return M