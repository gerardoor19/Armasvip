CREATE TABLE IF NOT EXISTS `armasvip_grants` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `owner_key` VARCHAR(160) NOT NULL,
  `owner_name` VARCHAR(100) NOT NULL,
  `weapon` VARCHAR(80) NOT NULL,
  `components` LONGTEXT NOT NULL,
  `tint` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `assigned_by` VARCHAR(160) NOT NULL,
  `assigned_by_name` VARCHAR(100) NOT NULL,
  `assigned_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` TIMESTAMP NULL DEFAULT NULL,
  `status` VARCHAR(16) NOT NULL DEFAULT 'active',
  `initial_delivered` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_armasvip_owner_status` (`owner_key`, `status`),
  KEY `idx_armasvip_expiry` (`status`, `expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `armasvip_cosmetics` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `grant_id` BIGINT UNSIGNED NOT NULL,
  `cosmetic_type` VARCHAR(24) NOT NULL,
  `cosmetic_value` VARCHAR(80) NOT NULL,
  `unlocked_by` VARCHAR(160) NOT NULL DEFAULT 'system',
  `unlocked_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_armasvip_cosmetic` (`grant_id`, `cosmetic_type`, `cosmetic_value`),
  KEY `idx_armasvip_cosmetic_grant` (`grant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `armasvip_skin_state` (
  `grant_id` BIGINT UNSIGNED NOT NULL,
  `skin_id` VARCHAR(80) NOT NULL DEFAULT 'default',
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`grant_id`),
  KEY `idx_armasvip_skin_id` (`skin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
