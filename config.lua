Config 					= {}

Config.Impound 			= {
	Name = "MissionRow",
	RetrieveLocation = { X = 826.30, Y = -1290.20, Z = 28.60 },
	StoreLocation = { X = 872.64, Y = -1350.50, Z = 26.30 },
	SpawnLocations = {
		{ x = 818.21, y = -1334.90, z = 26.10 , h = 180.00 },
		{ x = 818.21, y = -1341.20, z = 26.10 , h = 180.00 },
		{ x = 818.21, y = -1349.00, z = 26.10 , h = 180.00 },
		{ x = 818.21, y = -1355.00, z = 26.10 , h = 180.00 },
		{ x = 818.21, y = -1363.00, z = 26.10 , h = 180.00 },
	},
	AdminTerminalLocations = {
		{ x = 830.30, y = -1311.09, z = 28.13 },
		{ x = 440.18, y = -976.00, z = 30.68 }
	}
}

Config.Rules = {
	maxWeeks		= 5,
	maxDays			= 6,
	maxHours		= 24,

	minFee			= 50,
	maxFee 			= 15000,

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
