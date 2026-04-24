-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: gshc_management
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `administrator`
--

DROP TABLE IF EXISTS `administrator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `administrator` (
  `AdminID` int(11) NOT NULL AUTO_INCREMENT,
  `Username` varchar(50) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `EmailAddress` varchar(100) NOT NULL,
  PRIMARY KEY (`AdminID`),
  UNIQUE KEY `Username` (`Username`),
  UNIQUE KEY `EmailAddress` (`EmailAddress`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `administrator`
--

LOCK TABLES `administrator` WRITE;
/*!40000 ALTER TABLE `administrator` DISABLE KEYS */;
INSERT INTO `administrator` VALUES (1,'admin_test','$2a$12$JnMBeQZQ1o/u4IUzwmQn6eR.cWnlk0rHPx.MQ4Ub6D9eINIjgUDOG','reyes@goodshepherdhome.ph'),(2,'admin_erediano','$2a$12$frnERDb.o5GpPsu.3jypjeTvfTC7BtINEXIxnlEcl/.uqE.v8S9tO','jErediano@goodshepherdhome.ph'),(3,'gshc_test','$2y$12$Jp4hBNf6nDqC/q5hY3u7T.yYOqkdUX1cFGwKPRJvjWWfa0Bmb62T.','gshc@goodshepherdhome.com.ph');
/*!40000 ALTER TABLE `administrator` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `caregiver`
--

DROP TABLE IF EXISTS `caregiver`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `caregiver` (
  `StaffID` int(11) NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `ContactNumber` varchar(20) NOT NULL,
  `AdminID` int(11) NOT NULL,
  `Username` varchar(50) DEFAULT NULL,
  `EmailAddress` varchar(100) DEFAULT NULL,
  `Password` varchar(255) DEFAULT NULL,
  `IsArchived` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0 = active, 1 = archived (resigned/transferred)',
  PRIMARY KEY (`StaffID`),
  UNIQUE KEY `Username` (`Username`),
  UNIQUE KEY `EmailAddress` (`EmailAddress`),
  KEY `fk_caregiver_admin` (`AdminID`),
  CONSTRAINT `fk_caregiver_admin` FOREIGN KEY (`AdminID`) REFERENCES `administrator` (`AdminID`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caregiver`
--

LOCK TABLES `caregiver` WRITE;
/*!40000 ALTER TABLE `caregiver` DISABLE KEYS */;
INSERT INTO `caregiver` VALUES (1,'Maria','Dela Cruz','09171234567',1,NULL,NULL,NULL,0),(2,'Jose','Reyes','09301234567',1,NULL,NULL,NULL,0),(3,'Ana','Santos','09191234567',2,NULL,NULL,NULL,0),(4,'Ramon','Flores','09201234567',2,NULL,NULL,NULL,0),(5,'Toph','Beifong','09877654321',1,'tBeifong','tBeifong@goodshepherdhome.com.ph','$2y$12$hMQIl/OcBDMxfo9ACJRcdeGJWNmZgrVcc.r8Zh8mgKAly6CmvcEUW',0);
/*!40000 ALTER TABLE `caregiver` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `familycontact`
--

DROP TABLE IF EXISTS `familycontact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `familycontact` (
  `ContactID` int(11) NOT NULL AUTO_INCREMENT,
  `ResidentID` int(11) NOT NULL,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `Relationship` varchar(50) NOT NULL,
  `PhoneNumber` varchar(20) NOT NULL,
  `Address` varchar(255) NOT NULL,
  `MOASignedDate` date DEFAULT NULL,
  PRIMARY KEY (`ContactID`),
  KEY `fk_contact_resident` (`ResidentID`),
  CONSTRAINT `fk_contact_resident` FOREIGN KEY (`ResidentID`) REFERENCES `resident` (`ResidentID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `familycontact`
--

LOCK TABLES `familycontact` WRITE;
/*!40000 ALTER TABLE `familycontact` DISABLE KEYS */;
INSERT INTO `familycontact` VALUES (1,1,'Ricardo','Garcia','Son','09221234567','123 Mabini St, Davao City','2023-01-10'),(3,2,'Pilar','Mendoza','Spouse','09241234567','789 Bonifacio St, Digos','2023-03-05'),(4,3,'Marco','Villanueva','Son','09251234567','12 Quezon Blvd, Tagum','2023-06-18'),(5,4,'Luisa','Bautista','Daughter','09261234567','34 Aguinaldo St, Davao City','2024-02-01');
/*!40000 ALTER TABLE `familycontact` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `healthlog`
--

DROP TABLE IF EXISTS `healthlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `healthlog` (
  `LogID` int(11) NOT NULL AUTO_INCREMENT,
  `ResidentID` int(11) NOT NULL,
  `StaffID` int(11) NOT NULL,
  `LogTimestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `SystolicBP` int(11) DEFAULT NULL,
  `DiastolicBP` int(11) DEFAULT NULL,
  `HeartRate` int(11) DEFAULT NULL,
  `Temperature` decimal(4,1) DEFAULT NULL,
  `OxygenSaturation` int(11) DEFAULT NULL,
  `MedicationStatusID` int(11) NOT NULL,
  `ResidentStatusID` int(11) NOT NULL,
  `CaregiverNotes` text DEFAULT NULL,
  PRIMARY KEY (`LogID`),
  KEY `fk_hl_resident` (`ResidentID`),
  KEY `fk_hl_caregiver` (`StaffID`),
  KEY `fk_hl_medstatus` (`MedicationStatusID`),
  KEY `fk_hl_resstatus` (`ResidentStatusID`),
  CONSTRAINT `fk_hl_caregiver` FOREIGN KEY (`StaffID`) REFERENCES `caregiver` (`StaffID`) ON UPDATE CASCADE,
  CONSTRAINT `fk_hl_medstatus` FOREIGN KEY (`MedicationStatusID`) REFERENCES `statuslookup` (`StatusID`) ON UPDATE CASCADE,
  CONSTRAINT `fk_hl_resident` FOREIGN KEY (`ResidentID`) REFERENCES `resident` (`ResidentID`) ON UPDATE CASCADE,
  CONSTRAINT `fk_hl_resstatus` FOREIGN KEY (`ResidentStatusID`) REFERENCES `statuslookup` (`StatusID`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `healthlog`
--

LOCK TABLES `healthlog` WRITE;
/*!40000 ALTER TABLE `healthlog` DISABLE KEYS */;
INSERT INTO `healthlog` VALUES (1,1,1,'2025-04-10 00:00:00',130,85,78,36.5,97,1,4,'Resident ate breakfast well.'),(2,2,1,'2025-04-10 00:30:00',145,90,82,37.1,95,2,7,'Refused morning medication. Noted.'),(3,3,2,'2025-04-10 08:00:00',120,80,75,36.8,98,1,5,'Resident sleeping after lunch.'),(4,4,2,'2025-04-10 08:30:00',160,100,95,38.2,92,3,6,'High BP observed. Physician notified.'),(5,1,3,'2025-04-10 23:00:00',128,83,76,36.6,98,1,4,'Overnight stable. No concerns.'),(6,4,4,'2026-04-21 09:52:28',140,96,70,36.7,85,1,4,'Under stable condition');
/*!40000 ALTER TABLE `healthlog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory` (
  `ItemID` int(11) NOT NULL AUTO_INCREMENT,
  `ItemName` varchar(100) NOT NULL,
  `QuantityOnHand` int(11) NOT NULL DEFAULT 0,
  `CategoryID` int(11) NOT NULL,
  `AdminID` int(11) NOT NULL,
  PRIMARY KEY (`ItemID`),
  KEY `fk_inventory_category` (`CategoryID`),
  KEY `fk_inventory_admin` (`AdminID`),
  CONSTRAINT `fk_inventory_admin` FOREIGN KEY (`AdminID`) REFERENCES `administrator` (`AdminID`) ON UPDATE CASCADE,
  CONSTRAINT `fk_inventory_category` FOREIGN KEY (`CategoryID`) REFERENCES `inventorycategory` (`CategoryID`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (1,'Adult Diapers (pack)',50,3,1),(2,'Wheelchair',5,5,1),(3,'Bed Sheets (set)',30,2,1),(4,'Paracetamol 500mg (box)',20,1,2),(5,'Alcohol 70% (bottle)',80,3,2),(6,'Ensure Powder (can)',15,4,2);
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_monitoring`
--

DROP TABLE IF EXISTS `inventory_monitoring`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory_monitoring` (
  `MonitoringID` int(11) NOT NULL AUTO_INCREMENT,
  `StaffID` int(11) NOT NULL,
  `ItemID` int(11) NOT NULL,
  `LastChecked` timestamp NOT NULL DEFAULT current_timestamp(),
  `Remarks` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`MonitoringID`),
  KEY `fk_im_caregiver` (`StaffID`),
  KEY `fk_im_inventory` (`ItemID`),
  CONSTRAINT `fk_im_caregiver` FOREIGN KEY (`StaffID`) REFERENCES `caregiver` (`StaffID`) ON UPDATE CASCADE,
  CONSTRAINT `fk_im_inventory` FOREIGN KEY (`ItemID`) REFERENCES `inventory` (`ItemID`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_monitoring`
--

LOCK TABLES `inventory_monitoring` WRITE;
/*!40000 ALTER TABLE `inventory_monitoring` DISABLE KEYS */;
INSERT INTO `inventory_monitoring` VALUES (1,1,1,'2025-04-01 00:00:00','Stock is adequate'),(2,1,3,'2025-04-01 00:05:00','Needs replenishment next week'),(3,2,4,'2025-04-02 08:00:00','Good stock level'),(4,3,5,'2025-04-02 23:30:00','Low stock - reorder needed'),(5,4,2,'2025-04-05 01:00:00','One wheelchair needs repair');
/*!40000 ALTER TABLE `inventory_monitoring` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventorycategory`
--

DROP TABLE IF EXISTS `inventorycategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventorycategory` (
  `CategoryID` int(11) NOT NULL AUTO_INCREMENT,
  `CategoryName` varchar(100) NOT NULL,
  PRIMARY KEY (`CategoryID`),
  UNIQUE KEY `CategoryName` (`CategoryName`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventorycategory`
--

LOCK TABLES `inventorycategory` WRITE;
/*!40000 ALTER TABLE `inventorycategory` DISABLE KEYS */;
INSERT INTO `inventorycategory` VALUES (5,'Equipment'),(4,'Food & Nutrition'),(3,'Hygiene & Sanitation'),(2,'Linen & Bedding'),(1,'Medical Supply');
/*!40000 ALTER TABLE `inventorycategory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medicationlog`
--

DROP TABLE IF EXISTS `medicationlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `medicationlog` (
  `MedLogID` int(11) NOT NULL AUTO_INCREMENT,
  `ResidentID` int(11) NOT NULL,
  `StaffID` int(11) NOT NULL,
  `MedName` varchar(100) NOT NULL,
  `Dosage` varchar(50) NOT NULL,
  `ScheduledAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `StatusID` int(11) NOT NULL,
  `Notes` text DEFAULT NULL,
  PRIMARY KEY (`MedLogID`),
  KEY `fk_ml_resident` (`ResidentID`),
  KEY `fk_ml_caregiver` (`StaffID`),
  KEY `fk_ml_status` (`StatusID`),
  CONSTRAINT `fk_ml_caregiver` FOREIGN KEY (`StaffID`) REFERENCES `caregiver` (`StaffID`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ml_resident` FOREIGN KEY (`ResidentID`) REFERENCES `resident` (`ResidentID`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ml_status` FOREIGN KEY (`StatusID`) REFERENCES `statuslookup` (`StatusID`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medicationlog`
--

LOCK TABLES `medicationlog` WRITE;
/*!40000 ALTER TABLE `medicationlog` DISABLE KEYS */;
INSERT INTO `medicationlog` VALUES (1,1,1,'Amlodipine','5mg','2025-04-10 00:00:00',1,NULL),(2,2,1,'Metformin','500mg','2025-04-10 00:00:00',2,'Resident said stomach is upset.'),(3,3,2,'Atorvastatin','20mg','2025-04-10 12:00:00',1,NULL),(4,4,2,'Losartan','50mg','2026-04-18 05:52:53',1,'Administered at next round.'),(5,1,3,'Amlodipine','5mg','2025-04-11 00:00:00',1,NULL),(6,5,3,'Losartan','3mg','2026-04-22 04:00:00',1,'Nagkaon na ug lunch. Naka inom na sad ug tambal');
/*!40000 ALTER TABLE `medicationlog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (5,'App\\Models\\Administrator',3,'carenest-token','5586b6bd44d9352dc116fa0bb133510fcf2ee37da4b948906003bace82874e77','[\"*\"]','2026-04-20 03:45:57',NULL,'2026-04-20 03:45:56','2026-04-20 03:45:57'),(11,'App\\Models\\Administrator',3,'carenest-token','d9ad337b59ecb65f8ff690118dea6a0d3937cadc7d63acb48364e51ff5ecc7ac','[\"*\"]','2026-04-21 05:27:24',NULL,'2026-04-21 05:19:33','2026-04-21 05:27:24'),(12,'App\\Models\\Administrator',3,'carenest-token','a437e9c892846ab6ee72f728e9f950c6ab35e9af3f484e704970ab4e494b8002','[\"*\"]','2026-04-21 18:35:03',NULL,'2026-04-21 16:34:48','2026-04-21 18:35:03'),(16,'App\\Models\\Administrator',3,'carenest-token','a8f9202d771df005359e45b806aac66e215684132557aad7bb0851112bb7218e','[\"*\"]','2026-04-23 02:18:45',NULL,'2026-04-22 20:01:49','2026-04-23 02:18:45');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resident`
--

DROP TABLE IF EXISTS `resident`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resident` (
  `ResidentID` int(11) NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `BirthDate` date NOT NULL,
  `AdmissionDate` date NOT NULL,
  `AdminID` int(11) NOT NULL,
  `IsArchived` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0 = active, 1 = archived (left/deceased)',
  PRIMARY KEY (`ResidentID`),
  KEY `fk_resident_admin` (`AdminID`),
  CONSTRAINT `fk_resident_admin` FOREIGN KEY (`AdminID`) REFERENCES `administrator` (`AdminID`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resident`
--

LOCK TABLES `resident` WRITE;
/*!40000 ALTER TABLE `resident` DISABLE KEYS */;
INSERT INTO `resident` VALUES (1,'Lourdes','Garcia','1942-03-15','2023-01-10',1,0),(2,'Roberto','Mendoza','1938-07-22','2023-03-05',1,0),(3,'Caridad','Villanueva','1945-11-30','2023-06-18',2,0),(4,'Ernesto','Bautista','1940-01-08','2024-02-01',2,0),(5,'Mildred','Antala','1952-03-12','2025-04-03',3,0);
/*!40000 ALTER TABLE `resident` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shiftschedule`
--

DROP TABLE IF EXISTS `shiftschedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shiftschedule` (
  `ShiftID` int(11) NOT NULL AUTO_INCREMENT,
  `StaffID` int(11) NOT NULL,
  `ShiftDay` varchar(10) NOT NULL,
  `StartTime` time NOT NULL,
  `EndTime` time NOT NULL,
  PRIMARY KEY (`ShiftID`),
  KEY `fk_shift_caregiver` (`StaffID`),
  CONSTRAINT `fk_shift_caregiver` FOREIGN KEY (`StaffID`) REFERENCES `caregiver` (`StaffID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shiftschedule`
--

LOCK TABLES `shiftschedule` WRITE;
/*!40000 ALTER TABLE `shiftschedule` DISABLE KEYS */;
INSERT INTO `shiftschedule` VALUES (10,1,'Monday','07:00:00','15:00:00'),(11,1,'Wednesday','07:00:00','15:00:00'),(13,2,'Tuesday','15:00:00','23:00:00'),(14,2,'Thursday','15:00:00','23:00:00'),(15,3,'Monday','23:00:00','07:00:00'),(16,3,'Tuesday','23:00:00','07:00:00'),(17,4,'Saturday','07:00:00','15:00:00'),(18,4,'Sunday','07:00:00','15:00:00');
/*!40000 ALTER TABLE `shiftschedule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `statuslookup`
--

DROP TABLE IF EXISTS `statuslookup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `statuslookup` (
  `StatusID` int(11) NOT NULL AUTO_INCREMENT,
  `Category` varchar(50) NOT NULL,
  `StatusValue` varchar(50) NOT NULL,
  PRIMARY KEY (`StatusID`),
  UNIQUE KEY `uq_status` (`Category`,`StatusValue`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `statuslookup`
--

LOCK TABLES `statuslookup` WRITE;
/*!40000 ALTER TABLE `statuslookup` DISABLE KEYS */;
INSERT INTO `statuslookup` VALUES (3,'MedicationStatus','Pending'),(2,'MedicationStatus','Refused'),(1,'MedicationStatus','Taken'),(6,'ResidentStatus','Critical'),(5,'ResidentStatus','Sleeping'),(4,'ResidentStatus','Stable'),(7,'ResidentStatus','Under Observation');
/*!40000 ALTER TABLE `statuslookup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `vw_caregiverworkload`
--

DROP TABLE IF EXISTS `vw_caregiverworkload`;
/*!50001 DROP VIEW IF EXISTS `vw_caregiverworkload`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_caregiverworkload` AS SELECT
 1 AS `StaffID`,
  1 AS `CaregiverName`,
  1 AS `ContactNumber`,
  1 AS `HealthLogsRecorded`,
  1 AS `MedLogsRecorded`,
  1 AS `TotalShifts` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_criticalresidents`
--

DROP TABLE IF EXISTS `vw_criticalresidents`;
/*!50001 DROP VIEW IF EXISTS `vw_criticalresidents`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_criticalresidents` AS SELECT
 1 AS `ResidentName`,
  1 AS `LogTimestamp`,
  1 AS `SystolicBP`,
  1 AS `DiastolicBP`,
  1 AS `HeartRate`,
  1 AS `Temperature`,
  1 AS `OxygenSaturation`,
  1 AS `ResidentStatus`,
  1 AS `AttendingCaregiver`,
  1 AS `CaregiverNotes` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_familycontactdirectory`
--

DROP TABLE IF EXISTS `vw_familycontactdirectory`;
/*!50001 DROP VIEW IF EXISTS `vw_familycontactdirectory`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_familycontactdirectory` AS SELECT
 1 AS `ResidentName`,
  1 AS `ContactName`,
  1 AS `Relationship`,
  1 AS `PhoneNumber`,
  1 AS `Address`,
  1 AS `MOASignedDate` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_latesthealthlog`
--

DROP TABLE IF EXISTS `vw_latesthealthlog`;
/*!50001 DROP VIEW IF EXISTS `vw_latesthealthlog`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_latesthealthlog` AS SELECT
 1 AS `ResidentID`,
  1 AS `ResidentName`,
  1 AS `LogTimestamp`,
  1 AS `SystolicBP`,
  1 AS `DiastolicBP`,
  1 AS `HeartRate`,
  1 AS `Temperature`,
  1 AS `OxygenSaturation`,
  1 AS `MedicationStatus`,
  1 AS `ResidentStatus`,
  1 AS `AttendingCaregiver`,
  1 AS `CaregiverNotes` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_lowstockinventory`
--

DROP TABLE IF EXISTS `vw_lowstockinventory`;
/*!50001 DROP VIEW IF EXISTS `vw_lowstockinventory`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_lowstockinventory` AS SELECT
 1 AS `ItemID`,
  1 AS `ItemName`,
  1 AS `CategoryName`,
  1 AS `QuantityOnHand`,
  1 AS `ManagedBy` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_medicationcompliance`
--

DROP TABLE IF EXISTS `vw_medicationcompliance`;
/*!50001 DROP VIEW IF EXISTS `vw_medicationcompliance`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_medicationcompliance` AS SELECT
 1 AS `ResidentName`,
  1 AS `TotalTaken`,
  1 AS `TotalRefused`,
  1 AS `TotalPending`,
  1 AS `TotalScheduled`,
  1 AS `ComplianceRate` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_residentsummary`
--

DROP TABLE IF EXISTS `vw_residentsummary`;
/*!50001 DROP VIEW IF EXISTS `vw_residentsummary`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_residentsummary` AS SELECT
 1 AS `ResidentID`,
  1 AS `ResidentName`,
  1 AS `BirthDate`,
  1 AS `Age`,
  1 AS `AdmissionDate`,
  1 AS `ManagedBy`,
  1 AS `TotalFamilyContacts` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_weeklyshiftschedule`
--

DROP TABLE IF EXISTS `vw_weeklyshiftschedule`;
/*!50001 DROP VIEW IF EXISTS `vw_weeklyshiftschedule`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_weeklyshiftschedule` AS SELECT
 1 AS `CaregiverName`,
  1 AS `ContactNumber`,
  1 AS `ShiftDay`,
  1 AS `StartTime`,
  1 AS `EndTime`,
  1 AS `ShiftDuration` */;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_caregiverworkload`
--

/*!50001 DROP VIEW IF EXISTS `vw_caregiverworkload`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_caregiverworkload` AS select `c`.`StaffID` AS `StaffID`,concat(`c`.`FirstName`,' ',`c`.`LastName`) AS `CaregiverName`,`c`.`ContactNumber` AS `ContactNumber`,count(distinct `hl`.`LogID`) AS `HealthLogsRecorded`,count(distinct `ml`.`MedLogID`) AS `MedLogsRecorded`,count(distinct `ss`.`ShiftID`) AS `TotalShifts` from (((`caregiver` `c` left join `healthlog` `hl` on(`c`.`StaffID` = `hl`.`StaffID`)) left join `medicationlog` `ml` on(`c`.`StaffID` = `ml`.`StaffID`)) left join `shiftschedule` `ss` on(`c`.`StaffID` = `ss`.`StaffID`)) group by `c`.`StaffID`,`c`.`FirstName`,`c`.`LastName`,`c`.`ContactNumber` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_criticalresidents`
--

/*!50001 DROP VIEW IF EXISTS `vw_criticalresidents`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_criticalresidents` AS select `lhl`.`ResidentName` AS `ResidentName`,`lhl`.`LogTimestamp` AS `LogTimestamp`,`lhl`.`SystolicBP` AS `SystolicBP`,`lhl`.`DiastolicBP` AS `DiastolicBP`,`lhl`.`HeartRate` AS `HeartRate`,`lhl`.`Temperature` AS `Temperature`,`lhl`.`OxygenSaturation` AS `OxygenSaturation`,`lhl`.`ResidentStatus` AS `ResidentStatus`,`lhl`.`AttendingCaregiver` AS `AttendingCaregiver`,`lhl`.`CaregiverNotes` AS `CaregiverNotes` from `vw_latesthealthlog` `lhl` where `lhl`.`ResidentStatus` in ('Critical','Under Observation') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_familycontactdirectory`
--

/*!50001 DROP VIEW IF EXISTS `vw_familycontactdirectory`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_familycontactdirectory` AS select concat(`r`.`FirstName`,' ',`r`.`LastName`) AS `ResidentName`,concat(`fc`.`FirstName`,' ',`fc`.`LastName`) AS `ContactName`,`fc`.`Relationship` AS `Relationship`,`fc`.`PhoneNumber` AS `PhoneNumber`,`fc`.`Address` AS `Address`,`fc`.`MOASignedDate` AS `MOASignedDate` from (`familycontact` `fc` left join `resident` `r` on(`fc`.`ResidentID` = `r`.`ResidentID`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_latesthealthlog`
--

/*!50001 DROP VIEW IF EXISTS `vw_latesthealthlog`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_latesthealthlog` AS select `r`.`ResidentID` AS `ResidentID`,concat(`r`.`FirstName`,' ',`r`.`LastName`) AS `ResidentName`,`hl`.`LogTimestamp` AS `LogTimestamp`,`hl`.`SystolicBP` AS `SystolicBP`,`hl`.`DiastolicBP` AS `DiastolicBP`,`hl`.`HeartRate` AS `HeartRate`,`hl`.`Temperature` AS `Temperature`,`hl`.`OxygenSaturation` AS `OxygenSaturation`,`ms`.`StatusValue` AS `MedicationStatus`,`rs`.`StatusValue` AS `ResidentStatus`,concat(`c`.`FirstName`,' ',`c`.`LastName`) AS `AttendingCaregiver`,`hl`.`CaregiverNotes` AS `CaregiverNotes` from ((((`healthlog` `hl` join `resident` `r` on(`hl`.`ResidentID` = `r`.`ResidentID`)) join `caregiver` `c` on(`hl`.`StaffID` = `c`.`StaffID`)) join `statuslookup` `ms` on(`hl`.`MedicationStatusID` = `ms`.`StatusID`)) join `statuslookup` `rs` on(`hl`.`ResidentStatusID` = `rs`.`StatusID`)) where `hl`.`LogTimestamp` = (select max(`hl2`.`LogTimestamp`) from `healthlog` `hl2` where `hl2`.`ResidentID` = `hl`.`ResidentID`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_lowstockinventory`
--

/*!50001 DROP VIEW IF EXISTS `vw_lowstockinventory`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_lowstockinventory` AS select `i`.`ItemID` AS `ItemID`,`i`.`ItemName` AS `ItemName`,`ic`.`CategoryName` AS `CategoryName`,`i`.`QuantityOnHand` AS `QuantityOnHand`,`a`.`Username` AS `ManagedBy` from ((`inventory` `i` left join `inventorycategory` `ic` on(`i`.`CategoryID` = `ic`.`CategoryID`)) left join `administrator` `a` on(`i`.`AdminID` = `a`.`AdminID`)) where `i`.`QuantityOnHand` < 10 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_medicationcompliance`
--

/*!50001 DROP VIEW IF EXISTS `vw_medicationcompliance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_medicationcompliance` AS select concat(`r`.`FirstName`,' ',`r`.`LastName`) AS `ResidentName`,sum(case when `sl`.`StatusValue` = 'Taken' then 1 else 0 end) AS `TotalTaken`,sum(case when `sl`.`StatusValue` = 'Refused' then 1 else 0 end) AS `TotalRefused`,sum(case when `sl`.`StatusValue` = 'Pending' then 1 else 0 end) AS `TotalPending`,count(`ml`.`MedLogID`) AS `TotalScheduled`,round(sum(case when `sl`.`StatusValue` = 'Taken' then 1 else 0 end) / count(`ml`.`MedLogID`) * 100,1) AS `ComplianceRate` from ((`medicationlog` `ml` left join `resident` `r` on(`ml`.`ResidentID` = `r`.`ResidentID`)) left join `statuslookup` `sl` on(`ml`.`StatusID` = `sl`.`StatusID`)) group by `r`.`ResidentID`,`r`.`FirstName`,`r`.`LastName` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_residentsummary`
--

/*!50001 DROP VIEW IF EXISTS `vw_residentsummary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_residentsummary` AS select `r`.`ResidentID` AS `ResidentID`,concat(`r`.`FirstName`,' ',`r`.`LastName`) AS `ResidentName`,`r`.`BirthDate` AS `BirthDate`,timestampdiff(YEAR,`r`.`BirthDate`,curdate()) AS `Age`,`r`.`AdmissionDate` AS `AdmissionDate`,`a`.`Username` AS `ManagedBy`,count(`fc`.`ContactID`) AS `TotalFamilyContacts` from ((`resident` `r` left join `administrator` `a` on(`r`.`AdminID` = `a`.`AdminID`)) left join `familycontact` `fc` on(`r`.`ResidentID` = `fc`.`ResidentID`)) group by `r`.`ResidentID`,`r`.`FirstName`,`r`.`LastName`,`r`.`BirthDate`,`r`.`AdmissionDate`,`a`.`Username` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_weeklyshiftschedule`
--

/*!50001 DROP VIEW IF EXISTS `vw_weeklyshiftschedule`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_weeklyshiftschedule` AS select concat(`c`.`FirstName`,' ',`c`.`LastName`) AS `CaregiverName`,`c`.`ContactNumber` AS `ContactNumber`,`ss`.`ShiftDay` AS `ShiftDay`,`ss`.`StartTime` AS `StartTime`,`ss`.`EndTime` AS `EndTime`,timediff(`ss`.`EndTime`,`ss`.`StartTime`) AS `ShiftDuration` from (`shiftschedule` `ss` left join `caregiver` `c` on(`ss`.`StaffID` = `c`.`StaffID`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-24 17:31:29
