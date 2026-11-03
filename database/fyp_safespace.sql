-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 03, 2026 at 01:39 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fyp_safespace`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('super_admin','admin') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'admin',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `name`, `email`, `password`, `role`, `created_at`, `updated_at`) VALUES
(2, 'SafeSpace Admin', 'admin@safespace.test', '$2y$12$GdtSBN8yGcTOQIqIE.fyYeg0EC2JrefavSaO1MLRxL8soU/SAoQg2', 'super_admin', '2026-10-23 07:14:03', '2026-10-23 07:14:03');

-- --------------------------------------------------------

--
-- Table structure for table `admins_questionnaire`
--

CREATE TABLE `admins_questionnaire` (
  `id` bigint UNSIGNED NOT NULL,
  `admin_id` bigint UNSIGNED NOT NULL,
  `title` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `question` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` json NOT NULL,
  `is_published` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admins_questionnaire`
--

INSERT INTO `admins_questionnaire` (`id`, `admin_id`, `title`, `question`, `options`, `is_published`, `created_at`, `updated_at`) VALUES
(1, 2, 'Daily Wellbeing Check-In', 'How supported have you felt today?', '[{\"label\": \"Not at all\", \"score\": 1}, {\"label\": \"A little\", \"score\": 2}, {\"label\": \"Moderately\", \"score\": 3}, {\"label\": \"Quite a lot\", \"score\": 4}, {\"label\": \"Very much\", \"score\": 5}]', 1, '2026-10-27 20:50:48', '2026-10-27 20:50:48'),
(2, 2, 'Daily Wellbeing Check-In', 'How manageable have your daily activities felt?', '[{\"label\": \"Not at all\", \"score\": 1}, {\"label\": \"A little\", \"score\": 2}, {\"label\": \"Moderately\", \"score\": 3}, {\"label\": \"Quite a lot\", \"score\": 4}, {\"label\": \"Very much\", \"score\": 5}]', 1, '2026-10-27 20:50:48', '2026-10-27 20:50:48'),
(3, 2, 'Daily Wellbeing Check-In', 'How hopeful do you feel about the coming days?', '[{\"label\": \"Not at all\", \"score\": 1}, {\"label\": \"A little\", \"score\": 2}, {\"label\": \"Moderately\", \"score\": 3}, {\"label\": \"Quite a lot\", \"score\": 4}, {\"label\": \"Very much\", \"score\": 5}]', 1, '2026-10-27 20:50:48', '2026-10-27 20:50:48');

-- --------------------------------------------------------

--
-- Table structure for table `admins_questionnaire_reply`
--

CREATE TABLE `admins_questionnaire_reply` (
  `id` bigint UNSIGNED NOT NULL,
  `questionnaire_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `selected_answer` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `score` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admins_questionnaire_reply`
--

INSERT INTO `admins_questionnaire_reply` (`id`, `questionnaire_id`, `user_id`, `selected_answer`, `score`, `created_at`, `updated_at`) VALUES
(1, 1, 12, 'Moderately', 3, '2026-10-27 20:53:15', '2026-10-27 20:53:15'),
(2, 2, 12, 'Moderately', 3, '2026-10-27 20:53:15', '2026-10-27 20:53:15'),
(3, 3, 12, 'Moderately', 3, '2026-10-27 20:53:15', '2026-10-27 20:53:15'),
(4, 1, 12, 'Not at all', 1, '2026-10-27 20:58:56', '2026-10-27 20:58:56'),
(5, 2, 12, 'Not at all', 1, '2026-10-27 20:58:56', '2026-10-27 20:58:56'),
(6, 3, 12, 'Not at all', 1, '2026-10-27 20:58:56', '2026-10-27 20:58:56'),
(7, 1, 12, 'Moderately', 3, '2026-10-28 06:53:06', '2026-10-28 06:53:06'),
(8, 2, 12, 'Quite a lot', 4, '2026-10-28 06:53:06', '2026-10-28 06:53:06'),
(9, 3, 12, 'Quite a lot', 4, '2026-10-28 06:53:06', '2026-10-28 06:53:06');

-- --------------------------------------------------------

--
-- Table structure for table `admins_tips`
--

CREATE TABLE `admins_tips` (
  `id` bigint UNSIGNED NOT NULL,
  `admin_id` bigint UNSIGNED NOT NULL,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('article','tip') COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_published` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admins_tips`
--

INSERT INTO `admins_tips` (`id`, `admin_id`, `title`, `content`, `category`, `type`, `is_published`, `created_at`, `updated_at`) VALUES
(1, 2, 'Understanding Daily Stress', 'Stress is a common response to daily challenges. Taking short breaks, maintaining a routine, and talking to someone you trust can support your well-being.', 'Mental Health', 'article', 1, '2026-10-28 06:25:15', '2026-10-28 06:36:13'),
(2, 2, 'Simple Breathing Break', 'Find a comfortable position and breathe gently at a pace that feels natural. Notice your surroundings and allow yourself a moment to rest.', 'Relaxation', 'tip', 1, '2026-10-28 06:26:23', '2026-10-28 06:26:23');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2026_10_25_053813_create_personal_access_tokens_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint UNSIGNED NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 12, 'safespace-mobile', 'a4fc6a15ccc209288a8292d7bb0fc2b2d5534baa1ebd9fec9faea32f5b7ee239', '[\"*\"]', '2026-10-24 22:40:07', '2026-11-23 22:39:45', '2026-10-24 22:39:45', '2026-10-24 22:40:07'),
(6, 'App\\Models\\User', 12, 'safespace-mobile', 'eb33a1da830c38f587b1d4162586d4c52a7d20a5728e9c9cbf858ce1511c70db', '[\"*\"]', '2026-10-25 03:11:27', '2026-11-24 03:10:13', '2026-10-25 03:10:13', '2026-10-25 03:11:27'),
(8, 'App\\Models\\User', 12, 'safespace-mobile', 'e9e1308305cd896198a09b2f7d6e3228b8907e568479365425e34e1c1f03bede', '[\"*\"]', '2026-10-25 04:03:21', '2026-11-24 04:02:17', '2026-10-25 04:02:17', '2026-10-25 04:03:21'),
(11, 'App\\Models\\User', 12, 'safespace-mobile', '03cafa20710c15f6d126fda3359c819889fab328eba4d1f741eb5d30038fc578', '[\"*\"]', '2026-10-27 20:53:15', '2026-11-26 20:52:25', '2026-10-27 20:52:26', '2026-10-27 20:53:15'),
(14, 'App\\Models\\User', 12, 'safespace-mobile', 'b4a26222cc277024f029f4e2480fd928956c1e153322a4a376d58246c1f6bd28', '[\"*\"]', '2026-10-27 21:30:28', '2026-11-26 21:28:52', '2026-10-27 21:28:52', '2026-10-27 21:30:28'),
(17, 'App\\Models\\User', 12, 'safespace-mobile', 'a29614ca0e9807cd07723e8226d2bfdb969ceefde6f85568a9b547db5f7a627b', '[\"*\"]', '2026-10-28 06:30:22', '2026-11-27 06:28:47', '2026-10-28 06:28:47', '2026-10-28 06:30:22'),
(19, 'App\\Models\\User', 12, 'safespace-mobile', '71d92e6888ea45c784dfca66dd944b7d5fb3b7402fb1ea9eaee3df0397136774', '[\"*\"]', '2026-10-28 07:07:22', '2026-11-27 06:51:58', '2026-10-28 06:51:58', '2026-10-28 07:07:22'),
(22, 'App\\Models\\User', 12, 'safespace-mobile', '74742400fdb1ac51d5f3c54f15f44ab5fced9d3bb1977a66778cc71114240d65', '[\"*\"]', '2026-11-02 04:09:21', '2026-12-02 03:59:12', '2026-11-02 03:59:12', '2026-11-02 04:09:21');

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `id` bigint UNSIGNED NOT NULL,
  `reporter_user_id` bigint UNSIGNED DEFAULT NULL,
  `target_type` enum('journal','reply') COLLATE utf8mb4_unicode_ci NOT NULL,
  `journal_id` bigint UNSIGNED DEFAULT NULL,
  `reply_id` bigint UNSIGNED DEFAULT NULL,
  `reason` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','reviewed','resolved') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `admin_notes` text COLLATE utf8mb4_unicode_ci,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `account_status` enum('active','inactive') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `last_login_at`, `created_at`, `updated_at`, `account_status`) VALUES
(1, 'aiman01', 'aiman01@example.com', 'a109e36947ad56de1dca1cc49f0ef8ac9ad9a7b1aa0df41fb3c4cb73c1ff01ea', '2026-10-24 14:40:44', '2026-10-24 06:40:44', '2026-10-24 06:40:44', 'active'),
(2, 'sarah02', 'sarah02@example.com', 'a109e36947ad56de1dca1cc49f0ef8ac9ad9a7b1aa0df41fb3c4cb73c1ff01ea', '2026-10-23 14:40:44', '2026-10-24 06:40:44', '2026-10-24 06:40:44', 'active'),
(3, 'danial03', 'danial03@example.com', 'a109e36947ad56de1dca1cc49f0ef8ac9ad9a7b1aa0df41fb3c4cb73c1ff01ea', '2026-10-22 14:40:44', '2026-10-24 06:40:44', '2026-10-24 06:40:44', 'active'),
(4, 'aisyah04', 'aisyah04@example.com', 'a109e36947ad56de1dca1cc49f0ef8ac9ad9a7b1aa0df41fb3c4cb73c1ff01ea', '2026-10-21 14:40:44', '2026-10-24 06:40:44', '2026-10-24 06:40:44', 'active'),
(5, 'hakim05', 'hakim05@example.com', 'a109e36947ad56de1dca1cc49f0ef8ac9ad9a7b1aa0df41fb3c4cb73c1ff01ea', '2026-10-20 14:40:44', '2026-10-24 06:40:44', '2026-10-24 06:40:44', 'active'),
(6, 'nurin06', 'nurin06@example.com', 'a109e36947ad56de1dca1cc49f0ef8ac9ad9a7b1aa0df41fb3c4cb73c1ff01ea', '2026-10-19 14:40:44', '2026-10-24 06:40:44', '2026-10-24 06:40:44', 'active'),
(7, 'faris07', 'faris07@example.com', 'a109e36947ad56de1dca1cc49f0ef8ac9ad9a7b1aa0df41fb3c4cb73c1ff01ea', '2026-10-18 14:40:44', '2026-10-24 06:40:44', '2026-10-24 06:40:44', 'active'),
(8, 'alya08', 'alya08@example.com', 'a109e36947ad56de1dca1cc49f0ef8ac9ad9a7b1aa0df41fb3c4cb73c1ff01ea', '2026-10-17 14:40:44', '2026-10-24 06:40:44', '2026-10-24 06:40:44', 'active'),
(9, 'irfan09', 'irfan09@example.com', 'a109e36947ad56de1dca1cc49f0ef8ac9ad9a7b1aa0df41fb3c4cb73c1ff01ea', '2026-10-16 14:40:44', '2026-10-24 06:40:44', '2026-10-24 06:40:44', 'active'),
(10, 'hannah10', 'hannah10@example.com', 'a109e36947ad56de1dca1cc49f0ef8ac9ad9a7b1aa0df41fb3c4cb73c1ff01ea', '2026-10-15 14:40:44', '2026-10-24 06:40:44', '2026-10-24 07:54:50', 'active'),
(11, 'safespace_test_01', 'safespace_test_01@example.com', '$2y$12$h55rj3npezt7rSKlMMlyeOdBicMwwW1NWfgWrnMWPgaRP3W4jiWS.', NULL, '2026-10-24 21:54:05', '2026-10-24 21:54:05', 'active'),
(12, 'kim', 'kim@gmail.com', '$2y$12$UDzhq6Fjk3zTLWqtqjBMH.kEfkf4NxU5COh0WttM9XjWdTs2kI1Bq', NULL, '2026-10-24 22:20:30', '2026-10-24 22:20:30', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `users_journal`
--

CREATE TABLE `users_journal` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `title` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `moderation_status` enum('normal','hidden') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'normal'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users_journal`
--

INSERT INTO `users_journal` (`id`, `user_id`, `title`, `content`, `created_at`, `updated_at`, `moderation_status`) VALUES
(2, 2, 'A small reminder for everyone', 'Just wanted to remind anyone reading this that it is okay to take a break. You do not have to be productive every single day. Sometimes getting out of bed, eating a proper meal, or simply making it through the day is already an achievement. Be kind to yourself.', '2026-10-24 02:21:59', '2026-10-24 08:19:41', 'normal'),
(3, 3, 'Anyone else struggling to sleep?', 'It is almost 3 AM and my brain just refuses to switch off. I keep overthinking things that happened months ago and worrying about things that have not even happened yet. If anyone has tips for calming their mind before sleeping, I would really appreciate it.', '2026-10-23 07:21:59', '2026-10-23 07:21:59', 'normal'),
(4, 12, 'My First SafeSpace Journal', 'Today I am testing the anonymous community journal feature.', '2026-10-25 03:10:56', '2026-10-25 03:10:56', 'normal');

-- --------------------------------------------------------

--
-- Table structure for table `users_journal_replies`
--

CREATE TABLE `users_journal_replies` (
  `id` bigint UNSIGNED NOT NULL,
  `journal_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users_journal_replies`
--

INSERT INTO `users_journal_replies` (`id`, `journal_id`, `user_id`, `content`, `created_at`, `updated_at`) VALUES
(1, 4, 12, 'Thank you for sharing your thoughts!', '2026-10-25 03:11:18', '2026-10-25 03:11:18'),
(2, 2, 12, 'okay', '2026-10-29 04:05:37', '2026-10-29 04:05:37');

-- --------------------------------------------------------

--
-- Table structure for table `users_mental_health`
--

CREATE TABLE `users_mental_health` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `mood` enum('very_bad','bad','neutral','good','very_good') COLLATE utf8mb4_unicode_ci NOT NULL,
  `mood_score` tinyint UNSIGNED NOT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `recorded_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users_mental_health`
--

INSERT INTO `users_mental_health` (`id`, `user_id`, `mood`, `mood_score`, `note`, `recorded_date`, `created_at`, `updated_at`) VALUES
(1, 12, 'very_good', 5, 'im so happy today', '2026-10-25', '2026-10-25 04:02:31', '2026-10-25 04:12:28'),
(5, 12, 'good', 4, 'Self-assessment: Daily Wellbeing Check-In', '2026-10-28', '2026-10-27 20:53:15', '2026-10-28 06:53:06');

-- --------------------------------------------------------

--
-- Table structure for table `users_profile`
--

CREATE TABLE `users_profile` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `display_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text COLLATE utf8mb4_unicode_ci,
  `avatar_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users_task`
--

CREATE TABLE `users_task` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `title` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `status` enum('pending','in_progress','completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users_task`
--

INSERT INTO `users_task` (`id`, `user_id`, `title`, `description`, `category`, `due_date`, `status`, `created_at`, `updated_at`) VALUES
(1, 12, 'Complete FYP Report', 'Currently working on the testing chapter.', 'Study', '2026-10-30', 'completed', '2026-10-27 21:29:17', '2026-11-02 04:31:42');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `admins_questionnaire`
--
ALTER TABLE `admins_questionnaire`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_questionnaire_admin` (`admin_id`);

--
-- Indexes for table `admins_questionnaire_reply`
--
ALTER TABLE `admins_questionnaire_reply`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_questionnaire_reply_question` (`questionnaire_id`),
  ADD KEY `idx_assessment_user` (`user_id`,`created_at`);

--
-- Indexes for table `admins_tips`
--
ALTER TABLE `admins_tips`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_tips_admin` (`admin_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_reports_status` (`status`),
  ADD KEY `idx_reports_created_at` (`created_at`),
  ADD KEY `fk_reports_reporter` (`reporter_user_id`),
  ADD KEY `fk_reports_journal` (`journal_id`),
  ADD KEY `fk_reports_reply` (`reply_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `users_journal`
--
ALTER TABLE `users_journal`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_journal_user` (`user_id`),
  ADD KEY `idx_journal_created` (`created_at`);

--
-- Indexes for table `users_journal_replies`
--
ALTER TABLE `users_journal_replies`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_reply_user` (`user_id`),
  ADD KEY `idx_reply_journal` (`journal_id`);

--
-- Indexes for table `users_mental_health`
--
ALTER TABLE `users_mental_health`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_mood_date` (`user_id`,`recorded_date`);

--
-- Indexes for table `users_profile`
--
ALTER TABLE `users_profile`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `users_task`
--
ALTER TABLE `users_task`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_task_user_date` (`user_id`,`due_date`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `admins_questionnaire`
--
ALTER TABLE `admins_questionnaire`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `admins_questionnaire_reply`
--
ALTER TABLE `admins_questionnaire_reply`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `admins_tips`
--
ALTER TABLE `admins_tips`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `users_journal`
--
ALTER TABLE `users_journal`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users_journal_replies`
--
ALTER TABLE `users_journal_replies`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users_mental_health`
--
ALTER TABLE `users_mental_health`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `users_profile`
--
ALTER TABLE `users_profile`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users_task`
--
ALTER TABLE `users_task`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admins_questionnaire`
--
ALTER TABLE `admins_questionnaire`
  ADD CONSTRAINT `fk_questionnaire_admin` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE RESTRICT;

--
-- Constraints for table `admins_questionnaire_reply`
--
ALTER TABLE `admins_questionnaire_reply`
  ADD CONSTRAINT `fk_questionnaire_reply_question` FOREIGN KEY (`questionnaire_id`) REFERENCES `admins_questionnaire` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_questionnaire_reply_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `admins_tips`
--
ALTER TABLE `admins_tips`
  ADD CONSTRAINT `fk_tips_admin` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE RESTRICT;

--
-- Constraints for table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `fk_reports_journal` FOREIGN KEY (`journal_id`) REFERENCES `users_journal` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_reports_reply` FOREIGN KEY (`reply_id`) REFERENCES `users_journal_replies` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_reports_reporter` FOREIGN KEY (`reporter_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `users_journal`
--
ALTER TABLE `users_journal`
  ADD CONSTRAINT `fk_journal_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users_journal_replies`
--
ALTER TABLE `users_journal_replies`
  ADD CONSTRAINT `fk_reply_journal` FOREIGN KEY (`journal_id`) REFERENCES `users_journal` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_reply_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users_mental_health`
--
ALTER TABLE `users_mental_health`
  ADD CONSTRAINT `fk_mental_health_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users_profile`
--
ALTER TABLE `users_profile`
  ADD CONSTRAINT `fk_profile_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users_task`
--
ALTER TABLE `users_task`
  ADD CONSTRAINT `fk_task_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
