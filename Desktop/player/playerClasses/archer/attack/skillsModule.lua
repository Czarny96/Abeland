--ARCHER
local M = {}

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
	local dir = go.get("#player", "movingDir")
	if self.isYellowHit and self.yellowCD_Timer <= 0 and (dir.x ~= 0 or dir.y ~= 0) then
		local dir = vmath.normalize(go.get("#player", "movingDir"))
		
		local l_x = dir.x * math.cos(math.pi/24) - dir.y * math.sin(math.pi/24)
		local l_y = dir.x * math.sin(math.pi/24) + dir.y * math.cos(math.pi/24)
		local l_angle = math.atan2(l_y, l_x)
		factory.create("#arrowsConeFactory", nil, vmath.quat_rotation_z(l_angle), { projectileDir = vmath.vector3(l_x,l_y,0) })

		l_x = dir.x * math.cos(math.pi/12) - dir.y * math.sin(math.pi/12)
		l_y = dir.x * math.sin(math.pi/12) + dir.y * math.cos(math.pi/12)
		l_angle = math.atan2(l_y, l_x)
		factory.create("#arrowsConeFactory", nil, vmath.quat_rotation_z(l_angle), { projectileDir = vmath.vector3(l_x,l_y,0) })

		l_angle = math.atan2(dir.y, dir.x)
		factory.create("#arrowsConeFactory", nil, vmath.quat_rotation_z(l_angle), { projectileDir = dir } )

		l_x = dir.x * math.cos(-math.pi/12) - dir.y * math.sin(-math.pi/12)
		l_y = dir.x * math.sin(-math.pi/12) + dir.y * math.cos(-math.pi/12)
		l_angle = math.atan2(l_y, l_x)
		factory.create("#arrowsConeFactory", nil, vmath.quat_rotation_z(l_angle), { projectileDir = vmath.vector3(l_x,l_y,0) })

		l_x = dir.x * math.cos(-math.pi/24) - dir.y * math.sin(-math.pi/24)
		l_y = dir.x * math.sin(-math.pi/24) + dir.y * math.cos(-math.pi/24)
		l_angle = math.atan2(l_y, l_x)
		factory.create("#arrowsConeFactory", nil, vmath.quat_rotation_z(l_angle), { projectileDir = vmath.vector3(l_x,l_y,0) })

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