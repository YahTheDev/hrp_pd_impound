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
	MaxWeeks		= 41,
	MaxDays			= 6,

	MinFee			= 250,
	MaxFee 			= 1000000,

	MinReasonLength	= 25,
}
