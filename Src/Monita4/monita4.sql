-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema monita4
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema monita4
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `monita4` DEFAULT CHARACTER SET latin1 ;
USE `monita4` ;

-- -----------------------------------------------------
-- Table `monita4`.`3rd_server`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`3rd_server` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(50) NULL DEFAULT NULL,
  `gw` VARCHAR(100) NULL DEFAULT NULL,
  `access_id` VARCHAR(100) NULL DEFAULT NULL,
  `password` VARCHAR(100) NULL DEFAULT NULL,
  `conf` VARCHAR(512) NULL DEFAULT NULL,
  `last_update` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 12
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`address` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `alamat` VARCHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 126
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`aset_cat_ref`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`aset_cat_ref` (
  `id` INT(11) NOT NULL,
  `nama_ref` VARCHAR(45) NULL DEFAULT NULL,
  `kode_ref` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`media`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`media` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `file_name` VARCHAR(128) NULL DEFAULT NULL,
  `path` VARCHAR(256) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 36
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`aset_cat`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`aset_cat` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL DEFAULT NULL,
  `media_id` INT(11) NULL DEFAULT NULL,
  `aset_cat_ref_id` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_aset_cat_media1_idx` (`media_id` ASC),
  INDEX `fk_aset_cat_aset_cat_ref1_idx` (`aset_cat_ref_id` ASC),
  CONSTRAINT `fk_aset_cat_aset_cat_ref1`
    FOREIGN KEY (`aset_cat_ref_id`)
    REFERENCES `monita4`.`aset_cat_ref` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_aset_cat_media1`
    FOREIGN KEY (`media_id`)
    REFERENCES `monita4`.`media` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 33
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`user_company`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`user_company` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL DEFAULT NULL,
  `phone` VARCHAR(45) NULL DEFAULT NULL,
  `email` VARCHAR(45) NULL DEFAULT NULL,
  `ket` VARCHAR(45) NULL DEFAULT NULL,
  `address_id` INT(11) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_user_company_address1_idx` (`address_id` ASC),
  CONSTRAINT `fk_user_company_address1`
    FOREIGN KEY (`address_id`)
    REFERENCES `monita4`.`address` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 167
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`aset`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`aset` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `aset_nama` VARCHAR(45) NULL DEFAULT NULL,
  `parent_id` INT(11) NULL DEFAULT NULL,
  `leaf` TINYINT(4) NULL DEFAULT '0',
  `expanded` TINYINT(4) NULL DEFAULT '1',
  `aset_cat_id` INT(11) NULL DEFAULT NULL,
  `user_company_id` INT(11) NULL DEFAULT NULL,
  `flag_perusahaan` VARCHAR(45) NULL DEFAULT NULL,
  `last_update` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_aset_aset_idx` (`parent_id` ASC),
  INDEX `fk_aset_aset_cat1_idx` (`aset_cat_id` ASC),
  INDEX `fk_aset_user_company1_idx` (`user_company_id` ASC),
  CONSTRAINT `fk_aset_aset`
    FOREIGN KEY (`parent_id`)
    REFERENCES `monita4`.`aset` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_aset_aset_cat1`
    FOREIGN KEY (`aset_cat_id`)
    REFERENCES `monita4`.`aset_cat` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_aset_user_company1`
    FOREIGN KEY (`user_company_id`)
    REFERENCES `monita4`.`user_company` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 361
DEFAULT CHARACTER SET = utf8
COMMENT = 'Aset sampai Group Titik Ukur';


-- -----------------------------------------------------
-- Table `monita4`.`data`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`data` (
  `titik_ukur_id` INT(11) NOT NULL DEFAULT '0',
  `value` FLOAT NULL DEFAULT NULL,
  `epochtime` INT(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`epochtime`, `titik_ukur_id`),
  INDEX `fk_data_titik_ukur1_idx` (`titik_ukur_id` ASC),
  INDEX `index3` (`epochtime` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`data_hari_test`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`data_hari_test` (
  `id_titik_ukur` INT(11) NULL DEFAULT NULL,
  `value` DOUBLE NULL DEFAULT NULL,
  `id_trip` INT(11) NULL DEFAULT NULL,
  `epochtime` INT(11) NULL DEFAULT NULL,
  `data_time` TEXT NULL DEFAULT NULL,
  `flag_data` INT(11) NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `monita4`.`data_jaman_deprecated`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`data_jaman_deprecated` (
  `id_titik_ukur` INT(11) NOT NULL,
  `data_tunggal` FLOAT NULL DEFAULT NULL,
  `year` SMALLINT(6) NOT NULL,
  `month` TINYINT(4) NOT NULL,
  `date` TINYINT(4) NOT NULL,
  `hour` TINYINT(4) NOT NULL,
  `minute` TINYINT(4) NOT NULL,
  `second` TINYINT(4) NOT NULL,
  `waktu` BIGINT(20) NOT NULL,
  `titik_ukur_id` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id_titik_ukur`, `waktu`),
  INDEX `datetime` (`year` ASC, `month` ASC, `date` ASC, `hour` ASC, `minute` ASC, `second` ASC),
  INDEX `fk_data_jaman_titik_ukur1_idx` (`titik_ukur_id` ASC))
ENGINE = MEMORY
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`komunikasi_field`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`komunikasi_field` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `field` VARCHAR(145) NULL DEFAULT NULL,
  `mandatory` TINYINT(1) NULL DEFAULT NULL,
  `komunikasi_type_id` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC),
  INDEX `fk_komunikasi_field_komunikasi_type_idx` (`komunikasi_type_id` ASC))
ENGINE = InnoDB
AUTO_INCREMENT = 75
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`modul_info`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`modul_info` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `sn` VARCHAR(50) NULL DEFAULT NULL,
  `nama` VARCHAR(50) NULL DEFAULT NULL,
  `aset_id` INT(11) NULL DEFAULT NULL,
  `date_beli` DATE NULL DEFAULT NULL,
  `ket` VARCHAR(512) NULL DEFAULT NULL,
  `last_update` INT(10) UNSIGNED NULL DEFAULT NULL,
  `status` TINYINT(4) NULL DEFAULT NULL,
  `parent_id` INT(11) NOT NULL,
  `latitude` FLOAT NULL DEFAULT NULL,
  `longitude` FLOAT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_komunikasi_modul_aset1_idx` (`aset_id` ASC),
  INDEX `fk_modul_info_modul_info1_idx` (`parent_id` ASC),
  CONSTRAINT `fk_komunikasi_modul_aset1`
    FOREIGN KEY (`aset_id`)
    REFERENCES `monita4`.`aset` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 118
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`komunikasi_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`komunikasi_type` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NOT NULL,
  `ket` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 39
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`komunikasi_modul_detail`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`komunikasi_modul_detail` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `operator` VARCHAR(45) NULL DEFAULT NULL,
  `device_name` VARCHAR(45) NULL DEFAULT NULL,
  `status` TINYINT(1) NULL DEFAULT '0',
  `type` VARCHAR(45) NULL DEFAULT NULL,
  `number` VARCHAR(45) NULL DEFAULT NULL,
  `apn` VARCHAR(45) NULL DEFAULT NULL,
  `username` VARCHAR(45) NULL DEFAULT NULL,
  `password` VARCHAR(45) NULL DEFAULT NULL,
  `3rd_server_id` INT(11) NOT NULL,
  `modul_info_id` INT(11) NOT NULL,
  `komunikasi_type_id` INT(11) NOT NULL,
  `ip` VARCHAR(45) NULL DEFAULT NULL,
  `gateway` VARCHAR(145) NULL DEFAULT NULL,
  `dns` VARCHAR(45) NULL DEFAULT NULL,
  `protocol_type_id` VARCHAR(45) NOT NULL,
  `protocol_type_available` VARCHAR(45) NULL DEFAULT NULL,
  `address` TEXT NULL DEFAULT NULL,
  `slave_id` TEXT NULL DEFAULT NULL,
  `tempat_lahir` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_komunikasi_modul_detail_modul_type1_idx` (`komunikasi_type_id` ASC),
  INDEX `fk_komunikasi_modul_detail_modul_info1_idx` (`modul_info_id` ASC),
  CONSTRAINT `fk_komunikasi_modul_detail_modul_info1`
    FOREIGN KEY (`modul_info_id`)
    REFERENCES `monita4`.`modul_info` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_komunikasi_modul_detail_modul_type1`
    FOREIGN KEY (`komunikasi_type_id`)
    REFERENCES `monita4`.`komunikasi_type` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 66
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`modul_log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`modul_log` (
  `modul_info_id` INT(11) NOT NULL,
  `start_komunikasi` TIMESTAMP NULL DEFAULT NULL,
  `last_komunikasi` TIMESTAMP NULL DEFAULT NULL,
  `jml_masuk` INT(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`modul_info_id`, `jml_masuk`),
  INDEX `fk_log_modul_komunikasi_modul1_idx` (`modul_info_id` ASC),
  CONSTRAINT `fk_modul_log_modul_info`
    FOREIGN KEY (`modul_info_id`)
    REFERENCES `monita4`.`modul_info` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`parsing_ref`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`parsing_ref` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `modul_id` INT(11) NOT NULL,
  `titik_ukur_id` INT(11) NOT NULL,
  `urutan` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_parsing_ref_aset1_idx` (`modul_id` ASC),
  INDEX `fk_parsing_ref_titik_ukur1_idx` (`titik_ukur_id` ASC),
  CONSTRAINT `fk_parsing_ref_deprecated_1`
    FOREIGN KEY (`modul_id`)
    REFERENCES `monita4`.`modul_info` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 25
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `monita4`.`protocol_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`protocol_type` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL DEFAULT NULL,
  `ket` VARCHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 9
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`titik_ukur_tipe`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`titik_ukur_tipe` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL DEFAULT NULL,
  `satuan` VARCHAR(45) NULL DEFAULT NULL,
  `media_id` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_titik_ukur_tipe_media1_idx` (`media_id` ASC),
  CONSTRAINT `fk_titik_ukur_tipe_media1`
    FOREIGN KEY (`media_id`)
    REFERENCES `monita4`.`media` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 106
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`titik_ukur`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`titik_ukur` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL DEFAULT NULL,
  `titik_ukur_tipe_id` INT(11) NULL DEFAULT NULL,
  `last_update` INT(11) NULL DEFAULT NULL,
  `aset_id` INT(11) NULL DEFAULT NULL,
  `id_tu` INT(11) NULL DEFAULT NULL,
  `range_min` INT(11) NULL DEFAULT NULL,
  `range_max` INT(11) NULL DEFAULT NULL,
  `alarm_min_min` INT(11) NULL DEFAULT NULL,
  `alarm_min` INT(11) NULL DEFAULT NULL,
  `alarm_max` INT(11) NULL DEFAULT NULL,
  `alarm_max_max` INT(11) NULL DEFAULT NULL,
  `kalib_a` INT(11) NULL DEFAULT '1',
  `kalib_b` INT(11) NULL DEFAULT '0',
  `modul_info_id` INT(11) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_titik_ukur_titik_ukur_tipe1_idx` (`titik_ukur_tipe_id` ASC),
  INDEX `fk_titik_ukur_aset1_idx` (`aset_id` ASC),
  INDEX `fk_titik_ukur_1_idx` (`modul_info_id` ASC),
  CONSTRAINT `fk_titik_ukur_aset1`
    FOREIGN KEY (`aset_id`)
    REFERENCES `monita4`.`aset` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_titik_ukur_titik_ukur_tipe1`
    FOREIGN KEY (`titik_ukur_tipe_id`)
    REFERENCES `monita4`.`titik_ukur_tipe` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 112
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`titik_ukur_tpl`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`titik_ukur_tpl` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`titik_ukur_tpl_ref`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`titik_ukur_tpl_ref` (
  `titik_ukur_tpl_id` INT(11) NULL DEFAULT NULL,
  `titik_ukur_tipe_id` INT(11) NULL DEFAULT NULL,
  INDEX `fk_titik_ukur_temp_has_titik_ukur_tipe_titik_ukur_tipe1_idx` (`titik_ukur_tipe_id` ASC),
  INDEX `fk_titik_ukur_temp_has_titik_ukur_tipe_titik_ukur_temp1_idx` (`titik_ukur_tpl_id` ASC),
  CONSTRAINT `fk_titik_ukur_temp_has_titik_ukur_tipe_titik_ukur_temp1`
    FOREIGN KEY (`titik_ukur_tpl_id`)
    REFERENCES `monita4`.`titik_ukur_tpl` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_titik_ukur_temp_has_titik_ukur_tipe_titik_ukur_tipe1`
    FOREIGN KEY (`titik_ukur_tipe_id`)
    REFERENCES `monita4`.`titik_ukur_tipe` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`user_login`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`user_login` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `userid` VARCHAR(45) NULL DEFAULT NULL,
  `password` VARCHAR(75) NULL DEFAULT NULL,
  `last_login` INT(11) NULL DEFAULT NULL,
  `ip_login` VARCHAR(20) NULL DEFAULT NULL,
  `api_key` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 62
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`user_role`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`user_role` (
  `id` INT(11) NOT NULL,
  `nama` VARCHAR(20) NULL DEFAULT NULL COMMENT '\n',
  `config` VARCHAR(128) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`user_detail`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`user_detail` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL DEFAULT NULL,
  `email` VARCHAR(45) NULL DEFAULT NULL,
  `phone` VARCHAR(45) NULL DEFAULT NULL,
  `company_id` VARCHAR(256) NOT NULL,
  `user_login_id` INT(11) NOT NULL,
  `last_update` INT(11) NULL DEFAULT NULL,
  `user_role_id` INT(11) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_user_detail_user_role1_idx` (`user_role_id` ASC),
  INDEX `fk_user_detail_user_login1_idx` (`user_login_id` ASC),
  CONSTRAINT `fk_user_detail_user_login1`
    FOREIGN KEY (`user_login_id`)
    REFERENCES `monita4`.`user_login` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_detail_user_role1`
    FOREIGN KEY (`user_role_id`)
    REFERENCES `monita4`.`user_role` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 60
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`visual_group`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`visual_group` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL DEFAULT NULL,
  `aset_id` INT(11) NOT NULL,
  `file_url` VARCHAR(128) NULL DEFAULT NULL,
  `last_update` VARCHAR(45) NULL DEFAULT NULL,
  `visual_menu_id` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_visual_group_aset1_idx` (`aset_id` ASC),
  CONSTRAINT `fk_visual_group_aset1`
    FOREIGN KEY (`aset_id`)
    REFERENCES `monita4`.`aset` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 141
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`visual_group_has_titik_ukur`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`visual_group_has_titik_ukur` (
  `titik_ukur_id` INT(11) NOT NULL,
  `visual_group_id` INT(11) NOT NULL,
  PRIMARY KEY (`titik_ukur_id`, `visual_group_id`),
  INDEX `fk_titik_ukur_has_visual_group_visual_group1_idx` (`visual_group_id` ASC),
  INDEX `fk_titik_ukur_has_visual_group_titik_ukur1_idx` (`titik_ukur_id` ASC),
  CONSTRAINT `fk_titik_ukur_has_visual_group_titik_ukur1`
    FOREIGN KEY (`titik_ukur_id`)
    REFERENCES `monita4`.`titik_ukur` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_titik_ukur_has_visual_group_visual_group1`
    FOREIGN KEY (`visual_group_id`)
    REFERENCES `monita4`.`visual_group` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `monita4`.`visual_menu`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `monita4`.`visual_menu` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(45) NULL DEFAULT NULL,
  `link` VARCHAR(128) NULL DEFAULT NULL,
  `aset_id` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 18
DEFAULT CHARACTER SET = utf8;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `monita4`.`aset_cat_ref`
-- -----------------------------------------------------
START TRANSACTION;
USE `monita4`;
INSERT INTO `monita4`.`aset_cat_ref` (`id`, `nama_ref`, `kode_ref`) VALUES (1, 'Company', 'c');
INSERT INTO `monita4`.`aset_cat_ref` (`id`, `nama_ref`, `kode_ref`) VALUES (2, 'Equipment Unit', 'e');
INSERT INTO `monita4`.`aset_cat_ref` (`id`, `nama_ref`, `kode_ref`) VALUES (3, 'Equipment Group', 'eg');
INSERT INTO `monita4`.`aset_cat_ref` (`id`, `nama_ref`, `kode_ref`) VALUES (4, 'Measurement Point', 'tu');

COMMIT;


-- -----------------------------------------------------
-- Data for table `monita4`.`media`
-- -----------------------------------------------------
START TRANSACTION;
USE `monita4`;
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (1, 'factory.png', 'resources/asset/image/factory.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (2, 'ocean.png', 'resources/asset/image/ocean.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (3, 'engine.png', 'resources/asset/image/engine.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (4, 'contoh_undangan_reuni.jpg', 'resources/asset/image/contoh_undangan_reuni.jpg');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (5, 'g9569.png', 'resources/asset/image/g9569.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (6, 'g10304.png', 'resources/asset/image/g10304.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (7, 'programmer.jpg', 'resources/asset/image/programmer.jpg');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (8, 'g9815.png', 'resources/asset/image/g9815.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (9, 'map.png', 'resources/asset/image/map.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (10, 'speed.png', 'resources/asset/image/speed.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (11, 'compass.png', 'resources/asset/image/compass.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (12, 'gear.png', 'resources/asset/image/gear.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (13, 'propeler.png', 'resources/asset/image/propeler.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (14, 'fuel.png', 'resources/asset/image/fuel.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (24, 'editFile.png', 'resources/asset/image/editFile.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (25, 'IMG_20160807_084546.jpg', 'resources/asset/image/IMG_20160807_084546.jpg');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (27, 'editFile1.png', 'resources/asset/image/editFile1.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (28, 'editFile2.png', 'resources/asset/image/editFile2.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (29, '13735825_1223859770980031_6268331579741792076_o.jpg', 'resources/asset/image/13735825_1223859770980031_6268331579741792076_o.jpg');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (30, 'buttonwindow.png', 'resources/asset/image/buttonwindow.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (31, 'maxresdefault.jpg', 'resources/asset/image/maxresdefault.jpg');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (32, 'Uploading.jpg', 'resources/asset/image/Uploading.jpg');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (33, 'error_404__reallife_not_found_by_reactdesign-d363abm.png', 'resources/asset/image/error_404__reallife_not_found_by_reactdesign-d363abm.png');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (34, 'typo.jpg', 'resources/asset/image/typo.jpg');
INSERT INTO `monita4`.`media` (`id`, `file_name`, `path`) VALUES (35, '1920545_727109744028011_2566188841249108436_n.jpg', 'resources/asset/image/1920545_727109744028011_2566188841249108436_n.jpg');

COMMIT;


-- -----------------------------------------------------
-- Data for table `monita4`.`aset_cat`
-- -----------------------------------------------------
START TRANSACTION;
USE `monita4`;
INSERT INTO `monita4`.`aset_cat` (`id`, `nama`, `media_id`, `aset_cat_ref_id`) VALUES (1, 'Pusat', 1, 1);
INSERT INTO `monita4`.`aset_cat` (`id`, `nama`, `media_id`, `aset_cat_ref_id`) VALUES (2, 'Cabang', 1, 1);
INSERT INTO `monita4`.`aset_cat` (`id`, `nama`, `media_id`, `aset_cat_ref_id`) VALUES (3, 'Vessel', 2, 2);

COMMIT;


-- -----------------------------------------------------
-- Data for table `monita4`.`user_role`
-- -----------------------------------------------------
START TRANSACTION;
USE `monita4`;
INSERT INTO `monita4`.`user_role` (`id`, `nama`, `config`) VALUES (1, 'Admin', '{\"lex\":\"100\",\"tab1\":true,\"tab2\":true,\"tab3\":true}');
INSERT INTO `monita4`.`user_role` (`id`, `nama`, `config`) VALUES (2, 'Operator', '{lex:\"-1\",\"tab1\":false,\"tab2\":true,\"tab3\":true}');
INSERT INTO `monita4`.`user_role` (`id`, `nama`, `config`) VALUES (3, 'Manager', '{lex:\"10\",\"tab1\":false,\"tab2\":true,\"tab3\":true}');
INSERT INTO `monita4`.`user_role` (`id`, `nama`, `config`) VALUES (4, 'Dispatcher', '{\"um\":1,\"am\":1,\"cm\":1}');

COMMIT;
