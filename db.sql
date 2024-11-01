-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 01, 2024 at 08:01 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pawtner`
--
CREATE DATABASE IF NOT EXISTS `pawtner` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `pawtner`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `AcceptAdoptionAppointment`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AcceptAdoptionAppointment` (IN `appointmentId` INT)   BEGIN
    DECLARE petId INT;

    -- Get the pet_id from the appointment being accepted
    SELECT pet_id INTO petId FROM Appointments WHERE appointment_id = appointmentId;

    -- Cancel all other appointments for the pet
    UPDATE Appointments
    SET status = 'canceled'
    WHERE pet_id = petId AND appointment_id <> appointmentId;

    -- Set the pet's adoption status to 'yes'
    UPDATE Pets
    SET adoption_status = 'yes'
    WHERE pet_id = petId;

    -- Change the status of the accepted appointment to 'completed'
    UPDATE Appointments
    SET status = 'completed'
    WHERE appointment_id = appointmentId;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
CREATE TABLE `appointments` (
  `appointment_id` int(11) NOT NULL,
  `pet_id` int(11) NOT NULL,
  `customer_name` varchar(255) NOT NULL,
  `customer_number` varchar(15) NOT NULL,
  `appointment_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('scheduled','completed','canceled') DEFAULT 'scheduled'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `appointments`
--
DROP TRIGGER IF EXISTS `limit_one_active_appointment`;
DELIMITER $$
CREATE TRIGGER `limit_one_active_appointment` BEFORE INSERT ON `appointments` FOR EACH ROW BEGIN
    -- Check if there's already an active (non-canceled) appointment for the pet
    DECLARE active_count INT;
    SELECT COUNT(*) INTO active_count
    FROM Appointments
    WHERE pet_id = NEW.pet_id AND status <> 'canceled';

    -- If an active appointment exists, prevent the insert
    IF active_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pet already has been Appointed for Adoption';
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `prevent_appointments_for_adopted_pets`;
DELIMITER $$
CREATE TRIGGER `prevent_appointments_for_adopted_pets` BEFORE INSERT ON `appointments` FOR EACH ROW BEGIN
    DECLARE pet_status ENUM('no', 'pending', 'yes');

    -- Get the adoption status of the pet
    SELECT adoption_status INTO pet_status FROM Pets WHERE pet_id = NEW.pet_id;

    -- Raise an error if the pet is adopted
    IF pet_status = 'yes' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot create appointment for adopted pet';
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `reset_adoption_status_no`;
DELIMITER $$
CREATE TRIGGER `reset_adoption_status_no` AFTER UPDATE ON `appointments` FOR EACH ROW BEGIN
    -- Check if there are no remaining scheduled appointments for the pet
        DECLARE scheduled_count INT;
        SELECT COUNT(*) INTO scheduled_count
        FROM Appointments
        WHERE pet_id = OLD.pet_id AND status = 'scheduled';

    -- Prevent status change if the current status is "canceled" or "completed"
    IF OLD.status IN ('canceled', 'completed') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot change status of a canceled or completed appointment.';
    END IF;

    -- Check if the appointment status was changed to "canceled"
    IF OLD.status = 'scheduled' AND NEW.status = 'canceled' THEN

        IF scheduled_count = 0 THEN
            -- If no scheduled appointments exist, update the pet's adoption status to "no"
            UPDATE Pets
            SET adoption_status = 'no'
            WHERE pet_id = OLD.pet_id AND adoption_status = 'pending';
        END IF;
    END IF;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `set_adoption_status_pending`;
DELIMITER $$
CREATE TRIGGER `set_adoption_status_pending` AFTER INSERT ON `appointments` FOR EACH ROW BEGIN
    UPDATE Pets
    SET adoption_status = 'pending'
    WHERE pet_id = NEW.pet_id AND adoption_status = 'no';
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `set_appointment_status_scheduled`;
DELIMITER $$
CREATE TRIGGER `set_appointment_status_scheduled` BEFORE INSERT ON `appointments` FOR EACH ROW BEGIN
    SET NEW.status = 'scheduled';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pets`
--

DROP TABLE IF EXISTS `pets`;
CREATE TABLE `pets` (
  `pet_id` int(11) NOT NULL,
  `pet_name` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `age` varchar(50) NOT NULL,
  `breed` varchar(50) NOT NULL,
  `size` enum('small','medium','large') NOT NULL,
  `gender` enum('male','female') NOT NULL,
  `shelter_id` int(11) NOT NULL,
  `volunteer_id` int(11) NOT NULL,
  `category` enum('cat','dog') NOT NULL,
  `adoption_status` enum('no','pending','yes') NOT NULL DEFAULT 'no'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Truncate table before insert `pets`
--

TRUNCATE TABLE `pets`;
--
-- Dumping data for table `pets`
--

INSERT INTO `pets` (`pet_id`, `pet_name`, `image`, `description`, `age`, `breed`, `size`, `gender`, `shelter_id`, `volunteer_id`, `category`, `adoption_status`) VALUES
(1, 'Zuri', 'https://tinyurl.com/yxtw4vvd', 'An amazing and playful dog', 'Young', 'Poodle', 'medium', 'female', 1, 1, 'dog', 'no'),
(2, 'Koko', 'https://tinyurl.com/5hx2wtp9', 'Very obedient and well trained', 'Adult', 'Dachshund', 'large', 'male', 2, 2, 'dog', 'no'),
(3, 'Neema', 'https://tinyurl.com/2p9sc5pa', 'Loves playing fetch and always down for food', '3 months', 'Bernese Mountain Dog', 'small', 'female', 3, 3, 'dog', 'no'),
(4, 'Azizi', 'https://tinyurl.com/ycycrnx2', 'Best companion ever. Very lovable', 'Young', 'Corgi', 'medium', 'male', 4, 4, 'dog', 'no'),
(5, 'Amani', 'https://tinyurl.com/2p9eu6ka', 'Very affectionate and playful', 'Young', 'Shih Tzu', 'medium', 'female', 5, 5, 'dog', 'no'),
(6, 'Hasif', 'https://tinyurl.com/2539p6ey', 'Good with children and very affectionate', 'Young', 'Golden Retriever', 'large', 'male', 6, 6, 'dog', 'no');

--
-- Triggers `pets`
--
DROP TRIGGER IF EXISTS `prevent_invalid_adoption_status_change`;
DELIMITER $$
CREATE TRIGGER `prevent_invalid_adoption_status_change` BEFORE UPDATE ON `pets` FOR EACH ROW BEGIN
    -- Prevent changing adoption status from 'yes' to 'pending' or 'no'
    IF OLD.adoption_status = 'yes' AND (NEW.adoption_status = 'pending' OR NEW.adoption_status = 'no') THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot change adoption status from "yes" back to "pending" or "no"';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `shelters`
--

DROP TABLE IF EXISTS `shelters`;
CREATE TABLE `shelters` (
  `shelter_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `place` varchar(255) NOT NULL,
  `phone` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Truncate table before insert `shelters`
--

TRUNCATE TABLE `shelters`;
--
-- Dumping data for table `shelters`
--

INSERT INTO `shelters` (`shelter_id`, `name`, `place`, `phone`) VALUES
(1, 'Happy Paws Shelter', 'Panjim, Goa', '123-456-7890'),
(2, 'The Pet Store', 'Mumbai, Maharashtra', '123-456-7890'),
(3, 'Paws and Claws Rescue', 'Kannur, Kerala', '123-456-7890'),
(4, 'Fur Friends', 'Pune, Maharashtra', '123-456-7890'),
(5, 'Wag House', 'Nitte, Karnataka', '123-456-7890'),
(6, 'Paws Place', 'Mangalore, Karnataka', '123-456-7890');

-- --------------------------------------------------------

--
-- Table structure for table `volunteers`
--

DROP TABLE IF EXISTS `volunteers`;
CREATE TABLE `volunteers` (
  `volunteer_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Truncate table before insert `volunteers`
--

TRUNCATE TABLE `volunteers`;
--
-- Dumping data for table `volunteers`
--

INSERT INTO `volunteers` (`volunteer_id`, `name`) VALUES
(1, 'Alice Smith'),
(2, 'Bob Johnson'),
(3, 'Carol White'),
(4, 'David Brown'),
(5, 'Eve Davis'),
(6, 'Frank Miller');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`appointment_id`),
  ADD KEY `pet_id` (`pet_id`);

--
-- Indexes for table `pets`
--
ALTER TABLE `pets`
  ADD PRIMARY KEY (`pet_id`),
  ADD KEY `shelter_id` (`shelter_id`),
  ADD KEY `volunteer_id` (`volunteer_id`);

--
-- Indexes for table `shelters`
--
ALTER TABLE `shelters`
  ADD PRIMARY KEY (`shelter_id`);

--
-- Indexes for table `volunteers`
--
ALTER TABLE `volunteers`
  ADD PRIMARY KEY (`volunteer_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `appointment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pets`
--
ALTER TABLE `pets`
  MODIFY `pet_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `shelters`
--
ALTER TABLE `shelters`
  MODIFY `shelter_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `volunteers`
--
ALTER TABLE `volunteers`
  MODIFY `volunteer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`pet_id`) REFERENCES `pets` (`pet_id`);

--
-- Constraints for table `pets`
--
ALTER TABLE `pets`
  ADD CONSTRAINT `pets_ibfk_1` FOREIGN KEY (`shelter_id`) REFERENCES `shelters` (`shelter_id`),
  ADD CONSTRAINT `pets_ibfk_2` FOREIGN KEY (`volunteer_id`) REFERENCES `volunteers` (`volunteer_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
