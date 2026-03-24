-- =============================================================================
-- 博客系统数据库初始化脚本
-- 此脚本会在 Docker 容器首次启动时自动执行
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- 用户表
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    `password` VARCHAR(255) NOT NULL COMMENT '密码（加密存储）',
    `nickname` VARCHAR(100) DEFAULT NULL COMMENT '昵称',
    `role` VARCHAR(20) DEFAULT 'USER' COMMENT '角色：USER-普通用户，ADMIN-管理员',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 插入默认管理员账号（密码：123456，BCrypt 加密）
INSERT INTO `user` (`username`, `password`, `nickname`, `role`) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTV.91y', '系统管理员', 'ADMIN'),
('test', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTV.91y', '测试用户', 'USER');

-- -----------------------------------------------------------------------------
-- 文章表
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `article`;
CREATE TABLE `article` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '文章ID',
    `title` VARCHAR(200) NOT NULL COMMENT '文章标题',
    `content` TEXT NOT NULL COMMENT '文章内容',
    `user_id` INT NOT NULL COMMENT '作者用户ID',
    `view_count` INT DEFAULT 0 COMMENT '阅读次数',
    `status` TINYINT DEFAULT 0 COMMENT '状态：0-草稿，1-已发布，2-内容违规，3-复核中，4-复核通过，5-复核拒绝',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`),
    KEY `idx_create_time` (`create_time`),
    FULLTEXT KEY `ft_title_content` (`title`, `content`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章表';

-- 插入测试文章
INSERT INTO `article` (`title`, `content`, `user_id`, `view_count`, `status`) VALUES
('欢迎使用博客系统', '这是一篇测试文章，用于验证系统功能。您可以登录后创建自己的文章。', 1, 100, 1),
('Docker 部署指南', '使用 Docker Compose 可以快速部署整个应用栈，包括 MySQL、Redis 和后端服务。', 2, 50, 1);

-- -----------------------------------------------------------------------------
-- 申诉表
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `review_appeal`;
CREATE TABLE `review_appeal` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '申诉ID',
    `article_id` INT NOT NULL COMMENT '文章ID',
    `user_id` INT NOT NULL COMMENT '申诉用户ID',
    `reason` VARCHAR(1000) DEFAULT NULL COMMENT '申诉理由',
    `status` TINYINT DEFAULT 0 COMMENT '状态：0-待处理，1-已批准，2-已驳回',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `handle_time` DATETIME DEFAULT NULL COMMENT '处理时间',
    `handler_id` INT DEFAULT NULL COMMENT '处理人ID',
    `handler_note` VARCHAR(500) DEFAULT NULL COMMENT '处理备注',
    PRIMARY KEY (`id`),
    KEY `idx_article_id` (`article_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='申诉表';

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- 初始化完成
-- =============================================================================
