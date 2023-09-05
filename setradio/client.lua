--| Criado por 6A666C6D | Melhorado por theAlex
--| https://community.multitheftauto.com/index.php?p=resources&s=details&id=3104

radioSound = {
	['soundElement'] = nil,
}

syncKey = 165414876135

MinDistance = 10
MaxDistance = 45

function toggleRadio()
	if getPedOccupiedVehicle(localPlayer) and not isPedDoingGangDriveby(localPlayer) then
		triggerServerEvent("onPlayerToggleRadio", localPlayer)
	end
end

function getActualRadio(theVehicle)
	local theRadio = radioSound[theVehicle]
	if theRadio and isElement( theRadio.soundElement ) then
		return theRadio.soundElement
	end
	return false
end

function stopActualRadio(theVehicle)
	local nowRadio = getActualRadio(theVehicle)
	if nowRadio then -- URL DA RADIO SETADA, APOS LIGAR RADIO
		if getSoundPosition(nowRadio) then
			stopSound(nowRadio)
			radioSound[theVehicle] = {}
			return true
		end
	end
	return false
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	bindKey("r", "down", toggleRadio)
	bindKey("mouse_wheel_up", "down", volume)
	bindKey("mouse_wheel_down", "down", volume)
end)

addEventHandler("onClientSoundFinishedDownload", root, function()
	if getElementData(source, syncKey) then
		local newtime = (getTickCount() - getElementData(source, syncKey)) / 1000
		if newtime < (getSoundLength(source) + newtime) then
			setSoundPaused(source, true)
			setSoundPosition(source, newtime )
			setSoundPaused(source, false)
		end
	end
end)

addEventHandler("onClientSoundStream", root, function()
	if getElementData(source, syncKey) then
		setSoundPaused(source, true)
	end
end)

addEvent("onServerToggleRadio", true)
addEventHandler("onServerToggleRadio", localPlayer, function(toggle, url, veh, volume)
	if not isElement(veh) then
		return
	end
	if not url then
		return
	end

	if toggle then
		local x, y, z = getElementPosition(veh)
		local sound = playSound3D(url, x, y, z, false, false)
		setElementData(sound, syncKey, getTickCount() )
		stopActualRadio(veh)
		if volume then
			setSoundVolume(sound, volume)
		end
		if sound then
			setSoundMinDistance(sound, MinDistance)
			setSoundMaxDistance(sound, MaxDistance)
			attachElements(sound, veh)
		end
		radioSound[veh] = {}
		radioSound[veh].soundElement = sound
	else
		stopActualRadio(veh)
	end
end)

addEvent("onServerRadioURLChange", true)
addEventHandler("onServerRadioURLChange", localPlayer, function(newurl, veh, volume)
	stopActualRadio(veh)
	local x, y, z = getElementPosition(veh)
	local sound = playSound3D(newurl, x, y, z, false, false)
	setElementData(sound, syncKey, getTickCount() )
	if volume then
		setSoundVolume(sound, volume)
	end
	if sound then
		setSoundMinDistance(sound, MinDistance)
		setSoundMaxDistance(sound, MaxDistance)
		attachElements(sound, veh)
	end
	radioSound[veh] = {}
	radioSound[veh].soundElement = sound
end)

addEvent("onServerVolumeChangeAccept", true)
addEventHandler("onServerVolumeChangeAccept", localPlayer, function(veh, newVolume)
	if not veh then
		return
	end
	local nowRadio = getActualRadio(veh)
	if nowRadio then
		setSoundVolume(nowRadio, newVolume)
	end
end)

local toBool = {
	['mouse_wheel_up'] = true,
	['mouse_wheel_down'] = false,
}

function volume(state)
	if getPedOccupiedVehicle(localPlayer) and not isPedDoingGangDriveby(localPlayer) then
		local veh = getPedOccupiedVehicle(localPlayer)
		local nowRadio = getActualRadio(veh)
		if nowRadio then
			local volume = getSoundVolume(nowRadio)
			if volume then
				triggerServerEvent("onPlayerRadioVolumeChange", localPlayer, volume, toBool[state])
			end
		end
	end
end