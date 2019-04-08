local debuggingPath = "debugging/logs/"

function CheckDebugVersion()

	if "" .. hash("debug") == "[debug]" then
		return 1
	else
		return 0
	end
end

function CreateFile(fileName)
	local nameToCreateFile = io.open(debuggingPath ..  fileName, "w")
	nameToCreateFile:close()

	return
end

function CheckExistsFile(fileName)
	local checkExistsFile = io.open(debuggingPath .. fileName, "r")
	if checkExistsFile ~= nil then
		checkExistsFile:close()
		return 1
	else
		return 0
	end
end

function ReadFiles(fileName)
	local checkDebugVersion = CheckDebugVersion()
	local checkOfExistsFile = CheckExistsFile(fileName)

	if checkDebugVersion == 1 and checkOfExistsFile == 1 then
		local readFile = io.open(debuggingPath .. fileName)

		for lineOfFile in readFile:lines() do
			print(lineOfFile)
		end

		readFile:close()
	end

	return 1
end

function GetCurrentTime()
	local date = os.date("*t")
	local year, month, day = date.year, date.month, date.wday
	local hour, minute, second = date.hour, date.min, date.sec
	local millisecond = string.match(tostring(os.clock()), "%d%.(%d+)")

	return string.format("%04d-%02d-%02d %02d:%02d:%02d:%03s", year, month, day, hour, minute, second, millisecond)
end

function GetCurrentFileName()
	return debug.getinfo(2, "S").source:sub(2)
end

function WriteStaticFile(messageValue)
	local checkBuildVersion = CheckDebugVersion()

	if checkBuildVersion == 1 then
		local checkExistsLogTxt = CheckExistsFile("log.txt")

		if checkExistsLogTxt == 0 then 
			CreateFile("log.txt")
		end
		
		local staticFileToWriteData = io.open(debuggingPath .. "log.txt", "a")
		
		staticFileToWriteData:write(GetCurrentTime() .. " - " .. GetCurrentFileName() .. " - " .. messageValue .. "\n")
		
		staticFileToWriteData:close()
	end
	
	return
end

function WriteDynamicFile(messageValue, fileName)
	local checkBuildVersion = CheckDebugVersion()

	if checkBuildVersion == 1 then
		local checkExistsLogTxt = CheckExistsFile(fileName)

		if checkExistsLogTxt == 0 then 
			CreateFile(fileName)
		end

		local staticFileToWriteData = io.open(debuggingPath .. fileName, "a")

		staticFileToWriteData:write(GetCurrentTime() .. " - " .. GetCurrentFileName() .. " - " .. messageValue .. "\n")

		staticFileToWriteData:close()
	end

	return
end

function WriteLogsTofile(messageValue, fileName)
	WriteStaticFile(messageValue)

	if fileName ~= nil then
		WriteDynamicFile(messageValue, fileName)
	end
end
