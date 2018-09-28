CREATE TABLE IF NOT EXiSTS `h_impounded_vehicles` (
  `plate` varchar(12) NOT NULL,
  `officer` varchar(255) DEFAULT NULL,
  `mechanic` varchar(255) DEFAULT NULL,
  `releasedate` date NOT NULL,
  `fee` double NOT NULL,
  `reason` text NOT NULL,
  `notes` text,
  `vehicle` text NOT NULL,
  `identifier` varchar(30) NOT NULL,
  PRIMARY KEY (`plate`)
);

-- Update 01
ALTER TABLE `h_impounded_vehicles`
	ADD COLUMN `hold_o` boolean default false,
	ADD COLUMN `hold_m` boolean default false;

-- Update 03 Hours
ALTER TABLE h_impounded_vehicles  MODIFY COLUMN `releasedate` VARCHAR(25);