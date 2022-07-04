Config = {}

----------------------------------------------------------------------
--------------------CONFIG IMPOUND Gargae-----------------------------
----------------------------------------------------------------------

Config.Impound 			= {
	Name = "MissionRow",
	RetrieveLocation = { 
	
	vector3(437.55331420898,-624.58343505859,28.708402633667),

	},

}

Config.Rules = {   --------FOR IMPOUND
	maxWeeks		= 5,
	maxDays			= 6,
	maxHours		= 24,

	minFee			= 50,
	maxFee 			= 50000,

	minReasonLength	= 10,
}
--------------------------------------------------------------------------------
----------------------- SERVERS WITHOUT ESX_MIGRATE ----------------------------
---------------- This could work, it also could not work... --------------------
--------------------------------------------------------------------------------

-- Should be true if you still have an owned_vehicles table without plate column.
Config.NoPlateColumn = false
-- Only change when NoPlateColumn is true, menu's will take longer to show but otherwise you might not have any data.
-- Try increments of 250
Config.WaitTime = 250
-------------------------Impound END--------------------------------------------
-----------------------------------------------------------------------------
