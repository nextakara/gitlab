CREATE USER 'git'@'%' IDENTIFIED BY 'git';
SET storage_engine=INNODB;
CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlabhq_production`.* TO 'git'@'%';
FLUSH PRIVILEGES;

