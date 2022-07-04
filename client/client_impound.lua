----------------------------------------------------------------------------------------------------
-- Variables
----------------------------------------------------------------------------------------------------

local _ESX = nil;
local _XPlayer = nil;
local _OwnPlayerData = nil;
local _DependenciesLoaded = false;
local hasAlreadyEnteredMarker, lastZone
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

RegisterNetEvent('HRP:ESX:SetImpoundedVehicles')
AddEventHandler('HRP:ESX:SetImpoundedVehicles', function (impoundedVehicles)
	_ImpoundedVehicles = impoundedVehicles;
end)

RegisterNetEvent('HRP:ESX:VehicleUnimpounded')
AddEventHandler('HRP:ESX:VehicleUnimpounded', function (data, index)

	_ESX.ShowNotification("Your vehicle with the plate: " .. data.plate .. " has been unimpounded! check Garage A!")

end)

RegisterNetEvent('HRP:ESX:CannotUnimpound')
AddEventHandler('HRP:ESX:CannotUnimpound', function ()
	exports['okokNotify']:Alert("Information", "Beta Paise le kr ao ghar se ja kr." , 5000, 'warning')
end)

----------------------------------------------------------------------------------------------------
-- NUI bs
----------------------------------------------------------------------------------------------------

RegisterNetEvent('HRP:ESX:impoundMenu')
AddEventHandler('HRP:ESX:impoundMenu', function ()

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
			_ESX.ShowNotification('Are You Sure this vehicle belongs to a Human not Alien..!');
			return
		end

		data.action = "open"
		data.form 	= "impound"
		data.rules  = Config.Rules
		data.vehicle = {
			plate = _VehicleAndOwner.plate,
			owner = _VehicleAndOwner.name
			}

		
			data.officer = _OwnPlayerData.name
			_GuiEnabled = true
			SetNuiFocus(true, true)
			SendNuiMessage(json.encode(data))

	else
		_ESX.ShowNotification('No vehicle nearby');
	end
end)


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
	TriggerServerEvent('HRP:ESX:GetImpoundedVehicles', _XPlayer.identifier)
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

     cb('ok')
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

	TriggerServerEvent('HRP:ESX:ImpoundVehicle', data)

	_ESX.Game.DeleteVehicle(_ESX.Game.GetClosestVehicle());

	DisableImpoundMenu()
     cb('ok')
end)

RegisterNUICallback('unimpound', function(plate, cb)
	Citizen.Trace("Unimpounding:" .. plate)
	TriggerServerEvent('HRP:ESX:UnimpoundVehicle', plate);
	DisableImpoundMenu();
	 cb('ok');
end)

RegisterNUICallback('unlock', function(plate, cb)
	TriggerServerEvent('HRP:ESX:UnlockVehicle', plate)
end)
----------------------------------------------------------------------------------------------------
-- Background tasks
----------------------------------------------------------------------------------------------------

-- Decide what the player is currently doing and showing a help notification.
Citizen.CreateThread(function ()

	while true do
		inZone = false;
		Citizen.Wait(0)
		if(_DependenciesLoaded) then
			local PlayerPed = GetPlayerPed(PlayerId())
			local PlayerPedCoords = GetEntityCoords(PlayerPed)
			
			
			
			while _ESX.GetPlayerData().job == nil do
			Citizen.Wait(10)
				end
			
			local _XPlayer = _ESX.GetPlayerData()
			
			for k,v in pairs(Config.Impound.RetrieveLocation) do
			local distance = #(PlayerPedCoords - v)

			if distance < 100 then
				
				DrawMarker(2, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.2, 225, 225, 225, 225, false, true, 2, true, nil, nil, false)
			
				
				if distance < 1 then
				inZone = true;
				if (_CurrentAction ~= "retrieve") then
					_CurrentAction = "retrieve"
					_ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ To unimpound a vehicle");

				end
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
