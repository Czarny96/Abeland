--KNIGHT
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

function M.shieldUp(self, dt)
	if self.isYellowHit and self.yellowCD_Timer <= 0 then
		factory.create("#attack-shieldUpFactory")		
		self.yellowCD_Timer = self.yellowCD
	else
		self.yellowCD_Timer = self.yellowCD_Timer - dt
	end

	self.isYellowHit = false
end

function M.shieldCharge(self, dt)
	if self.isRedHit and self.redCD_Timer <= 0 then
		--Handle all of this attack in this function
		--It is already called in attack.script coresponding to this class
	end
end

function M.taunt(self, dt)
	if self.isGreenHit and self.greenCD_Timer <= 0 then
		--Handle all of this attack in this function
		--It is already called in attack.script coresponding to this class
	end
end

function M.warStomp(self, dt)
	if self.isBlueHit and self.BlueCD_Timer <= 0 then
		--Handle all of this attack in this function
		--It is already called in attack.script coresponding to this class
	end
end


return M