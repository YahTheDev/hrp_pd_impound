_ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) _ESX = obj end)

-- Allowed to reset during server restart
-- You can use this number to calculate a vehicle spawn location index if you have multiple
-- eg: 3 spawnlocations = index % 3 + 1
local _UnimpoundedVehicleCount = 1;

RegisterServerEvent('HRP:Impound:ImpoundVehicle')
RegisterServerEvent('HRP:Impound:GetImpoundedVehicles')
RegisterServerEvent('HRP:Impound:UnimpoundVehicle')

AddEventHandler('HRP:Impound:ImpoundVehicle', function (form)
	Citizen.Trace("HRP: Impounding vehicle: " .. form.plate);
	_source = source;
	MySQL.Async.execute('INSERT INTO `h_impounded_vehicles` VALUES (@plate, @officer, @mechanic, @releasedate, @fee, @reason, @notes, CONCAT(@vehicle), @identifier)',
		{
			['@plate'] 			= form.plate,
			['@officer']     	= form.officer,
			['@mechanic']       = form.mechanic,
			['@releasedate']	= form.releasedate, 
			['@fee']			= form.fee, 
			['@reason']			= form.reason, 
			['@notes']			= form.notes,
			['@vehicle']		= form.vehicle,
			['@identifier']		= form.identifier
		}, function(rowsChanged)
			if (rowsChanged == 0) then
				TriggerClientEvent('esx:showNotification', _source, 'Could not impound')
			else
				TriggerClientEvent('esx:showNotification', _source, 'Vehicle Impounded')
			end
	end)
end)

AddEventHandler('HRP:Impound:GetImpoundedVehicles', function (identifier)
	_source = source;
	MySQL.Async.fetchAll('SELECT * FROM `h_impounded_vehicles` WHERE `identifier` = @identifier ORDER BY `releasedate`',
		{
			['@identifier'] = identifier,
		}, function (impoundedVehicles)
			TriggerClientEvent('HRP:Impound:SetImpoundedVehicles', _source, impoundedVehicles)
	end)
end)

AddEventHandler('HRP:Impound:UnimpoundVehicle', function (plate)
	_source = source;
	xPlayer = _ESX.GetPlayerFromId(_source)
		
	_UnimpoundedVehicleCount = _UnimpoundedVehicleCount + 1;
	
	Citizen.Trace('HRP: Unimpounding Vehicle with plate: ' .. plate);
	
	local veh = MySQL.Sync.fetchAll('SELECT * FROM `h_impounded_vehicles` WHERE `plate` = @plate',
	{
		['@plate'] = plate,
	})
	
	if(veh == nil) then
		TriggerClientEvent("HRP:Impound:CannotUnimpound")
		return
	end
	
	if (xPlayer.getMoney() < veh[1].fee) then
		TriggerClientEvent("HRP:Impound:CannotUnimpound")
	else
		
		xPlayer.removeMoney(round(veh[1].fee));
		
		MySQL.Async.execute('DELETE FROM `h_impounded_vehicles` WHERE `plate` = @plate',
		{
			['@plate'] = plate,
		}, function (rows)
			TriggerClientEvent('HRP:Impound:VehicleUnimpounded', _source, veh[1], _UnimpoundedVehicleCount)
		end)
	end
end)

-------------------------------------------------------------------------------------------------------------------------------
-- Stupid extra shit because fuck all of this
-------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('HRP:ESX:GetCharacter')
AddEventHandler('HRP:ESX:GetCharacter', function (identifier)
	local _source = source
	MySQL.Async.fetchAll('SELECT * FROM `users` WHERE `identifier` = @identifier',
		{
			['@identifier'] 		= identifier,
		}, function(users)
		TriggerClientEvent('HRP:ESX:SetCharacter', _source, users[1]);
	end)
end)

RegisterServerEvent('HRP:ESX:GetVehicleAndOwner')
AddEventHandler('HRP:ESX:GetVehicleAndOwner', function (plate)
	local _source = source
	MySQL.Async.fetchAll('select * from `owned_vehicles` LEFT JOIN `users` ON users.identifier = owned_vehicles.owner WHERE `plate` = rtrim(@plate)',
		{
			['@plate'] 		= plate,
		}, function(vehicleAndOwner)
		TriggerClientEvent('HRP:ESX:SetVehicleAndOwner', _source, vehicleAndOwner[1]);
	end)
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

function round(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end