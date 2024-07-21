-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jul 02, 2024 at 06:03 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `audio_events_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `audio_events`
--

CREATE TABLE `audio_events` (
  `device_number` int(11) NOT NULL,
  `filename` text NOT NULL,
  `event_time` bigint(20) NOT NULL,
  `event_name` text NOT NULL,
  `time` bigint(20) NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audio_events`
--

INSERT INTO `audio_events` (`device_number`, `filename`, `event_time`, `event_name`, `time`, `id`) VALUES
(1, '1719892646.468604.wav', 1719892646, 'Gurgling', 1719892646, 890),
(1, '1719892647.509228.wav', 1719892647, 'Gurgling', 1719892647, 891),
(1, '1719892648.5656154.wav', 1719892648, 'Gurgling', 1719892648, 892),
(1, '1719892649.6253471.wav', 1719892649, 'Water', 1719892649, 893),
(1, '1719892650.6817634.wav', 1719892650, 'Water', 1719892650, 894),
(1, '1719892651.737356.wav', 1719892651, 'Water', 1719892651, 895),
(1, '1719892846.2766151.wav', 1719892846, 'Water', 1719892846, 896),
(1, '1719892847.3382897.wav', 1719892847, 'Gurgling', 1719892847, 897),
(1, '1719892848.367019.wav', 1719892848, 'Water', 1719892848, 898),
(1, '1719892849.396795.wav', 1719892849, 'Water', 1719892849, 899);

-- --------------------------------------------------------

--
-- Table structure for table `device_status`
--

CREATE TABLE `device_status` (
  `id` int(11) NOT NULL,
  `cpu_usage` int(11) NOT NULL,
  `ram_usage` bigint(32) NOT NULL,
  `time` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `device_status`
--

INSERT INTO `device_status` (`id`, `cpu_usage`, `ram_usage`, `time`) VALUES
(13, 5, 7293190144, 1719892647),
(14, 11, 7241428992, 1719892648),
(15, 4, 7249690624, 1719892649),
(16, 5, 7249494016, 1719892650),
(17, 6, 7250477056, 1719892651),
(18, 12, 7175962624, 1719892847),
(19, 4, 7128543232, 1719892848),
(20, 5, 7136788480, 1719892849);

-- --------------------------------------------------------

--
-- Table structure for table `micro_status`
--

CREATE TABLE `micro_status` (
  `temp` int(11) NOT NULL,
  `device` int(11) NOT NULL,
  `time` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `micro_status`
--

INSERT INTO `micro_status` (`temp`, `device`, `time`) VALUES
(100, 100, 1),
(100, 100, 1),
(100, 100, 1),
(100, 100, 1),
(100, 100, 1),
(100, 100, 1),
(100, 100, 1),
(100, 100, 1),
(100, 100, 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `audio_events`
--
ALTER TABLE `audio_events`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `device_status`
--
ALTER TABLE `device_status`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `audio_events`
--
ALTER TABLE `audio_events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=900;

--
-- AUTO_INCREMENT for table `device_status`
--
ALTER TABLE `device_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
