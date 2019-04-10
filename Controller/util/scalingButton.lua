-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions.

local M = {}

local BUTTON_SCALE = 0.8 -- button will be rescaled to this value after clicking

function M.create(nodeId, buttonId, onReleaseCallback, onClickCallback)
	local button = {}

	-- FIELDS
	button.nodeIdHash = hash(nodeId)
	button.node = gui.get_node(nodeId)
	button.onRelease = onReleaseCallback
	button.onClick = onClickCallback
	button.buttonId = buttonId -- used only in controller project

	button.isPressed = false
	button.touchId = -1
	-- END OF FIELDS

	function button.reset()
		button.isPressed = false
		button.touchId = -1
		gui.set_scale(button.node, vmath.vector3(1.0))
	end

	-- FUNCTIONS
	function button.multitouchUpdate(touchData)

		if not (touchData.id == button.touchId or button.touchId == -1) then
			return
		end

		if touchData.pressed and gui.pick_node(button.node, touchData.x, touchData.y) then
			-- first time clicked
			button.onClick(button.nodeIdHash)
			gui.set_scale(button.node, vmath.vector3(BUTTON_SCALE))
			button.isPressed = true
			button.touchId = touchData.id
		elseif touchData.released and button.isPressed then
			-- button released (finger was whole time on the button)
			button.onRelease(button.nodeIdHash)
			gui.set_scale(button.node, vmath.vector3(1.0))
			button.isPressed = false
			button.touchId = -1
		elseif button.isPressed and not isCursorInsideButton(button.node, touchData.x, touchData.y) then
			-- button was pressed and now is not
			button.isPressed = false
			gui.set_scale(button.node, vmath.vector3(1.0))
			button.touchId = -1
		end

	end

	function button.mouseUpdate(action)
		
		if action.pressed and gui.pick_node(button.node, action.x, action.y) then
			-- first time clicked
			button.onClick(button.nodeIdHash)
			gui.set_scale(button.node, vmath.vector3(BUTTON_SCALE))
			button.isPressed = true
		elseif action.released and button.isPressed then
			-- button released (pointer was whole time on the button)
			button.onRelease(button.nodeIdHash)
			gui.set_scale(button.node, vmath.vector3(1.0))
			button.isPressed = false
		elseif button.isPressed and not isCursorInsideButton(button.node, action.x, action.y) then
			-- button was pressed and now is not
			button.isPressed = false
			gui.set_scale(button.node, vmath.vector3(1.0))
		end
		
	end
	-- END OF FUNCTIONS

	return button
end

function isCursorInsideButton(node, x, y)
	local isInside = false
	-- BUGFIX #1: resize button to 1.02 if scale is set to BUTTON_SCALE, and
	--		   then go back to BUTTON_SCALE after 'checking collision'
	--		   REMOVE IT IF BUTTON IS NOT SCALING WHILE BEING PRESSED
	local scale = gui.get_scale(node)
	if scale.x < 0.9 then
		scale = vmath.vector3(1.02)
		gui.set_scale(node, scale)
		scale = gui.get_scale(node)
	end	
	-- PART 1 OF BUGFIX #1 END

	if gui.pick_node(node, x, y) then 
		isInside = true
	end

	-- PART 2 OF BUGFIX #1
	scale = gui.get_scale(node)
	if scale.x > 1.01 then
		scale = vmath.vector3(BUTTON_SCALE)
		gui.set_scale(node, scale)
	end	
	-- PART 2 OF BUGFIX #1 END

	return isInside
end

return M