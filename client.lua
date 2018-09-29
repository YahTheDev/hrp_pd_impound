----------------------------------------------------------------------------------------------------
-- Variables
----------------------------------------------------------------------------------------------------

local _ESX = nil;
local _XPlayer = nil;
local _OwnPlayerData = nil;
local _DependenciesLoaded = false;

local _Impound = Config.Impound

local _GuiEnabled = false

local _VehicleAndOwner = nil;

local _ImpoundedVehicles = nil;

----------------------------------------------------------------------------------------------------
-- Setup & Initialization
----------------------------------------------------------------------------------------------------

Citizen.CreateThread(function ()

	while _ESX == nil do
		TriggerEvent("esx:getSharedObject", function(obj) _ESX = obj end)
		Citizen.Wait(10)
	end

	while _ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	_DependenciesLoaded = true;
	_XPlayer = _ESX.GetPlayerData()
end)

function ActivateBlips()
	local blip = AddBlipForCoord(_Impound.RetrieveLocation.X, _Impound.RetrieveLocation.Y, _Impound.RetrieveLocation.Z)
	SetBlipScale(blip, 1.25)
	SetBlipDisplay(blip, 4)
	SetBlipSprite(blip, 430)
	SetBlipColour(blip, 3)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Police Impound")
    EndTextCommandSetBlipName(blip)
end

ActivateBlips()

----------------------------------------------------------------------------------------------------
-- Helper functions
----------------------------------------------------------------------------------------------------

function ShowHelpNotification(text)
    ClearAllHelpMessages();
    SetTextComponentFormat("STRING");
    AddTextComponentString(text);
    DisplayHelpTextFromStringLabel(0, false, true, 5000);
end

RegisterNetEvent('HRP:ESX:SetCharacter')
AddEventHandler('HRP:ESX:SetCharacter', function (playerData)
	_OwnPlayerData = playerData
end)

RegisterNetEvent('HRP:ESX:SetVehicleAndOwner')
AddEventHandler('HRP:ESX:SetVehicleAndOwner', function (vehicleAndOwner)
	_VehicleAndOwner = vehicleAndOwner;
end)

RegisterNetEvent('HRP:Impound:SetImpoundedVehicles')
AddEventHandler('HRP:Impound:SetImpoundedVehicles', function (impoundedVehicles)
	_ImpoundedVehicles = impoundedVehicles;
end)

RegisterNetEvent('HRP:Impound:VehicleUnimpounded')
AddEventHandler('HRP:Impound:VehicleUnimpounded', function (data, index)
	local spawnLocationIndex = index % 3 + 1
	local localVehicle = json.decode(data.vehicle)
	print(localVehicle.health);
	_ESX.Game.SpawnVehicle(localVehicle.model, _Impound.SpawnLocations[spawnLocationIndex],
		_Impound.SpawnLocations[spawnLocationIndex].h, function (spawnedVehicle)
		_ESX.Game.SetVehicleProperties(spawnedVehicle, localVehicle)

		SetVehicleEngineHealth(spawnedVehicle, localVehicle.engineHealth);
		SetVehicleBodyHealth(spawnedVehicle, localVehicle.bodyHealth);
		SetVehicleFuelLevel(spawnedVehicle, localVehicle.fuelLevel);
		SetVehiclePetrolTankHealth(spawnedVehicle, localVehicle.petrolTankHealth);
		SetVehicleOilLevel(spawnedVehicle, localVehicle.oilLevel);
		SetVehicleDirtLevel(spawnedVehicle, localVehicle.dirtLevel);

		for windowIndex = 1, 13, 1 do
			Citizen.Trace("Smashing window! ")
			if(localVehicle.windows[windowIndex] == false) then
				SmashVehicleWindow(spawnedVehicle, windowIndex);
			end
		end

		for tyreIndex = 1, 7, 1 do
			Citizen.Trace("Pooppiiiin! ")
			if(localVehicle.tyresburst[tyreIndex] ~= false) then
				SetVehicleTyreBurst(spawnedVehicle, tyreIndex, true, 1000);
			end
		end

	end)
	_ESX.ShowNotification("Your vehicle with the plate: " .. data.plate .. " has been unimpounded!")
	SetNewWaypoint(_Impound.SpawnLocations[spawnLocationIndex].x, _Impound.SpawnLocations[spawnLocationIndex].y)
end)

RegisterNetEvent('HRP:Impound:CannotUnimpound')
AddEventHandler('HRP:Impound:CannotUnimpound', function ()
	_ESX.ShowNotification("Your vehicle cannot be unimpounded at this moment, do you have enough cash?");
end)

----------------------------------------------------------------------------------------------------
-- NUI bs
----------------------------------------------------------------------------------------------------

function ShowImpoundMenu (action)

	local pos = GetEntityCoords(GetPlayerPed(PlayerId()))
	local vehicle = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 71)

	if (IsPedInAnyVehicle(GetPlayerPed(PlayerId()))) then
		_ESX.ShowNotification("Leave the vehicle first")
		return
	end


	if (vehicle ~= nil) then
		local v = _ESX.Game.GetVehicleProperties(vehicle)
		local data = {}

		TriggerServerEvent('HRP:ESX:GetCharacter', _XPlayer.identifier)
		TriggerServerEvent('HRP:ESX:GetVehicleAndOwner', v.plate)
		Citizen.Wait(500);

		if(Config.NoPlateColumn == true) then
			Citizen.Wait(Config.WaitTime);
		end

		if(_VehicleAndOwner == nil) then
			_ESX.ShowNotification('Unknown vehicle owner, cannot impound');
			return
		end

		data.action = "open"
		data.form 	= "impound"
		data.rules  = Config.Rules
		data.vehicle = {
			plate = _VehicleAndOwner.plate,
			owner = _VehicleAndOwner.firstname .. ' ' .. _VehicleAndOwner.lastname
			}

		if (_XPlayer.job.name == 'police') then
			data.officer = _OwnPlayerData.firstname .. ' ' .. _OwnPlayerData.lastname;
			_GuiEnabled = true
			SetNuiFocus(true, true)
			SendNuiMessage(json.encode(data))
		end

		if (_XPlayer.job.name == 'mecano') then
			data.mechanic = _OwnPlayerData.firstname .. ' ' .. _OwnPlayerData.lastname;
			_GuiEnabled = true
			SetNuiFocus(true, true)
			SendNuiMessage(json.encode(data))
		end
	else
		_ESX.ShowNotification('No vehicle nearby');
	end

end

function ShowAdminTerminal ()
	_XPlayer = _ESX.GetPlayerData()
	_GuiEnabled = true

	TriggerServerEvent('HRP:Impound:GetVehicles')
	Citizen.Wait(500)

	SetNuiFocus(true, true)
	local data = {
		action = "open",
		form = "admin",
		user = _OwnPlayerData,
		job = _XPlayer.job,
		vehicles = _ImpoundedVehicles
	}

	SendNuiMessage(json.encode(data))
end

function DisableImpoundMenu ()
	_GuiEnabled = false
	SetNuiFocus(false)
	SendNuiMessage("{\"action\": \"close\", \"form\": \"none\"}")
	_OwnPlayerData = nil;
	_VehicleAndOwner = nil;
	_ImpoundedVehicles = nil;
end

function ShowRetrievalMenu ()

	_XPlayer = _ESX.GetPlayerData()

	TriggerServerEvent('HRP:ESX:GetCharacter', _XPlayer.identifier)
	TriggerServerEvent('HRP:Impound:GetImpoundedVehicles', _XPlayer.identifier)
	Citizen.Wait(500)

	_GuiEnabled = true
	SetNuiFocus(true, true)
	local data = {
		action = "open",
		form = "retrieve",
		user = _OwnPlayerData,
		job = _XPlayer.job,
		vehicles = _ImpoundedVehicles
	}

	SendNuiMessage(json.encode(data))
end

RegisterNUICallback('escape', function(data, cb)
	DisableImpoundMenu()

    -- cb('ok')
end)

RegisterNUICallback('impound', function(data, cb)
	local v = _ESX.Game.GetClosestVehicle();
	local veh = _ESX.Game.GetVehicleProperties(v);

	veh.engineHealth = GetVehicleEngineHealth(v);
	veh.bodyHealth = GetVehicleBodyHealth(v);
	veh.fuelLevel = GetVehicleFuelLevel(v);
	veh.oilLevel = GetVehicleOilLevel(v);
	veh.petrolTankHealth = GetVehiclePetrolTankHealth(v);
	veh.tyresburst = {};
	for i = 1, 7 do
		res = IsVehicleTyreBurst(v, i, false);
		if res ~= nil then
			veh.tyresburst[#veh.tyresburst+1] = res;
			if res == false then
				res = IsVehicleTyreBurst(v, i, true);
				veh.tyresburst[#veh.tyresburst] = res;
			end
		else
			veh.tyresburst[#veh.tyresburst+1] = false;
		end
	end

	veh.windows = {};
	for i = 1, 13 do
		res = IsVehicleWindowIntact(v, i);
		if res ~= nil then
			veh.windows[#veh.windows+1] = res;
		else
			veh.windows[#veh.windows+1] = true;
		end
	end

	if (veh.plate:gsub("%s+", "") ~= data.plate:gsub("%s+", "")) then
		_ESX.ShowNotification("The processed vehicle, and nearest vehicle do not match");
		return
	end

	data.vehicle = json.encode(veh);
	data.identifier = _VehicleAndOwner.identifier;

	TriggerServerEvent('HRP:Impound:ImpoundVehicle', data)

	_ESX.Game.DeleteVehicle(_ESX.Game.GetClosestVehicle());

	DisableImpoundMenu()
    -- cb('ok')
end)

RegisterNUICallback('unimpound', function(plate, cb)
	Citizen.Trace("Unimpounding:" .. plate)
	TriggerServerEvent('HRP:Impound:UnimpoundVehicle', plate);
	DisableImpoundMenu();
	-- cb('ok');
end)

RegisterNUICallback('unlock', function(plate, cb)
	TriggerServerEvent('HRP:Impound:UnlockVehicle', plate)
end)
----------------------------------------------------------------------------------------------------
-- Background tasks
----------------------------------------------------------------------------------------------------

-- Decide what the player is currently doing and showing a help notification.
Citizen.CreateThread(function ()

	while true do
		inZone = false;
		Citizen.Wait(500)
		if(_DependenciesLoaded) then
			local PlayerPed = GetPlayerPed(PlayerId())
			local PlayerPedCoords = GetEntityCoords(PlayerPed)

			if (GetDistanceBetweenCoords(_Impound.RetrieveLocation.X, _Impound.RetrieveLocation.Y, _Impound.RetrieveLocation.Z,
				PlayerPedCoords.x, PlayerPedCoords.y, PlayerPedCoords.z, false) < 3) then

				inZone = true;

				if (_CurrentAction ~= "retrieve") then

					_CurrentAction = "retrieve"
					_ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ To unimpound a vehicle");

				end

			elseif (GetDistanceBetweenCoords(_Impound.StoreLocation.X, _Impound.StoreLocation.Y, _Impound.StoreLocation.Z,
				PlayerPedCoords.x, PlayerPedCoords.y, PlayerPedCoords.z, false) < 3) then

				inZone = true;

				if (_CurrentAction ~= "store" and (_XPlayer.job.name == "police" or _XPlayer.job.name == "mecano")) then

					_CurrentAction = "store"
					_ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ To impound this vehicle");

				end

			else
				for i, location in ipairs(_Impound.AdminTerminalLocations) do
					if (GetDistanceBetweenCoords(location.x, location.y, location.z,
					PlayerPedCoords.x, PlayerPedCoords.y, PlayerPedCoords.z, false) < 3) then

						inZone = true;

						if (_CurrentAction ~= "admin" and (_XPlayer.job.name == "police" or _XPlayer.job.name == "mecano")) then

							_CurrentAction = "admin"
							_ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ To open the admin terminal");
						end

						break;
					end
				end
			end
		end

		if not inZone then
			_CurrentAction = nil;
		end
	end
end)

Citizen.CreateThread(function ()

	while true do
		Citizen.Wait(0)
		if (IsControlJustReleased(0, 38)) then
			if (_CurrentAction == "retrieve") then
				ShowRetrievalMenu()
			elseif (_CurrentAction == "store") then
				ShowImpoundMenu("store")
			elseif (_CurrentAction == "admin") then
				ShowAdminTerminal("admin")
			end
		end
	end
end)

-- Disable background actions if the player is currently in a menu
Citizen.CreateThread(function()
  while true do
    if _GuiEnabled then
      local ply = GetPlayerPed(-1)
      local active = true
      DisableControlAction(0, 1, active) -- LookLeftRight
      DisableControlAction(0, 2, active) -- LookUpDown
      DisableControlAction(0, 24, active) -- Attack
      DisablePlayerFiring(ply, true) -- Disable weapon firing
      DisableControlAction(0, 142, active) -- MeleeAttackAlternate
      DisableControlAction(0, 106, active) -- VehicleMouseControlOverride
      if IsDisabledControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
        SendNUIMessage({type = "click"})
      end
    end
    Citizen.Wait(0)
  end
end)

function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end
