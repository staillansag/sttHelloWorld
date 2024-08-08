CREATE TABLE `Messages` (
  `id` char(36) NOT NULL,
  `content` text NOT NULL,
  `issuer` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL,
  PRIMARY KEY (`id`)
)