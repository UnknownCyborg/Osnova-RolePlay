-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Хост: 127.0.0.1
-- Время создания: Май 07 2020 г., 21:50
-- Версия сервера: 5.5.25
-- Версия PHP: 5.3.13

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- База данных: `montana`
--

-- --------------------------------------------------------

--
-- Структура таблицы `accounts`
--

CREATE TABLE IF NOT EXISTS `accounts` (
  `pID` int(8) NOT NULL AUTO_INCREMENT,
  `pName` varchar(24) NOT NULL,
  `pPassword` varchar(64) NOT NULL,
  `pSalt` varchar(10) NOT NULL,
  `pEmail` varchar(64) NOT NULL,
  `pRef` int(8) NOT NULL DEFAULT '0',
  `pRefmoney` int(9) NOT NULL DEFAULT '0',
  `pSex` int(1) NOT NULL,
  `pRace` int(1) NOT NULL,
  `pAge` int(2) NOT NULL,
  `pSkin` int(3) NOT NULL,
  `pRegdate` varchar(12) NOT NULL,
  `pRegip` varchar(15) NOT NULL,
  `pAdmin` int(4) NOT NULL DEFAULT '0',
  `pMoney` int(9) NOT NULL DEFAULT '100',
  `pLvl` int(6) NOT NULL DEFAULT '1',
  `pExp` int(10) NOT NULL DEFAULT '0',
  `pPin` varchar(6) NOT NULL DEFAULT '0,0',
  `pLastip` varchar(15) NOT NULL DEFAULT '0.0.0.0',
  `pGoogleauth` varchar(16) NOT NULL DEFAULT '0',
  `pGs` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`pID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
