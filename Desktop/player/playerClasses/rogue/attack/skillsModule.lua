--ROGUE
local M = {}
local lastMovingDir = vmath.vector3(0,1,0)


function M.basic(self, dt)
	--Shooting
	if not self.shadowFormFlag and self.isShooting then
		if self.basicCD_Timer <= 0 then
			self.shootingDir = vmath.normalize(self.shootingDir)
			local l_angle = math.atan2(self.shootingDir.y, self.shootingDir.x)
			factory.create("#attack-basicFactory", nil, vmath.quat_rotation_z(l_angle), { projectileDir = self.shootingDir })
			self.basicCD_Timer = self.basicCD
		else
			if self.basicCD_Timer > self.basicCDmashing and not self.isShooting then
				self.basicCD_Timer = self.basicCDmashing
			end
			self.basicCD_Timer = self.basicCD_Timer - dt
		end
	elseif self.shadowFormFlag and self.isShooting then
		if self.basicShadowFormCD_Timer <= 0 then
			self.shootingDir = vmath.normalize(self.shootingDir)
			local l_angle = math.atan2(self.shootingDir.y, self.shootingDir.x)
			factory.create("#attack-shadowFormFactory", nil, vmath.quat_rotation_z(l_angle), { projectileDir = self.shootingDir })
			self.basicShadowFormCD_Timer = self.basicShadowFormCD
		else
			if self.basicShadowFormCD_Timer > self.basicShadowFormCDmashing and not self.isShooting then
				self.basicShadowFormCD_Timer = self.basicShadowFormCDmashing
			end
			self.basicShadowFormCD_Timer = self.basicShadowFormCD_Timer - dt
		end
	end

	--Reset flags
	self.isShooting = false
end

function M.shadowForm(self, dt)
	if self.isYellowHit and self.yellowCD_Timer <= 0 then
		local url = msg.url(nil,go.get_id(),"shadowForm")
		
		msg.post("#shadowForm", "shadowForm")
		self.yellowCD_Timer = self.yellowCD
	else
		self.yellowCD_Timer = self.yellowCD_Timer - dt
	end
	self.isYellowHit = false
end

function M.venomVial(self, dt)
	local l_projectileDir = go.get("#player", "movingDir")
	if l_projectileDir.x ~= 0 or l_projectileDir.y ~= 0 then
		lastMovingDir = l_projectileDir
	else
		l_projectileDir = lastMovingDir
	end
	if self.isRedHit and self.redCD_Timer <= 0 then
		l_projectileDir = vmath.normalize(l_projectileDir)
		local l_angle = math.atan2(l_projectileDir.y, l_projectileDir.x)
		factory.create("#attack-venomVial", nil, vmath.quat_rotation_z(l_angle), { projectileDir = l_projectileDir })
		self.redCD_Timer = self.redCD
	else
		self.redCD_Timer = self.redCD_Timer - dt
	end

	self.isRedHit = false
end

function M.dashAttack(self, dt)
	local url = msg.url(nil,go.get_id(),"player")
	if self.dashDir ~= go.get(url, "movingDir") and go.get(url, "movingDir") ~= vmath.vector3() then
		self.dashDir = vmath.normalize(go.get(url, "movingDir"))
	end
	
	if self.isGreenHit and self.greenCD_Timer <= 0 then
		--Perform dash attack
		msg.post("#dashAttack", "dash", {dir = self.dashDir})
		self.greenCD_Timer = self.greenCD
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