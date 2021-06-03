/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 80015
 Source Host           : localhost:3306
 Source Schema         : onlinejudge_judgecenter

 Target Server Type    : MySQL
 Target Server Version : 80015
 File Encoding         : 65001

 Date: 03/06/2021 09:55:10
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for checkpoint
-- ----------------------------
DROP TABLE IF EXISTS `checkpoint`;
CREATE TABLE `checkpoint`  (
  `checkpoint_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '检查点ID',
  `problem_id` bigint(20) NOT NULL COMMENT '题目ID与内容中心同步',
  `input` varchar(2560) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '标准输入',
  `output` varchar(2560) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '标准输出',
  `is_deleted` tinyint(1) UNSIGNED ZEROFILL NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`checkpoint_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of checkpoint
-- ----------------------------

-- ----------------------------
-- Table structure for compile
-- ----------------------------
DROP TABLE IF EXISTS `compile`;
CREATE TABLE `compile`  (
  `compile_id` int(20) NOT NULL AUTO_INCREMENT COMMENT '编译配置的id',
  `config_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '配置的名称',
  `src_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `exe_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `max_cpu_time` bigint(20) NOT NULL,
  `max_real_time` bigint(20) NOT NULL,
  `max_memory` bigint(30) NOT NULL,
  `compile_command` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '编译命令',
  `env` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '环境变量',
  PRIMARY KEY (`compile_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of compile
-- ----------------------------
INSERT INTO `compile` VALUES (1, 'c_lang_config', 'main.c', 'main', 3000, 5000, 134217728, '/usr/bin/gcc -DONLINE_JUDGE -O2 -w -fmax-errors=3 -std=c99 {src_path} -lm -o {exe_path}', NULL);
INSERT INTO `compile` VALUES (2, 'c_lang_spj_config', 'spj-{spj_version}.c', 'spj-{spj_version}', 3000, 5000, 1073741824, '/usr/bin/gcc -DONLINE_JUDGE -O2 -w -fmax-errors=3 -std=c99 {src_path} -lm -o {exe_path}', NULL);
INSERT INTO `compile` VALUES (3, 'cpp_lang_config', 'main.cpp', 'main', 3000, 5000, 134217728, '/usr/bin/g++ -DONLINE_JUDGE -O2 -w -fmax-errors=3 -std=c++11 {src_path} -lm -o {exe_path}', NULL);
INSERT INTO `compile` VALUES (4, 'java_lang_config', 'Main.java', 'Main', 3000, 3000, -1, '/usr/bin/javac {src_path} -d {exe_dir} -encoding UTF8', NULL);
INSERT INTO `compile` VALUES (5, 'py2_lang_config', 'solution.py', 'solution.pyc', 3000, 5000, 134217728, '/usr/bin/python -m py_compile {src_path}', NULL);
INSERT INTO `compile` VALUES (6, 'py3_lang_config', 'solution.py', '__pycache__/solution.cpython-36.pyc', 3000, 5000, 134217728, '/usr/bin/python3 -m py_compile {src_path}', NULL);
INSERT INTO `compile` VALUES (7, 'go_lang_config', 'main.go', 'main', 3000, 5000, 1073741824, '/usr/bin/go build -o {exe_path} {src_path}', 'GOCACHE=/tmp');

-- ----------------------------
-- Table structure for languages
-- ----------------------------
DROP TABLE IF EXISTS `languages`;
CREATE TABLE `languages`  (
  `language_id` int(20) NOT NULL AUTO_INCREMENT COMMENT '语言ID',
  `language_slug` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '语言缩写',
  `language_name` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '语言名称',
  `language_compile_id` int(20) NOT NULL COMMENT '编译命令id',
  `language_run_id` int(20) NOT NULL COMMENT '运行命令id',
  `language_suffix` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '语言文件后缀',
  `language_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标注',
  `is_spj` tinyint(1) UNSIGNED ZEROFILL NOT NULL DEFAULT 0 COMMENT '是否是特殊判题',
  `is_deleted` tinyint(1) UNSIGNED ZEROFILL NOT NULL DEFAULT 0 COMMENT '是否删除',
  PRIMARY KEY (`language_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of languages
-- ----------------------------
INSERT INTO `languages` VALUES (1, 'c_lang', 'C', 1, 1, 'c', 'GCC 5.4', 0, 0);
INSERT INTO `languages` VALUES (2, 'c_lang_spj', 'C', 2, 2, 'c', 'GCC 5.4', 1, 0);
INSERT INTO `languages` VALUES (3, 'cpp_lang', 'C++', 3, 3, 'cpp', 'G++ 5.4', 0, 0);
INSERT INTO `languages` VALUES (4, 'java_lang', 'Java', 4, 4, 'java', 'OpenJDK 1.8', 0, 0);
INSERT INTO `languages` VALUES (5, 'py2_lang', 'Python2', 5, 5, 'py', 'Python 2', 0, 0);
INSERT INTO `languages` VALUES (6, 'py3_lang', 'Python3', 6, 6, 'py', 'Python 3', 0, 0);
INSERT INTO `languages` VALUES (7, 'go_lang', 'Golang', 7, 7, 'go', 'Go', 0, 0);

-- ----------------------------
-- Table structure for run
-- ----------------------------
DROP TABLE IF EXISTS `run`;
CREATE TABLE `run`  (
  `run_id` int(20) NOT NULL AUTO_INCREMENT COMMENT '运行时配置的id',
  `config_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '配置的名称',
  `command` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `seccomp_rule` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `exe_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `env` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `memory_limit_check_only` int(20) NULL DEFAULT NULL,
  PRIMARY KEY (`run_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of run
-- ----------------------------
INSERT INTO `run` VALUES (1, 'c_lang_config', '{exe_path}', 'c_cpp', NULL, 'LANG=en_US.UTF-8,LANGUAGE=en_US:en,LC_ALL=en_US.UTF-8', NULL);
INSERT INTO `run` VALUES (2, 'c_lang_spj_config', '{exe_path} {in_file_path} {user_out_file_path}', 'c_cpp', 'spj-{spj_version}', NULL, NULL);
INSERT INTO `run` VALUES (3, 'cpp_lang_config', '{exe_path}', 'c_cpp', NULL, 'LANG=en_US.UTF-8,LANGUAGE=en_US:en,LC_ALL=en_US.UTF-8', NULL);
INSERT INTO `run` VALUES (4, 'java_lang_config', '/usr/bin/java -cp {exe_dir} -XX:MaxRAM={max_memory}k -Djava.security.manager -Dfile.encoding=UTF-8 -Djava.security.policy==/etc/java_policy -Djava.awt.headless=true Main', NULL, NULL, 'LANG=en_US.UTF-8,LANGUAGE=en_US:en,LC_ALL=en_US.UTF-8', 1);
INSERT INTO `run` VALUES (5, 'py2_lang_config', '/usr/bin/python {exe_path}', 'general', NULL, 'LANG=en_US.UTF-8,LANGUAGE=en_US:en,LC_ALL=en_US.UTF-8', NULL);
INSERT INTO `run` VALUES (6, 'py3_lang_config', '/usr/bin/python3 {exe_path}', 'general', NULL, 'PYTHONIOENCODING=UTF-8,LANG=en_US.UTF-8,LANGUAGE=en_US:en,LC_ALL=en_US.UTF-8', NULL);
INSERT INTO `run` VALUES (7, 'go_lang_config', '{exe_path}', '', NULL, 'GODEBUG=madvdontneed=1,GOCACHE=off,LANG=en_US.UTF-8,LANGUAGE=en_US:en,LC_ALL=en_US.UTF-8', 1);

-- ----------------------------
-- Table structure for submission
-- ----------------------------
DROP TABLE IF EXISTS `submission`;
CREATE TABLE `submission`  (
  `submission_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '提交记录id',
  `submission_user_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '提交用户id',
  `submission_problem_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '题目id',
  `submission_contest_id` bigint(20) NULL DEFAULT NULL COMMENT '竞赛id',
  `submission_language_id` int(11) NOT NULL DEFAULT 0 COMMENT '解题使用语言id',
  `submission_source_code` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '提交源码',
  `submission_commit_time` datetime(0) NOT NULL COMMENT '提交时间',
  `submission_status` int(11) NOT NULL DEFAULT 9 COMMENT '判题状态',
  `submission_used_time` int(11) NULL DEFAULT NULL COMMENT '运行时间(MS)',
  `submission_used_memory` int(11) NULL DEFAULT NULL COMMENT '运行所需内存大小(KB)',
  PRIMARY KEY (`submission_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of submission
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
