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
	local url = msg.url(nil,go.get_id(),"player")
	if self.chargeDir ~= go.get(url, "movingDir") and go.get(url, "movingDir") ~= vmath.vector3() then
		self.chargeDir = vmath.normalize(go.get(url, "movingDir"))
	end

	if self.isRedHit and self.redCD_Timer <= 0 then
		--Perform shield charge
		msg.post("#shieldCharge", "charge", {dir = self.chargeDir})
		self.redCD_Timer = self.redCD
	else
		self.redCD_Timer = self.redCD_Timer - dt
	end

	self.isRedHit = false
end

function M.taunt(self, dt)
	if self.isGreenHit and self.greenCD_Timer <= 0 then
		factory.create("#attack-tauntFactory",nil,nil,{playerId = go.get_id()})		
		self.greenCD_Timer = self.greenCD
	else
		self.greenCD_Timer = self.greenCD_Timer - dt
	end

	self.isGreenHit = false
end

function M.warStomp(self, dt)
	if self.isBlueHit and self.blueCD_Timer <= 0 then

	else
		self.blueCD_Timer = self.blueCD_Timer - dt
	end

	self.isBlueHit = false
end


return M