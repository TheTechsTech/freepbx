-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: asteriskcdrdb
-- ------------------------------------------------------
-- Server version	5.1.73

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

DROP DATABASE IF EXISTS asteriskcdrdb;
CREATE DATABASE asteriskcdrdb;
USE asteriskcdrdb;

--
-- Table structure for table `cdr`
--

DROP TABLE IF EXISTS `cdr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdr` (
  `calldate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `clid` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `src` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `dst` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `dcontext` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `channel` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `dstchannel` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `lastapp` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `lastdata` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `duration` int(11) NOT NULL DEFAULT '0',
  `billsec` int(11) NOT NULL DEFAULT '0',
  `disposition` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `amaflags` int(11) NOT NULL DEFAULT '0',
  `accountcode` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `uniqueid` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `userfield` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `did` varchar(50) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `recordingfile` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `cnum` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `cnam` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `outbound_cnum` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `outbound_cnam` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `dst_cnam` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  KEY `calldate` (`calldate`),
  KEY `dst` (`dst`),
  KEY `accountcode` (`accountcode`),
  KEY `uniqueid` (`uniqueid`),
  KEY `did` (`did`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cdr`
--

LOCK TABLES `cdr` WRITE;
/*!40000 ALTER TABLE `cdr` DISABLE KEYS */;
/*!40000 ALTER TABLE `cdr` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cel`
--

DROP TABLE IF EXISTS `cel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `eventtype` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `eventtime` datetime NOT NULL,
  `cid_name` varchar(80) COLLATE utf8_unicode_ci NOT NULL,
  `cid_num` varchar(80) COLLATE utf8_unicode_ci NOT NULL,
  `cid_ani` varchar(80) COLLATE utf8_unicode_ci NOT NULL,
  `cid_rdnis` varchar(80) COLLATE utf8_unicode_ci NOT NULL,
  `cid_dnid` varchar(80) COLLATE utf8_unicode_ci NOT NULL,
  `exten` varchar(80) COLLATE utf8_unicode_ci NOT NULL,
  `context` varchar(80) COLLATE utf8_unicode_ci NOT NULL,
  `channame` varchar(80) COLLATE utf8_unicode_ci NOT NULL,
  `appname` varchar(80) COLLATE utf8_unicode_ci NOT NULL,
  `appdata` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `amaflags` int(11) NOT NULL,
  `accountcode` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  `uniqueid` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `linkedid` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `peer` varchar(80) COLLATE utf8_unicode_ci NOT NULL,
  `userdeftype` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `extra` varchar(512) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniqueid_index` (`uniqueid`),
  KEY `linkedid_index` (`linkedid`),
  KEY `context_index` (`context`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cel`
--

LOCK TABLES `cel` WRITE;
/*!40000 ALTER TABLE `cel` DISABLE KEYS */;
/*!40000 ALTER TABLE `cel` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-11-11  7:32:56
