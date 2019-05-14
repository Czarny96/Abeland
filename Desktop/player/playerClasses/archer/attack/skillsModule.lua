--ARCHER
local M = {}
local lastMovingDir = vmath.vector3(0,1,0)

function M.basic(self, dt)
	--Shooting
	if self.isShooting and self.basicCD_Timer <= 0 then
		self.shootingDir = vmath.normalize(self.shootingDir)
		local l_angle = math.atan2(self.shootingDir.y, self.shootingDir.x)
		factory.create("#attack-basicFactory", nil, vmath.quat_rotation_z(l_angle), { projectileDir = self.shootingDir })
		self.basicCD_Timer = self.basicCD
	else
		self.basicCD_Timer = self.basicCD_Timer - dt
	end

	--Reset flags
	self.isShooting = false
end

function M.arrowsCone(self, dt)
	local function countAngle(rad)
		local l_vec = vmath.vector3()
		local dir = lastMovingDir

		l_vec.x = dir.x * math.cos(rad) - dir.y * math.sin(rad)
		l_vec.y = dir.x * math.sin(rad) + dir.y * math.cos(rad)

		return vmath.normalize(l_vec)
	end

	local dir = go.get("#player", "movingDir") * 20
	
	if dir.x ~= 0 or dir.y ~= 0 then
		lastMovingDir = dir
	else
		dir = lastMovingDir
	end
		
	if self.isYellowHit and self.yellowCD_Timer <= 0 then
		local l_vec = countAngle(math.pi/24)
		local l_angle = math.atan2(l_vec.y, l_vec.x)
		factory.create("#arrowsConeFactory", go.get_position() + dir, vmath.quat_rotation_z(l_angle), { projectileDir = l_vec })

		l_vec = countAngle(math.pi/12)
		l_angle = math.atan2(l_vec.y, l_vec.x)
		factory.create("#arrowsConeFactory", go.get_position() + dir, vmath.quat_rotation_z(l_angle), { projectileDir = l_vec })

		l_vec = countAngle(0)
		l_angle = math.atan2(l_vec.y, l_vec.x)
		factory.create("#arrowsConeFactory", go.get_position() + dir, vmath.quat_rotation_z(l_angle), { projectileDir = l_vec })

		l_vec = countAngle(math.pi/-12)
		l_angle = math.atan2(l_vec.y, l_vec.x)
		factory.create("#arrowsConeFactory", go.get_position() + dir, vmath.quat_rotation_z(l_angle), { projectileDir = l_vec })

		l_vec = countAngle(math.pi/-24)
		l_angle = math.atan2(l_vec.y, l_vec.x)
		factory.create("#arrowsConeFactory", go.get_position() + dir, vmath.quat_rotation_z(l_angle), { projectileDir = l_vec })

		self.yellowCD_Timer = self.yellowCD
	else
		self.yellowCD_Timer = self.yellowCD_Timer - dt
	end
	
	self.isYellowHit = false
end

function M.sniperShots(self, dt)
	if self.isRedHit and self.redCD_Timer <= 0 then
		--Handle all of this attack in this function
		--It is already called in attack.script coresponding to this class
	end
end

function M.quickHands(self, dt)
	if self.isGreenHit and self.greenCD_Timer <= 0 then
		--Handle all of this attack in this function
		--It is already called in attack.script coresponding to this class
	end
end

function M.powerArrow(self, dt)
	if self.isBlueHit and self.blueCD_Timer <= 0 then
		--Handle all of this attack in this function
		--It is already called in attack.script coresponding to this class
	end
end

return M