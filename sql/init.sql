-- ============================================================
-- 系统初始化 SQL
-- 数据库名: lz
-- 字符集:   utf8mb4
-- 执行前确保 MySQL 版本 >= 5.7
-- 敏感字段（密码、手机号）在代码层处理，此处只插入系统内置数据
-- ============================================================

CREATE DATABASE IF NOT EXISTS lz
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE lz;

-- 初始化角色
INSERT INTO roles (id, name, code, description, is_system, status, sort) VALUES
  (1, '系统管理员', 'ADMIN',        '系统全部权限', 1, 1, 1),
  (2, '部门管理员', 'DEPT_MANAGER', '部门及授权范围权限', 1, 1, 2),
  (3, '普通用户',   'USER',         '基础业务权限', 1, 1, 3),
  (4, '供应商账号', 'SUPPLIER',     '供应链采购系统供应商', 1, 1, 4),
  (5, '外部协作',   'EXTERNAL',     '协作团队外部账号', 1, 1, 5);

-- 初始化顶级部门
INSERT INTO departments (id, name, parent_id, sort, level, path, status) VALUES
  (1, '总公司', 0, 0, 1, '/1/', 1);

-- 初始化账号（密码需在代码层用 password_hash 生成并单独执行 UPDATE，不在 SQL 中写明文）
-- 临时密码使用占位符，首次登录必须修改
INSERT INTO users (id, username, password_hash, phone, real_name, account_type, status, must_change_pwd) VALUES
  (1, 'admin', 'PLACEHOLDER_RUN_HASH_IN_PHP', '13800000001', '系统管理员', 0, 1, 1),
  (2, 'dpt1',  'PLACEHOLDER_RUN_HASH_IN_PHP', '13800000002', '部门管理员1', 0, 1, 1),
  (3, 'user1', 'PLACEHOLDER_RUN_HASH_IN_PHP', '13800000003', '普通用户1',  0, 1, 1);

-- 绑定角色
INSERT INTO user_roles (user_id, role_id) VALUES (1, 1), (2, 2), (3, 3);

-- ============================================================
-- 数据字典初始化
-- ============================================================

-- 字典类型
INSERT INTO dictionaries (id, type, name, is_system) VALUES
  (1,  'expense_category',    '费用类别',     1),
  (2,  'contract_type',       '合同类型',     1),
  (3,  'material_category',   '物料分类',     1),
  (4,  'customer_level',      '客户等级',     1),
  (5,  'customer_industry',   '客户行业',     1),
  (6,  'supplier_category',   '供应商分类',   1),
  (7,  'security_level',      '密级',         1),
  (8,  'approval_action',     '审批动作',     1),
  (9,  'business_status',     '业务状态',     1),
  (10, 'attendance_type',     '考勤类型',     1),
  (11, 'leave_type',          '请假类型',     1),
  (12, 'training_category',   '培训分类',     1),
  (13, 'work_order_type',     '工单类型',     1),
  (14, 'engineering_type',    '工程类型',     1),
  (15, 'party_meeting_type',  '党会类型',     1),
  (16, 'collaboration_type',  '协作团队类型', 1),
  (17, 'document_type',       '文档类型',     1),
  (18, 'qualification_type',  '资质类型',     1),
  (19, 'region',              '区域',         1),
  (20, 'currency',            '币种',         1);

-- 费用类别
INSERT INTO dictionary_items (dictionary_id, dict_type, label, value, sort) VALUES
  (1,'expense_category','差旅费',         'travel',          1),
  (1,'expense_category','交通费',         'transportation',   2),
  (1,'expense_category','餐饮费',         'meals',            3),
  (1,'expense_category','住宿费',         'accommodation',    4),
  (1,'expense_category','快递费',         'express',          5),
  (1,'expense_category','物业费',         'property',         6),
  (1,'expense_category','办公用品',       'office_supplies',  7),
  (1,'expense_category','招待费',         'entertainment',    8),
  (1,'expense_category','通讯费',         'communication',    9),
  (1,'expense_category','培训费',         'training',        10),
  (1,'expense_category','维修费',         'maintenance',     11),
  (1,'expense_category','采购费',         'procurement',     12),
  (1,'expense_category','其他费用',       'other',           99);

-- 合同类型
INSERT INTO dictionary_items (dictionary_id, dict_type, label, value, sort) VALUES
  (2,'contract_type','销售合同',   'sales',       1),
  (2,'contract_type','采购合同',   'purchase',    2),
  (2,'contract_type','服务合同',   'service',     3),
  (2,'contract_type','劳动合同',   'employment',  4),
  (2,'contract_type','运维合同',   'maintenance', 5),
  (2,'contract_type','租赁合同',   'lease',       6),
  (2,'contract_type','框架协议',   'framework',   7),
  (2,'contract_type','其他合同',   'other',       99);

-- 密级
INSERT INTO dictionary_items (dictionary_id, dict_type, label, value, sort, color) VALUES
  (7,'security_level','不涉密', '0', 0, '#888888'),
  (7,'security_level','内部',   '1', 1, '#409EFF'),
  (7,'security_level','秘密',   '2', 2, '#E6A23C'),
  (7,'security_level','机密',   '3', 3, '#F56C6C'),
  (7,'security_level','绝密',   '4', 4, '#C03639');

-- 请假类型
INSERT INTO dictionary_items (dictionary_id, dict_type, label, value, sort) VALUES
  (11,'leave_type','年假',      'annual',       1),
  (11,'leave_type','事假',      'personal',     2),
  (11,'leave_type','病假',      'sick',         3),
  (11,'leave_type','婚假',      'wedding',      4),
  (11,'leave_type','产假',      'maternity',    5),
  (11,'leave_type','陪产假',    'paternity',    6),
  (11,'leave_type','丧假',      'bereavement',  7),
  (11,'leave_type','调休',      'comp',         8);

-- 党会类型
INSERT INTO dictionary_items (dictionary_id, dict_type, label, value, sort) VALUES
  (15,'party_meeting_type','支部党员大会',   'member_meeting',   1),
  (15,'party_meeting_type','支委会',         'committee',        2),
  (15,'party_meeting_type','党小组会',       'group_meeting',    3),
  (15,'party_meeting_type','党课',           'party_class',      4),
  (15,'party_meeting_type','主题党日',       'party_day',        5),
  (15,'party_meeting_type','民主生活会',     'democratic_life',  6),
  (15,'party_meeting_type','组织生活会',     'org_life',         7);

-- 币种
INSERT INTO dictionary_items (dictionary_id, dict_type, label, value, sort, is_default) VALUES
  (20,'currency','人民币', 'CNY', 1, 1),
  (20,'currency','美元',   'USD', 2, 0),
  (20,'currency','欧元',   'EUR', 3, 0);

-- ============================================================
-- 密级规则初始化
-- ============================================================
INSERT INTO security_levels (id, name, level, default_period_days, auto_declassify, allow_download, need_approval_for_download, need_approval_for_share, audit_all_access) VALUES
  (1, '不涉密', 0, NULL, 0, 1, 0, 0, 0),
  (2, '内部',   1, 1825, 0, 1, 0, 0, 1),
  (3, '秘密',   2, 1825, 0, 1, 1, 1, 1),
  (4, '机密',   3, 3650, 0, 0, 1, 1, 1),
  (5, '绝密',   4, NULL, 0, 0, 1, 1, 1);

-- ============================================================
-- 系统参数初始化
-- ============================================================
INSERT INTO system_settings (group_name, key_name, value, description) VALUES
  ('security', 'password_min_length',  '8',      '密码最小长度'),
  ('security', 'password_complexity',  '1',      '1=要求大小写+数字'),
  ('security', 'password_expire_days', '90',     '密码有效期（天）0不限'),
  ('security', 'login_fail_lock',      '5',      '连续失败次数锁定账号'),
  ('security', 'session_timeout_mins', '120',    '会话超时（分钟）'),
  ('security', 'captcha_expire_mins',  '5',      '验证码有效期（分钟）'),
  ('upload',   'max_size_mb',          '50',     '单文件上传最大MB'),
  ('upload',   'allowed_exts',         'jpg,jpeg,png,gif,webp,pdf,doc,docx,xls,xlsx,ppt,pptx,zip,rar,mp4,avi,txt,csv', '允许的文件扩展名'),
  ('upload',   'upload_path',          '/uploads/', '文件存储基础路径'),
  ('system',   'site_name',            '企业管理系统', '系统名称'),
  ('system',   'icp_no',               '',       'ICP备案号'),
  ('system',   'default_timezone',     'Asia/Shanghai', '时区');
