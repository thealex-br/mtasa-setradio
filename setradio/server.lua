--| Criado por 6A666C6D | Melhorado por thealex-br
--| https://community.multitheftauto.com/index.php?p=resources&s=details&id=3104

local vehicleList = {}

addEventHandler("onPlayerJoin", root, function()
	local vehicles = getElementsByType("vehicle")
	for _, veh in ipairs( vehicles ) do
		if vehicleList[veh] then
			triggerClientEvent(source, "onServerToggleRadio", source, true, vehicleList[veh].radio, veh, vehicleList[veh].volume)
		end
	end
end)

addEventHandler("onVehicleExplode", root, function()
	if vehicleList[source] and vehicleList[source].radio then
		triggerClientEvent("onServerToggleRadio", root, false, nil, source)
		vehicleList[source].radio = false
	end
end)

addEventHandler("onElementDestroy", root, function()
	if vehicleList[source] and vehicleList[source].radio then
		triggerClientEvent("onServerToggleRadio", root, false, nil, source)
		vehicleList[source].radio = false
	end
end)

addEvent("onPlayerToggleRadio", true)
addEventHandler("onPlayerToggleRadio", root, function()
	if not client then
		return
	end
	if source and getElementType(source) == "player" then
		toggleRadio(source)
	end
end)

function createVehData(theVehicle)
	if not vehicleList[theVehicle] then
		vehicleList[theVehicle] = {}
		vehicleList[theVehicle].radio = false
		vehicleList[theVehicle].volume = 1.0
		return vehicleList[theVehicle] or false
	end
	return vehicleList[theVehicle] or false
end

function toggleRadio(player)
    local veh = getPedOccupiedVehicle(player)
    if veh then
        local playerSeat = getPedOccupiedVehicleSeat(player)
        if playerSeat == 0 or playerSeat == 1 then
			createVehData(veh)
			if not vehicleList[veh].radio then
				return
			end
            local turnOn = not vehicleList[veh].state

            if turnOn then
                vehicleList[veh].state = true
                vehicleList[veh].changedBy = player

				if not vehicleList[veh].placedBy then
					vehicleList[veh].placedBy = player
				end
            else
                vehicleList[veh].state = false
            end
            triggerClientEvent("onServerToggleRadio", root, turnOn, vehicleList[veh].radio, veh, vehicleList[veh].volume)

            local status = turnOn and "#00ff00ON" or "#ff0000OFF"
			local text = string.format("#696969Radio [%s#696969]", status)
            outputChatBox(text, player, 255, 255, 255, true)
        end
    end
end

function changeRadioURL(source, cmd, url)
	if not url then
		return outputChatBox("Dê: /"..cmd.." 'link-direto'   (SEM ASPAS)", source, 255, 255, 255)
	end

	local veh = getPedOccupiedVehicle(source)
	if veh then

		local playerSeat = getPedOccupiedVehicleSeat(source)
		if playerSeat ~= 0 and playerSeat ~= 1 then
			return
		end

		createVehData(veh)

		outputChatBox("#696969Você colocou uma música.", source, 255, 255, 255)

		vehicleList[veh].radio = url
		vehicleList[veh].changedBy = source
		vehicleList[veh].placedBy = source

		if vehicleList[veh].state then
			triggerClientEvent("onServerRadioURLChange", root, vehicleList[veh].radio, veh, vehicleList[veh].volume)
		end
	end
end
addCommandHandler("setradio", changeRadioURL, false, false)

function getRadioURL(source, cmd)
	local veh = getPedOccupiedVehicle(source)
	if veh then
		if vehicleList[veh] and vehicleList[veh].state and vehicleList[veh].radio then
			local text = string.format("URL: %s", vehicleList[veh].radio)
			outputChatBox(text, source)
		end
	end
end
addCommandHandler("getradio", getRadioURL, false, false)

addEvent("onPlayerRadioVolumeChange", true)
addEventHandler("onPlayerRadioVolumeChange", root, function(currentVol, volumeUp)
	if not client then
		return
	end
	local veh = getPedOccupiedVehicle(source)
	if veh and vehicleList[veh] and vehicleList[veh].state then
		local playerSeat = getPedOccupiedVehicleSeat(source)
		if playerSeat ~= 0 and playerSeat ~= 1 then
			return
		end
		if volumeUp then
			vehicleList[veh].volume = currentVol + 0.1
		else
			vehicleList[veh].volume = currentVol - 0.1
		end
		vehicleList[veh].volume = math.max(math.min(vehicleList[veh].volume, 1), 0)
		triggerClientEvent("onServerVolumeChangeAccept", root, veh, vehicleList[veh].volume)
	end
end)

function dumpAllRadios(source)
	local vehicles = getElementsByType("vehicle")
	for _, veh in ipairs( vehicles ) do
		if vehicleList[veh] and vehicleList[veh].state then
			local text
			local url = vehicleList[veh].radio
			local placed, changed = getPlayerName(vehicleList[veh].placedBy), getPlayerName(vehicleList[veh].changedBy)
			if placed then
				text = string.format("\nURL: %s\nColocada por: %s\nAlterada por: %s\n", url or "", placed or "", changed or "")
			end

			if getElementType(source) == "console" then
				outputServerLog(text)
			elseif getElementType(source) == "player" then
				outputChatBox(text, source, 255, 255, 255, true)
			end
		end
	end
end
addCommandHandler("dumpradio", dumpAllRadios)