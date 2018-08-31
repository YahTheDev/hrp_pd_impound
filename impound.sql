CREATE TABLE `h_impounded_vehicles` (
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