-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema marine_2_dev
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `marine_2_dev` ;

-- -----------------------------------------------------
-- Schema marine_2_dev
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `marine_2_dev` DEFAULT CHARACTER SET utf8 ;
USE `marine_2_dev` ;

-- -----------------------------------------------------
-- Table `marine_2_dev`.`media`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`media` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`media` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `file_name` VARCHAR(45) NULL,
  `path` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `marine_2_dev`.`aset_cat_ref`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`aset_cat_ref` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`aset_cat_ref` (
  `id` INT NOT NULL,
  `nama_ref` VARCHAR(45) NULL,
  `kode_ref` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `marine_2_dev`.`aset_cat`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`aset_cat` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`aset_cat` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL,
  `media_id` INT NULL,
  `aset_cat_ref_id` INT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_aset_cat_media1`
    FOREIGN KEY (`media_id`)
    REFERENCES `marine_2_dev`.`media` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_aset_cat_aset_cat_ref1`
    FOREIGN KEY (`aset_cat_ref_id`)
    REFERENCES `marine_2_dev`.`aset_cat_ref` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_aset_cat_media1_idx` ON `marine_2_dev`.`aset_cat` (`media_id` ASC);

CREATE INDEX `fk_aset_cat_aset_cat_ref1_idx` ON `marine_2_dev`.`aset_cat` (`aset_cat_ref_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`address`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`address` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`address` (
  `id` INT NOT NULL,
  `alamat` VARCHAR(100) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `marine_2_dev`.`user_company`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`user_company` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`user_company` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL,
  `phone` VARCHAR(45) NULL,
  `email` VARCHAR(45) NULL,
  `ket` VARCHAR(45) NULL,
  `address_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_user_company_address1`
    FOREIGN KEY (`address_id`)
    REFERENCES `marine_2_dev`.`address` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_user_company_address1_idx` ON `marine_2_dev`.`user_company` (`address_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`aset`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`aset` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`aset` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `aset_nama` VARCHAR(45) NULL,
  `parent_id` INT NULL,
  `leaf` TINYINT NULL DEFAULT 0,
  `expanded` TINYINT NULL DEFAULT 1,
  `aset_cat_id` INT NULL,
  `user_company_id` INT NULL,
  `flag_perusahaan` TINYINT NULL,
  `last_update` VARCHAR(45) NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_aset_aset`
    FOREIGN KEY (`parent_id`)
    REFERENCES `marine_2_dev`.`aset` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_aset_aset_cat1`
    FOREIGN KEY (`aset_cat_id`)
    REFERENCES `marine_2_dev`.`aset_cat` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_aset_user_company1`
    FOREIGN KEY (`user_company_id`)
    REFERENCES `marine_2_dev`.`user_company` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
COMMENT = 'Aset sampai Group Titik Ukur';

CREATE INDEX `fk_aset_aset_idx` ON `marine_2_dev`.`aset` (`parent_id` ASC);

CREATE INDEX `fk_aset_aset_cat1_idx` ON `marine_2_dev`.`aset` (`aset_cat_id` ASC);

CREATE INDEX `fk_aset_user_company1_idx` ON `marine_2_dev`.`aset` (`user_company_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`titik_ukur_tipe`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`titik_ukur_tipe` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`titik_ukur_tipe` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL,
  `satuan` VARCHAR(45) NULL,
  `media_id` INT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_titik_ukur_tipe_media1`
    FOREIGN KEY (`media_id`)
    REFERENCES `marine_2_dev`.`media` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_titik_ukur_tipe_media1_idx` ON `marine_2_dev`.`titik_ukur_tipe` (`media_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`titik_ukur`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`titik_ukur` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`titik_ukur` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL,
  `titik_ukur_tipe_id` INT NULL,
  `last_update` INT NULL,
  `aset_id` INT NULL,
  `id_tu` INT NULL,
  `range_min` INT NULL,
  `range_max` INT NULL,
  `alarm_min_min` INT NULL,
  `alarm_min` INT NULL,
  `alarm_max` INT NULL,
  `alarm_max_max` INT NULL,
  `kalib_a` INT NULL DEFAULT 1,
  `kalib_b` INT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_titik_ukur_titik_ukur_tipe1`
    FOREIGN KEY (`titik_ukur_tipe_id`)
    REFERENCES `marine_2_dev`.`titik_ukur_tipe` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_titik_ukur_aset1`
    FOREIGN KEY (`aset_id`)
    REFERENCES `marine_2_dev`.`aset` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_titik_ukur_titik_ukur_tipe1_idx` ON `marine_2_dev`.`titik_ukur` (`titik_ukur_tipe_id` ASC);

CREATE INDEX `fk_titik_ukur_aset1_idx` ON `marine_2_dev`.`titik_ukur` (`aset_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`user_login`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`user_login` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`user_login` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `userid` VARCHAR(45) NULL,
  `password` VARCHAR(75) NULL,
  `last_login` INT NULL,
  `ip_login` VARCHAR(20) NULL,
  `api_key` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `marine_2_dev`.`user_role`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`user_role` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`user_role` (
  `id` INT NOT NULL,
  `nama` VARCHAR(20) NULL COMMENT '\n',
  `config` VARCHAR(128) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `marine_2_dev`.`user_detail`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`user_detail` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`user_detail` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL,
  `email` VARCHAR(45) NULL,
  `phone` VARCHAR(45) NULL,
  `last_update` INT NULL,
  `user_role_id` INT NOT NULL,
  `user_login_id` INT NOT NULL,
  `user_company_id` VARCHAR(128) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_user_detail_user_role1`
    FOREIGN KEY (`user_role_id`)
    REFERENCES `marine_2_dev`.`user_role` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_detail_user_login1`
    FOREIGN KEY (`user_login_id`)
    REFERENCES `marine_2_dev`.`user_login` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_user_detail_user_role1_idx` ON `marine_2_dev`.`user_detail` (`user_role_id` ASC);

CREATE INDEX `fk_user_detail_user_login1_idx` ON `marine_2_dev`.`user_detail` (`user_login_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`3rd_server`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`3rd_server` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`3rd_server` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(50) NULL,
  `gw` VARCHAR(100) NULL,
  `access_id` VARCHAR(100) NULL,
  `password` VARCHAR(100) NULL,
  `conf` VARCHAR(512) NULL,
  `last_update` INT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `marine_2_dev`.`titik_ukur_tpl`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`titik_ukur_tpl` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`titik_ukur_tpl` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `marine_2_dev`.`titik_ukur_tpl_ref`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`titik_ukur_tpl_ref` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`titik_ukur_tpl_ref` (
  `titik_ukur_tpl_id` INT NULL,
  `titik_ukur_tipe_id` INT NULL,
  CONSTRAINT `fk_titik_ukur_temp_has_titik_ukur_tipe_titik_ukur_temp1`
    FOREIGN KEY (`titik_ukur_tpl_id`)
    REFERENCES `marine_2_dev`.`titik_ukur_tpl` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_titik_ukur_temp_has_titik_ukur_tipe_titik_ukur_tipe1`
    FOREIGN KEY (`titik_ukur_tipe_id`)
    REFERENCES `marine_2_dev`.`titik_ukur_tipe` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_titik_ukur_temp_has_titik_ukur_tipe_titik_ukur_tipe1_idx` ON `marine_2_dev`.`titik_ukur_tpl_ref` (`titik_ukur_tipe_id` ASC);

CREATE INDEX `fk_titik_ukur_temp_has_titik_ukur_tipe_titik_ukur_temp1_idx` ON `marine_2_dev`.`titik_ukur_tpl_ref` (`titik_ukur_tpl_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`data`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`data` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`data` (
  `titik_ukur_id` INT NULL,
  `value` FLOAT NULL,
  `data_time` VARCHAR(45) NOT NULL,
  `epochtime` VARCHAR(45) NULL,
  PRIMARY KEY (`data_time`),
  CONSTRAINT `fk_data_titik_ukur1`
    FOREIGN KEY (`titik_ukur_id`)
    REFERENCES `marine_2_dev`.`titik_ukur` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_data_titik_ukur1_idx` ON `marine_2_dev`.`data` (`titik_ukur_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`data_jaman`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`data_jaman` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`data_jaman` (
  `id_titik_ukur` INT NOT NULL,
  `data_tunggal` FLOAT NULL,
  `year` SMALLINT NOT NULL,
  `month` TINYINT NOT NULL,
  `date` TINYINT NOT NULL,
  `hour` TINYINT NOT NULL,
  `minute` TINYINT NOT NULL,
  `second` TINYINT NOT NULL,
  `waktu` BIGINT NOT NULL,
  `titik_ukur_id` INT NULL,
  PRIMARY KEY (`id_titik_ukur`, `waktu`))
ENGINE = MEMORY
PACK_KEYS = DEFAULT;

CREATE INDEX `datetime` ON `marine_2_dev`.`data_jaman` (`year` ASC, `month` ASC, `date` ASC, `hour` ASC, `minute` ASC, `second` ASC);

CREATE INDEX `fk_data_jaman_titik_ukur1_idx` ON `marine_2_dev`.`data_jaman` (`titik_ukur_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`modul_info`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`modul_info` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`modul_info` (
  `id` INT NOT NULL,
  `sn` VARCHAR(50) NULL,
  `nama` VARCHAR(50) NULL,
  `aset_id` INT NULL,
  `date_beli` DATE NULL,
  `ket` VARCHAR(512) NULL,
  `last_update` INT UNSIGNED NULL,
  `status` TINYINT NULL,
  `parent_id` INT NOT NULL,
  `latitude` FLOAT NULL,
  `longitude` FLOAT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_komunikasi_modul_aset1`
    FOREIGN KEY (`aset_id`)
    REFERENCES `marine_2_dev`.`aset` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_modul_info_modul_info1`
    FOREIGN KEY (`parent_id`)
    REFERENCES `marine_2_dev`.`modul_info` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_komunikasi_modul_aset1_idx` ON `marine_2_dev`.`modul_info` (`aset_id` ASC);

CREATE INDEX `fk_modul_info_modul_info1_idx` ON `marine_2_dev`.`modul_info` (`parent_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`protocol_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`protocol_type` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`protocol_type` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL,
  `ket` VARCHAR(100) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `marine_2_dev`.`modul_log`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`modul_log` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`modul_log` (
  `modul_info_id` INT NOT NULL,
  `start_komunikasi` TIMESTAMP NULL,
  `last_komunikasi` TIMESTAMP NULL,
  `protocol_type_id` INT NOT NULL,
  PRIMARY KEY (`modul_info_id`, `protocol_type_id`),
  CONSTRAINT `fk_log_modul_komunikasi_modul1`
    FOREIGN KEY (`modul_info_id`)
    REFERENCES `marine_2_dev`.`modul_info` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_log_modul_protocol_type1`
    FOREIGN KEY (`protocol_type_id`)
    REFERENCES `marine_2_dev`.`protocol_type` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_log_modul_komunikasi_modul1_idx` ON `marine_2_dev`.`modul_log` (`modul_info_id` ASC);

CREATE INDEX `fk_log_modul_protocol_type1_idx` ON `marine_2_dev`.`modul_log` (`protocol_type_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`komunikasi_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`komunikasi_type` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`komunikasi_type` (
  `id` INT NOT NULL,
  `nama` VARCHAR(45) NOT NULL,
  `ket` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `marine_2_dev`.`komunikasi_modul_detail`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`komunikasi_modul_detail` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`komunikasi_modul_detail` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `operator` VARCHAR(45) NOT NULL,
  `device_name` VARCHAR(45) NULL,
  `status` TINYINT(1) NULL DEFAULT 0,
  `type` VARCHAR(45) NOT NULL,
  `number` VARCHAR(45) NOT NULL,
  `apn` VARCHAR(45) NULL,
  `username` VARCHAR(45) NULL,
  `password` VARCHAR(45) NULL,
  `3rd_server_id` INT NOT NULL,
  `modul_info_id` INT NOT NULL,
  `komunikasi_type_id` INT NOT NULL,
  `ip` VARCHAR(45) NULL,
  `gateway` VARCHAR(145) NULL,
  `dns` VARCHAR(45) NULL,
  `protocol_type_id` VARCHAR(45) NOT NULL,
  `protocol_type_available` VARCHAR(45) NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_komunikasi_modul_detail_3rd_server1`
    FOREIGN KEY (`3rd_server_id`)
    REFERENCES `marine_2_dev`.`3rd_server` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_komunikasi_modul_detail_modul_info1`
    FOREIGN KEY (`modul_info_id`)
    REFERENCES `marine_2_dev`.`modul_info` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_komunikasi_modul_detail_modul_type1`
    FOREIGN KEY (`komunikasi_type_id`)
    REFERENCES `marine_2_dev`.`komunikasi_type` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_komunikasi_modul_detail_3rd_server1_idx` ON `marine_2_dev`.`komunikasi_modul_detail` (`3rd_server_id` ASC);

CREATE INDEX `fk_komunikasi_modul_detail_modul_info1_idx` ON `marine_2_dev`.`komunikasi_modul_detail` (`modul_info_id` ASC);

CREATE INDEX `fk_komunikasi_modul_detail_modul_type1_idx` ON `marine_2_dev`.`komunikasi_modul_detail` (`komunikasi_type_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`komunikasi_field`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`komunikasi_field` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`komunikasi_field` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `field` VARCHAR(45) NULL,
  `mandatory` TINYINT(1) NULL,
  `modul_type_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_komunikasi_field_modul_type1`
    FOREIGN KEY (`modul_type_id`)
    REFERENCES `marine_2_dev`.`komunikasi_type` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_komunikasi_field_modul_type1_idx` ON `marine_2_dev`.`komunikasi_field` (`modul_type_id` ASC);

CREATE UNIQUE INDEX `id_UNIQUE` ON `marine_2_dev`.`komunikasi_field` (`id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`visual_group`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`visual_group` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`visual_group` (
  `id` INT NOT NULL,
  `nama` VARCHAR(45) NULL,
  `aset_id` INT NOT NULL,
  `file_url` VARCHAR(128) NULL,
  `last_update` VARCHAR(45) NULL,
  `visual_group_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_visual_group_aset1`
    FOREIGN KEY (`aset_id`)
    REFERENCES `marine_2_dev`.`aset` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_visual_group_visual_group1`
    FOREIGN KEY (`visual_group_id`)
    REFERENCES `marine_2_dev`.`visual_group` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_visual_group_aset1_idx` ON `marine_2_dev`.`visual_group` (`aset_id` ASC);

CREATE INDEX `fk_visual_group_visual_group1_idx` ON `marine_2_dev`.`visual_group` (`visual_group_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`titik_ukur_has_visual_group`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`titik_ukur_has_visual_group` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`titik_ukur_has_visual_group` (
  `titik_ukur_id` INT NOT NULL,
  `visual_group_id` INT NOT NULL,
  PRIMARY KEY (`titik_ukur_id`, `visual_group_id`),
  CONSTRAINT `fk_titik_ukur_has_visual_group_titik_ukur1`
    FOREIGN KEY (`titik_ukur_id`)
    REFERENCES `marine_2_dev`.`titik_ukur` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_titik_ukur_has_visual_group_visual_group1`
    FOREIGN KEY (`visual_group_id`)
    REFERENCES `marine_2_dev`.`visual_group` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_titik_ukur_has_visual_group_visual_group1_idx` ON `marine_2_dev`.`titik_ukur_has_visual_group` (`visual_group_id` ASC);

CREATE INDEX `fk_titik_ukur_has_visual_group_titik_ukur1_idx` ON `marine_2_dev`.`titik_ukur_has_visual_group` (`titik_ukur_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`visual_menu`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`visual_menu` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`visual_menu` (
  `id` INT NOT NULL,
  `parent_id` INT NOT NULL,
  `nama` VARCHAR(45) NULL,
  `link` VARCHAR(45) NULL,
  `visual_group_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_visual_menu_visual_menu1`
    FOREIGN KEY (`parent_id`)
    REFERENCES `marine_2_dev`.`visual_menu` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_visual_menu_visual_group1`
    FOREIGN KEY (`visual_group_id`)
    REFERENCES `marine_2_dev`.`visual_group` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_visual_menu_visual_menu1_idx` ON `marine_2_dev`.`visual_menu` (`parent_id` ASC);

CREATE INDEX `fk_visual_menu_visual_group1_idx` ON `marine_2_dev`.`visual_menu` (`visual_group_id` ASC);


-- -----------------------------------------------------
-- Table `marine_2_dev`.`parsing_ref`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `marine_2_dev`.`parsing_ref` ;

CREATE TABLE IF NOT EXISTS `marine_2_dev`.`parsing_ref` (
  `id` INT NOT NULL,
  `aset_id` INT NOT NULL,
  `titik_ukur_id` INT NOT NULL,
  `urutan` INT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_parsing_ref_aset1`
    FOREIGN KEY (`aset_id`)
    REFERENCES `marine_2_dev`.`aset` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_parsing_ref_titik_ukur1`
    FOREIGN KEY (`titik_ukur_id`)
    REFERENCES `marine_2_dev`.`titik_ukur` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_parsing_ref_aset1_idx` ON `marine_2_dev`.`parsing_ref` (`aset_id` ASC);

CREATE INDEX `fk_parsing_ref_titik_ukur1_idx` ON `marine_2_dev`.`parsing_ref` (`titik_ukur_id` ASC);

USE `marine_2_dev` ;

-- -----------------------------------------------------
-- procedure data_harian
-- -----------------------------------------------------

USE `marine_2_dev`;
DROP procedure IF EXISTS `marine_2_dev`.`data_harian`;

DELIMITER $$
USE `marine_2_dev`$$
CREATE PROCEDURE `data_harian` ()
BEGIN
 select * from ship;
END$$

DELIMITER ;
USE `marine_2_dev`;

DELIMITER $$

USE `marine_2_dev`$$
DROP TRIGGER IF EXISTS `marine_2_dev`.`data_jaman_AINS` $$
USE `marine_2_dev`$$
CREATE TRIGGER `data_jaman_AINS` AFTER INSERT ON `data_jaman` FOR EACH ROW
BEGIN
	call create_data_harian();
end
$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `marine_2_dev`.`media`
-- -----------------------------------------------------
START TRANSACTION;
USE `marine_2_dev`;
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (1, 'factory.png', 'resources/asset/image/factory.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (2, 'ocean.png', 'resources/asset/image/ocean.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (3, 'engine.png', 'resources/asset/image/engine.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (4, 'contoh_undangan_reuni.jpg', 'resources/asset/image/contoh_undangan_reuni.jpg');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (5, 'g9569.png', 'resources/asset/image/g9569.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (6, 'g10304.png', 'resources/asset/image/g10304.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (7, 'programmer.jpg', 'resources/asset/image/programmer.jpg');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (8, 'g9815.png', 'resources/asset/image/g9815.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (9, 'map.png', 'resources/asset/image/map.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (10, 'speed.png', 'resources/asset/image/speed.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (11, 'compass.png', 'resources/asset/image/compass.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (12, 'gear.png', 'resources/asset/image/gear.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (13, 'propeler.png', 'resources/asset/image/propeler.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (14, 'fuel.png', 'resources/asset/image/fuel.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (24, 'editFile.png', 'resources/asset/image/editFile.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (25, 'IMG_20160807_084546.jpg', 'resources/asset/image/IMG_20160807_084546.jpg');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (27, 'editFile1.png', 'resources/asset/image/editFile1.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (28, 'editFile2.png', 'resources/asset/image/editFile2.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (29, '13735825_1223859770980031_6268331579741792076_o.jpg', 'resources/asset/image/13735825_1223859770980031_6268331579741792076_o.jpg');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (30, 'buttonwindow.png', 'resources/asset/image/buttonwindow.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (31, 'maxresdefault.jpg', 'resources/asset/image/maxresdefault.jpg');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (32, 'Uploading.jpg', 'resources/asset/image/Uploading.jpg');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (33, 'error_404__reallife_not_found_by_reactdesign-d363abm.png', 'resources/asset/image/error_404__reallife_not_found_by_reactdesign-d363abm.png');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (34, 'typo.jpg', 'resources/asset/image/typo.jpg');
INSERT INTO `marine_2_dev`.`media` (`id`, `file_name`, `path`) VALUES (35, '1920545_727109744028011_2566188841249108436_n.jpg', 'resources/asset/image/1920545_727109744028011_2566188841249108436_n.jpg');

COMMIT;


-- -----------------------------------------------------
-- Data for table `marine_2_dev`.`aset_cat_ref`
-- -----------------------------------------------------
START TRANSACTION;
USE `marine_2_dev`;
INSERT INTO `marine_2_dev`.`aset_cat_ref` (`id`, `nama_ref`, `kode_ref`) VALUES (1, 'Company', 'c');
INSERT INTO `marine_2_dev`.`aset_cat_ref` (`id`, `nama_ref`, `kode_ref`) VALUES (2, 'Equipment Unit', 'e');
INSERT INTO `marine_2_dev`.`aset_cat_ref` (`id`, `nama_ref`, `kode_ref`) VALUES (3, 'Equipment Group', 'eg');
INSERT INTO `marine_2_dev`.`aset_cat_ref` (`id`, `nama_ref`, `kode_ref`) VALUES (4, 'Measurement Point', 'tu');

COMMIT;


-- -----------------------------------------------------
-- Data for table `marine_2_dev`.`aset_cat`
-- -----------------------------------------------------
START TRANSACTION;
USE `marine_2_dev`;
INSERT INTO `marine_2_dev`.`aset_cat` (`id`, `nama`, `media_id`, `aset_cat_ref_id`) VALUES (1, 'Pusat', 1, 1);
INSERT INTO `marine_2_dev`.`aset_cat` (`id`, `nama`, `media_id`, `aset_cat_ref_id`) VALUES (2, 'Cabang', 1, 1);
INSERT INTO `marine_2_dev`.`aset_cat` (`id`, `nama`, `media_id`, `aset_cat_ref_id`) VALUES (3, 'Vessel', 2, 2);

COMMIT;


-- -----------------------------------------------------
-- Data for table `marine_2_dev`.`user_role`
-- -----------------------------------------------------
START TRANSACTION;
USE `marine_2_dev`;
INSERT INTO `marine_2_dev`.`user_role` (`id`, `nama`, `config`) VALUES (1, 'Admin', '{\"lex\":\"100\",\"tab1\":true,\"tab2\":true,\"tab3\":true}');
INSERT INTO `marine_2_dev`.`user_role` (`id`, `nama`, `config`) VALUES (2, 'Operator', '{lex:\"-1\",\"tab1\":false,\"tab2\":true,\"tab3\":true}');
INSERT INTO `marine_2_dev`.`user_role` (`id`, `nama`, `config`) VALUES (3, 'Manager', '{lex:\"10\",\"tab1\":false,\"tab2\":true,\"tab3\":true}');
INSERT INTO `marine_2_dev`.`user_role` (`id`, `nama`, `config`) VALUES (4, 'Dispatcher', '{\"um\":1,\"am\":1,\"cm\":1}');

COMMIT;


-- -----------------------------------------------------
-- Data for table `marine_2_dev`.`protocol_type`
-- -----------------------------------------------------
START TRANSACTION;
USE `marine_2_dev`;
INSERT INTO `marine_2_dev`.`protocol_type` (`id`, `nama`, `ket`) VALUES (1, 'TCP IP', NULL);
INSERT INTO `marine_2_dev`.`protocol_type` (`id`, `nama`, `ket`) VALUES (2, 'TCP Modbus', NULL);
INSERT INTO `marine_2_dev`.`protocol_type` (`id`, `nama`, `ket`) VALUES (3, 'Modbus RTU', NULL);
INSERT INTO `marine_2_dev`.`protocol_type` (`id`, `nama`, `ket`) VALUES (4, 'SMS', NULL);
INSERT INTO `marine_2_dev`.`protocol_type` (`id`, `nama`, `ket`) VALUES (5, 'HTTP', NULL);
INSERT INTO `marine_2_dev`.`protocol_type` (`id`, `nama`, `ket`) VALUES (6, 'GPRS', NULL);
INSERT INTO `marine_2_dev`.`protocol_type` (`id`, `nama`, `ket`) VALUES (DEFAULT, 'IEC 104', NULL);
INSERT INTO `marine_2_dev`.`protocol_type` (`id`, `nama`, `ket`) VALUES (DEFAULT, 'DNP3', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `marine_2_dev`.`komunikasi_type`
-- -----------------------------------------------------
START TRANSACTION;
USE `marine_2_dev`;
INSERT INTO `marine_2_dev`.`komunikasi_type` (`id`, `nama`, `ket`) VALUES (1, 'GSM', NULL);
INSERT INTO `marine_2_dev`.`komunikasi_type` (`id`, `nama`, `ket`) VALUES (2, 'Satelit Skywave', NULL);
INSERT INTO `marine_2_dev`.`komunikasi_type` (`id`, `nama`, `ket`) VALUES (3, 'LAN', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `marine_2_dev`.`komunikasi_field`
-- -----------------------------------------------------
START TRANSACTION;
USE `marine_2_dev`;
INSERT INTO `marine_2_dev`.`komunikasi_field` (`id`, `field`, `mandatory`, `modul_type_id`) VALUES (DEFAULT, 'operator', NULL, 1);

COMMIT;
