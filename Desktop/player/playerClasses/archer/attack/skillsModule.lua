--ARCHER
local M = {}
local lastMovingDir = vmath.vector3(0,1,0)

local basicSlow_tim = 0

function M.basic(self, dt)
	local url = msg.url(nil,go.get_id(),"player")
	--Shooting
	if self.isShooting and self.basicCD_Timer <= 0 then
		go.set(url, "movingSpeed", self.baseMovingSpeed * 0.6)
		self.isMovementBase = false
		basicSlow_tim = 0
		self.shootingDir = vmath.normalize(self.shootingDir)
		local l_angle = math.atan2(self.shootingDir.y, self.shootingDir.x)
		factory.create("#attack-basicFactory", nil, vmath.quat_rotation_z(l_angle), { projectileDir = self.shootingDir })
		if self.quickHands_Timer > 0 then
			self.basicCD_Timer = self.basicCD / 2
			basicSlow_tim = 1
		else
			self.basicCD_Timer = self.basicCD
		end
	else
		self.basicCD_Timer = self.basicCD_Timer - dt
	end

	--Timers
	self.quickHands_Timer = self.quickHands_Timer - dt
	if basicSlow_tim > 0.2 and  not self.isMovementBase then
		self.isMovementBase = true
		go.set(url, "movingSpeed", self.baseMovingSpeed)
	else
		basicSlow_tim = basicSlow_tim + dt
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
		
	else
		self.redCD_Timer = self.redCD_Timer - dt
	end

	self.isRedHit = false
end

function M.quickHands(self, dt)
	if self.isGreenHit and self.greenCD_Timer <= 0 then

		self.quickHands_Timer = self.quickHandsDuration
		
		self.greenCD_Timer = self.greenCD
	else
		self.greenCD_Timer = self.greenCD_Timer - dt
	end

	self.isGreenHit = false
end

function M.powerArrow(self, dt)
	if self.isBlueHit and self.blueCD_Timer <= 0 then
		
	else
		self.blueCD_Timer = self.blueCD_Timer - dt
	end

	self.isBlueHit = false
end

return M