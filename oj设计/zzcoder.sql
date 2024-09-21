-- 创建数据库
CREATE DATABASE zzcoder;

-- 使用数据库
USE zzcoder;

-- 用户表
CREATE TABLE user (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    wx_unionid VARCHAR(32) UNIQUE COMMENT '微信unionid',
    wx_openid VARCHAR(32) UNIQUE COMMENT '微信openid', -- 可选字段
    username VARCHAR(32) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(128) NOT NULL COMMENT '登录密码',
    email VARCHAR(32) NOT NULL UNIQUE COMMENT '邮箱',
    phone_number VARCHAR(11) UNIQUE COMMENT '手机号码',
    avatar_url VARCHAR(128) COMMENT '头像图片地址',
    cf_username VARCHAR(32) COMMENT 'Codeforces的用户名',
    status INT DEFAULT 0 COMMENT '账号状态, 0可用, 1不可用',
    create_time DATETIME NOT NULL COMMENT '创建时间',
    update_time DATETIME NOT NULL '修改时间'
) COMMENT '用户表';
