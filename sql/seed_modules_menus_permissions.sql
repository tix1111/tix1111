-- ============================================================
-- 模块、主菜单、基础权限点种子数据
-- 执行顺序：schema.sql -> init.sql -> seed_modules_menus_permissions.sql
-- ============================================================

USE lz;

-- 17 个主模块
INSERT INTO modules (id, name, code, icon, sort, status, is_system) VALUES
  (1,  '工作台',         'workbench',     'bi-speedometer2',  1, 1, 1),
  (2,  '审批管理',       'approval',      'bi-check2-square', 2, 1, 1),
  (3,  '项目管理',       'projects',      'bi-kanban',        3, 1, 1),
  (4,  '客户管理',       'customers',     'bi-people',        4, 1, 1),
  (5,  '人事管理',       'hr',            'bi-person-badge',  5, 1, 1),
  (6,  '财务管理',       'finance',       'bi-cash-stack',    6, 1, 1),
  (7,  '运维管理',       'ops',           'bi-tools',         7, 1, 1),
  (8,  '工程管理',       'engineering',   'bi-building',      8, 1, 1),
  (9,  '合同管理',       'contracts',     'bi-file-text',     9, 1, 1),
  (10, '库存管理',       'inventory',     'bi-box-seam',     10, 1, 1),
  (11, '培训管理',       'training',      'bi-mortarboard',  11, 1, 1),
  (12, '通知公告',       'notices',       'bi-megaphone',    12, 1, 1),
  (13, '系统管理',       'system',        'bi-gear',         13, 1, 1),
  (14, '涉密管理',       'classified',    'bi-shield-lock',  14, 1, 1),
  (15, '党建管理',       'party',         'bi-flag',         15, 1, 1),
  (16, '协作团队管理',   'collaboration', 'bi-diagram-3',    16, 1, 1),
  (17, '供应链采购管理', 'suppliers',     'bi-truck',        17, 1, 1)
ON DUPLICATE KEY UPDATE name=VALUES(name), sort=VALUES(sort), status=VALUES(status);

-- 主菜单
INSERT INTO menus (id, module_id, parent_id, name, route, icon, sort, level, status) VALUES
  (1,  1, 0, '工作台',         '/pages/workbench/index.php',     'bi-speedometer2',  1, 1, 1),
  (2,  2, 0, '审批管理',       '/pages/approval/index.php',      'bi-check2-square', 2, 1, 1),
  (3,  3, 0, '项目管理',       '/pages/projects/index.php',      'bi-kanban',        3, 1, 1),
  (4,  4, 0, '客户管理',       '/pages/customers/index.php',     'bi-people',        4, 1, 1),
  (5,  5, 0, '人事管理',       '/pages/hr/index.php',            'bi-person-badge',  5, 1, 1),
  (6,  6, 0, '财务管理',       '/pages/finance/index.php',       'bi-cash-stack',    6, 1, 1),
  (7,  7, 0, '运维管理',       '/pages/ops/index.php',           'bi-tools',         7, 1, 1),
  (8,  8, 0, '工程管理',       '/pages/engineering/index.php',   'bi-building',      8, 1, 1),
  (9,  9, 0, '合同管理',       '/pages/contracts/index.php',     'bi-file-text',     9, 1, 1),
  (10,10, 0, '库存管理',       '/pages/inventory/index.php',     'bi-box-seam',     10, 1, 1),
  (11,11, 0, '培训管理',       '/pages/training/index.php',      'bi-mortarboard',  11, 1, 1),
  (12,12, 0, '通知公告',       '/pages/notices/index.php',       'bi-megaphone',    12, 1, 1),
  (13,13, 0, '系统管理',       '/pages/system/index.php',        'bi-gear',         13, 1, 1),
  (14,14, 0, '涉密管理',       '/pages/classified/index.php',    'bi-shield-lock',  14, 1, 1),
  (15,15, 0, '党建管理',       '/pages/party/index.php',         'bi-flag',         15, 1, 1),
  (16,16, 0, '协作团队管理',   '/pages/collaboration/index.php', 'bi-diagram-3',    16, 1, 1),
  (17,17, 0, '供应链采购管理', '/pages/suppliers/index.php',     'bi-truck',        17, 1, 1)
ON DUPLICATE KEY UPDATE name=VALUES(name), route=VALUES(route), sort=VALUES(sort);

-- 基础权限点：每个模块 view/create/update/delete/export
INSERT INTO permissions (module_id, menu_id, name, code, type, api_path, sort, status)
SELECT m.id, me.id, CONCAT(m.name, '查看'), CONCAT(m.code, '.view'), 'api', CONCAT('/api/', m.code, '/list.php'), 1, 1
FROM modules m JOIN menus me ON me.module_id = m.id AND me.parent_id = 0
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO permissions (module_id, menu_id, name, code, type, api_path, sort, status)
SELECT m.id, me.id, CONCAT(m.name, '新增'), CONCAT(m.code, '.create'), 'button', CONCAT('/api/', m.code, '/save.php'), 2, 1
FROM modules m JOIN menus me ON me.module_id = m.id AND me.parent_id = 0
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO permissions (module_id, menu_id, name, code, type, api_path, sort, status)
SELECT m.id, me.id, CONCAT(m.name, '编辑'), CONCAT(m.code, '.update'), 'button', CONCAT('/api/', m.code, '/save.php'), 3, 1
FROM modules m JOIN menus me ON me.module_id = m.id AND me.parent_id = 0
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO permissions (module_id, menu_id, name, code, type, api_path, sort, status)
SELECT m.id, me.id, CONCAT(m.name, '删除'), CONCAT(m.code, '.delete'), 'button', CONCAT('/api/', m.code, '/delete.php'), 4, 1
FROM modules m JOIN menus me ON me.module_id = m.id AND me.parent_id = 0
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO permissions (module_id, menu_id, name, code, type, api_path, sort, status)
SELECT m.id, me.id, CONCAT(m.name, '导出'), CONCAT(m.code, '.export'), 'button', CONCAT('/api/', m.code, '/export.php'), 5, 1
FROM modules m JOIN menus me ON me.module_id = m.id AND me.parent_id = 0
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- 系统管理员拥有全部菜单和权限
INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT 1, id FROM menus;

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions;

-- 部门管理员默认拥有非系统管理主菜单查看权限
INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT 2, id FROM menus WHERE module_id <> 13;

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, p.id
FROM permissions p
JOIN modules m ON p.module_id = m.id
WHERE m.code NOT IN ('system')
  AND p.code NOT LIKE '%.delete';

-- 普通用户默认拥有基础查看权限（系统/涉密管理仅授权时开放）
INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT 3, id FROM menus
WHERE module_id IN (1,2,3,4,5,6,7,8,9,10,11,12,15,16,17);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, p.id
FROM permissions p
JOIN modules m ON p.module_id = m.id
WHERE p.code LIKE '%.view'
  AND m.code IN ('workbench','approval','projects','customers','hr','finance','ops','engineering','contracts','inventory','training','notices','party','collaboration','suppliers');

-- 供应商账号默认只拥有供应链采购查看/处理相关权限
INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT 4, id FROM menus WHERE module_id IN (1,17);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 4, p.id
FROM permissions p
JOIN modules m ON p.module_id = m.id
WHERE m.code IN ('workbench','suppliers') AND p.code NOT LIKE '%.delete';

-- 外部协作账号默认只拥有工作台和协作团队查看/执行相关权限
INSERT IGNORE INTO role_menus (role_id, menu_id)
SELECT 5, id FROM menus WHERE module_id IN (1,16);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 5, p.id
FROM permissions p
JOIN modules m ON p.module_id = m.id
WHERE m.code IN ('workbench','collaboration') AND p.code IN ('workbench.view','collaboration.view','collaboration.update');
