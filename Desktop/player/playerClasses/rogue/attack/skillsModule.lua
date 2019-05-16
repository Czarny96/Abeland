--ROGUE
local M = {}

shaderManager = require "managers/shaderManager"

function M.basic(self, dt)
	--Shooting
	if not self.shadowFormFlag and self.isShooting then
		if self.basicCD_Timer <= 0 then
			self.shootingDir = vmath.normalize(self.shootingDir)
			local l_angle = math.atan2(self.shootingDir.y, self.shootingDir.x)
			factory.create("#attack-basicFactory", nil, vmath.quat_rotation_z(l_angle), { projectileDir = self.shootingDir })
			self.basicCD_Timer = self.basicCD
		else
			self.basicCD_Timer = self.basicCD_Timer - dt
		end
	elseif self.shadowFormFlag and self.isShooting then
		if self.basicShadowFormCD_Timer <= 0 then
			self.shootingDir = vmath.normalize(self.shootingDir)
			local l_angle = math.atan2(self.shootingDir.y, self.shootingDir.x)
			factory.create("#attack-shadowFormFactory", nil, vmath.quat_rotation_z(l_angle), { projectileDir = self.shootingDir })
			self.basicShadowFormCD_Timer = self.basicShadowFormCD
		else
			self.basicShadowFormCD_Timer = self.basicShadowFormCD_Timer - dt
		end
	end

	--Reset flags
	self.isShooting = false
end

function M.shadowForm(self, dt)
	if self.isYellowHit and self.yellowCD_Timer <= 0 then
		local url = msg.url(nil,go.get_id(),"shadowForm")
		
		msg.post("#shadowForm", "activate")
		self.yellowCD_Timer = self.yellowCD
	else
		self.yellowCD_Timer = self.yellowCD_Timer - dt
	end
	self.isYellowHit = false
end

function M.venomVial(self, dt)
	if self.isRedHit and self.redCD_Timer <= 0 then

	else
		self.redCD_Timer = self.redCD_Timer - dt
	end

	self.isRedHit = false
end

function M.dashAttack(self, dt)
	if self.isGreenHit and self.greenCD_Timer <= 0 then

	else
		self.greenCD_Timer = self.greenCD_Timer - dt
	end

	self.isGreenHit = false
end

function M.explodingTrap(self, dt)
	if self.isBlueHit and self.blueCD_Timer <= 0 then

	else
		self.blueCD_Timer = self.blueCD_Timer - dt
	end

	self.isBlueHit = false
end

return M