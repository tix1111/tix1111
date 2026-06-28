# 数据库字段详细定义（基础表与权限体系）

> 数据库名：`lz`，字符集：`utf8mb4`，排序：`utf8mb4_unicode_ci`。
> 所有 `id` 均使用 `BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY`。
> 所有时间字段类型均为 `DATETIME`，默认 `CURRENT_TIMESTAMP`。
> 金额字段类型均为 `DECIMAL(14,2)`，数量字段均为 `DECIMAL(14,4)`。

## 1. 用户表 `users`

```sql
CREATE TABLE users (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(64)  NOT NULL UNIQUE COMMENT '账号',
  password_hash VARCHAR(255) NOT NULL COMMENT 'password_hash 加密',
  phone         VARCHAR(20)  NOT NULL COMMENT '手机号（可加密存储）',
  real_name     VARCHAR(64)  COMMENT '真实姓名',
  employee_id   BIGINT UNSIGNED COMMENT '关联员工档案 ID',
  account_type  TINYINT NOT NULL DEFAULT 0 COMMENT '0内部 1供应商 2外部协作 3临时',
  supplier_id   BIGINT UNSIGNED COMMENT '供应商账号关联',
  status        TINYINT NOT NULL DEFAULT 1 COMMENT '0禁用 1正常 2锁定',
  failed_count  TINYINT NOT NULL DEFAULT 0 COMMENT '连续失败次数',
  locked_at     DATETIME     COMMENT '账号锁定时间',
  last_login_at DATETIME     COMMENT '最近登录时间',
  last_login_ip VARCHAR(64)  COMMENT '最近登录IP',
  must_change_pwd TINYINT NOT NULL DEFAULT 1 COMMENT '首次登录必须改密码',
  remark        VARCHAR(500) COMMENT '备注',
  created_by    BIGINT UNSIGNED NOT NULL DEFAULT 0,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME COMMENT '软删除'
) ENGINE=InnoDB;
```

## 2. 角色表 `roles`

```sql
CREATE TABLE roles (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(64) NOT NULL COMMENT '角色名称',
  code        VARCHAR(64) NOT NULL UNIQUE COMMENT '角色编码，如 ADMIN、DEPT_MANAGER、USER',
  description VARCHAR(500) COMMENT '说明',
  is_system   TINYINT NOT NULL DEFAULT 0 COMMENT '1系统内置，不允许删除',
  status      TINYINT NOT NULL DEFAULT 1 COMMENT '0禁用 1启用',
  sort        INT NOT NULL DEFAULT 0 COMMENT '排序',
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB;
```

## 3. 用户角色关联 `user_roles`

```sql
CREATE TABLE user_roles (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id    BIGINT UNSIGNED NOT NULL,
  role_id    BIGINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_role (user_id, role_id)
) ENGINE=InnoDB;
```

## 4. 部门表 `departments`

```sql
CREATE TABLE departments (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(128) NOT NULL COMMENT '部门名称',
  parent_id   BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '上级部门，0=顶级',
  leader_id   BIGINT UNSIGNED COMMENT '负责人用户 ID',
  sort        INT NOT NULL DEFAULT 0,
  level       TINYINT NOT NULL DEFAULT 1 COMMENT '层级深度',
  path        VARCHAR(500) COMMENT '路径，如 /1/3/5/',
  status      TINYINT NOT NULL DEFAULT 1,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB;
```

## 5. 岗位表 `positions`

```sql
CREATE TABLE positions (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(128) NOT NULL COMMENT '岗位名称',
  code          VARCHAR(64) UNIQUE COMMENT '岗位编码',
  department_id BIGINT UNSIGNED COMMENT '所属部门（可空表示通用岗位）',
  status        TINYINT NOT NULL DEFAULT 1,
  sort          INT NOT NULL DEFAULT 0,
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME
) ENGINE=InnoDB;
```

## 6. 模块表 `modules`

```sql
CREATE TABLE modules (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(128) NOT NULL COMMENT '模块名称',
  code        VARCHAR(64)  NOT NULL UNIQUE COMMENT '模块编码',
  icon        VARCHAR(128) COMMENT '图标',
  sort        INT NOT NULL DEFAULT 0,
  status      TINYINT NOT NULL DEFAULT 1 COMMENT '0停用 1启用',
  is_system   TINYINT NOT NULL DEFAULT 0 COMMENT '1系统内置',
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB;
```

## 7. 菜单表 `menus`

```sql
CREATE TABLE menus (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  module_id   BIGINT UNSIGNED NOT NULL COMMENT '所属模块',
  parent_id   BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '父菜单，0=主菜单',
  name        VARCHAR(128) NOT NULL COMMENT '菜单名称',
  route       VARCHAR(255) COMMENT '前端路由或页面路径',
  icon        VARCHAR(128) COMMENT '图标',
  sort        INT NOT NULL DEFAULT 0,
  level       TINYINT NOT NULL DEFAULT 1 COMMENT '1主菜单 2二级菜单',
  is_hidden   TINYINT NOT NULL DEFAULT 0 COMMENT '1仅具有URL但不显示在导航',
  status      TINYINT NOT NULL DEFAULT 1,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB;
```

## 8. 权限点表 `permissions`

```sql
CREATE TABLE permissions (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  module_id   BIGINT UNSIGNED NOT NULL,
  menu_id     BIGINT UNSIGNED COMMENT '关联菜单（可为空表示模块级权限）',
  name        VARCHAR(128) NOT NULL COMMENT '权限名称，如"新增客户"',
  code        VARCHAR(128) NOT NULL UNIQUE COMMENT '权限编码，如 customer.create',
  type        VARCHAR(32) NOT NULL COMMENT 'menu/button/api/export',
  api_path    VARCHAR(255) COMMENT '对应 API 路径',
  sort        INT NOT NULL DEFAULT 0,
  status      TINYINT NOT NULL DEFAULT 1,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB;
```

## 9. 角色菜单关联 `role_menus`

```sql
CREATE TABLE role_menus (
  id        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_id   BIGINT UNSIGNED NOT NULL,
  menu_id   BIGINT UNSIGNED NOT NULL,
  UNIQUE KEY uk_role_menu (role_id, menu_id)
) ENGINE=InnoDB;
```

## 10. 角色权限关联 `role_permissions`

```sql
CREATE TABLE role_permissions (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_id        BIGINT UNSIGNED NOT NULL,
  permission_id  BIGINT UNSIGNED NOT NULL,
  UNIQUE KEY uk_role_perm (role_id, permission_id)
) ENGINE=InnoDB;
```

## 11. 数据权限范围 `data_scopes`

```sql
CREATE TABLE data_scopes (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_id      BIGINT UNSIGNED NOT NULL,
  scope_type   VARCHAR(32) NOT NULL COMMENT 'self/dept/multi_dept/all/custom',
  department_ids TEXT COMMENT '多部门 ID（JSON 数组，scope_type=multi_dept 时使用）',
  created_by   BIGINT UNSIGNED,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by   BIGINT UNSIGNED,
  updated_at   DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_role_scope (role_id)
) ENGINE=InnoDB;
```

## 12. 字典主表 `dictionaries`

```sql
CREATE TABLE dictionaries (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  type        VARCHAR(64)  NOT NULL UNIQUE COMMENT '字典类型编码，如 expense_category',
  name        VARCHAR(128) NOT NULL COMMENT '字典类型名称',
  description VARCHAR(500),
  is_system   TINYINT NOT NULL DEFAULT 0 COMMENT '1系统内置，只能增加子项不能删除类型',
  status      TINYINT NOT NULL DEFAULT 1,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB;
```

## 13. 字典项表 `dictionary_items`

```sql
CREATE TABLE dictionary_items (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  dictionary_id BIGINT UNSIGNED NOT NULL COMMENT '字典类型 ID',
  dict_type     VARCHAR(64) NOT NULL COMMENT '冗余字典类型编码，方便直接查询',
  label         VARCHAR(128) NOT NULL COMMENT '显示名称',
  value         VARCHAR(128) NOT NULL COMMENT '存储值',
  color         VARCHAR(32)  COMMENT '标签颜色',
  sort          INT NOT NULL DEFAULT 0,
  is_default    TINYINT NOT NULL DEFAULT 0 COMMENT '1是默认选项',
  status        TINYINT NOT NULL DEFAULT 1,
  remark        VARCHAR(500),
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME,
  UNIQUE KEY uk_type_value (dict_type, value)
) ENGINE=InnoDB;
```

## 14. 系统参数 `system_settings`

```sql
CREATE TABLE system_settings (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  group_name  VARCHAR(64)  NOT NULL COMMENT '参数分组，如 security、mail、sms',
  key_name    VARCHAR(128) NOT NULL COMMENT '参数键',
  value       TEXT         COMMENT '参数值',
  description VARCHAR(500) COMMENT '说明',
  is_secret   TINYINT NOT NULL DEFAULT 0 COMMENT '1保密参数，不返回给前端',
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_group_key (group_name, key_name)
) ENGINE=InnoDB;
```

## 15. 登录日志 `login_logs`

```sql
CREATE TABLE login_logs (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id    BIGINT UNSIGNED COMMENT '为空表示账号不存在的尝试',
  username   VARCHAR(64) NOT NULL COMMENT '尝试登录的账号',
  result     TINYINT NOT NULL COMMENT '0失败 1成功',
  fail_reason VARCHAR(255) COMMENT '失败原因',
  ip         VARCHAR(64) NOT NULL,
  user_agent VARCHAR(500),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## 16. 操作日志 `operation_logs`

```sql
CREATE TABLE operation_logs (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id       BIGINT UNSIGNED NOT NULL,
  username      VARCHAR(64) NOT NULL,
  module        VARCHAR(64) NOT NULL COMMENT '模块编码',
  action        VARCHAR(64) NOT NULL COMMENT '操作类型，如 create/update/delete/view/export/download',
  business_type VARCHAR(64) COMMENT '业务类型',
  business_id   BIGINT UNSIGNED COMMENT '业务 ID',
  description   VARCHAR(500) COMMENT '操作描述',
  ip            VARCHAR(64) NOT NULL,
  request_method VARCHAR(16),
  api_path      VARCHAR(255),
  before_data   MEDIUMTEXT COMMENT '变更前数据（JSON）',
  after_data    MEDIUMTEXT COMMENT '变更后数据（JSON）',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## 17. 附件表 `attachments`

```sql
CREATE TABLE attachments (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  business_type   VARCHAR(64) NOT NULL COMMENT '业务类型，如 contract/project/engineering',
  business_id     BIGINT UNSIGNED NOT NULL COMMENT '业务单据 ID',
  file_name       VARCHAR(255) NOT NULL COMMENT '原始文件名',
  stored_name     VARCHAR(255) NOT NULL COMMENT '存储文件名（脱敏/随机）',
  file_path       VARCHAR(500) NOT NULL COMMENT '存储路径',
  file_size       INT UNSIGNED NOT NULL COMMENT '字节',
  mime_type       VARCHAR(128) NOT NULL COMMENT 'MIME 类型',
  file_ext        VARCHAR(32)  COMMENT '扩展名',
  security_level  TINYINT NOT NULL DEFAULT 0 COMMENT '密级：0不涉密 1内部 2秘密 3机密 4绝密',
  download_count  INT UNSIGNED NOT NULL DEFAULT 0,
  uploaded_by     BIGINT UNSIGNED NOT NULL,
  uploaded_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at      DATETIME,
  UNIQUE KEY uk_stored_name (stored_name)
) ENGINE=InnoDB;
```

## 18. 验证码 `captcha_codes`

```sql
CREATE TABLE captcha_codes (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  phone      VARCHAR(20) COMMENT '手机号（短信验证码时有值）',
  session_id VARCHAR(128) COMMENT '图形验证码关联会话',
  code       VARCHAR(16) NOT NULL,
  type       VARCHAR(32) NOT NULL COMMENT 'register/login/forgot_password',
  used       TINYINT NOT NULL DEFAULT 0,
  expired_at DATETIME NOT NULL COMMENT '有效期',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## 19. 待办表 `todo_items`

```sql
CREATE TABLE todo_items (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id       BIGINT UNSIGNED NOT NULL COMMENT '待办接收人',
  type          VARCHAR(64) NOT NULL COMMENT '待办类型，如 approval/work_order/training',
  business_type VARCHAR(64) NOT NULL,
  business_id   BIGINT UNSIGNED NOT NULL,
  title         VARCHAR(255) NOT NULL,
  source_user_id BIGINT UNSIGNED COMMENT '来源用户',
  priority      TINYINT NOT NULL DEFAULT 0 COMMENT '0普通 1重要 2紧急',
  status        TINYINT NOT NULL DEFAULT 0 COMMENT '0未读 1已读 2已处理',
  due_at        DATETIME COMMENT '截止时间',
  read_at       DATETIME,
  completed_at  DATETIME,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB;
```

## 20. 消息提醒 `messages`

```sql
CREATE TABLE messages (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id       BIGINT UNSIGNED NOT NULL COMMENT '接收用户',
  type          VARCHAR(64) NOT NULL COMMENT '类型：notify/alert/system',
  business_type VARCHAR(64) COMMENT '关联业务类型',
  business_id   BIGINT UNSIGNED COMMENT '关联业务 ID',
  title         VARCHAR(255) NOT NULL,
  content       TEXT,
  is_read       TINYINT NOT NULL DEFAULT 0,
  read_at       DATETIME,
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_read (user_id, is_read)
) ENGINE=InnoDB;
```

## 21. 业务事件 `business_events`

```sql
CREATE TABLE business_events (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  event_type    VARCHAR(64) NOT NULL COMMENT '事件类型，如 reimbursement.approved/order.shipped',
  business_type VARCHAR(64) NOT NULL,
  business_id   BIGINT UNSIGNED NOT NULL,
  actor_id      BIGINT UNSIGNED COMMENT '触发用户',
  payload       JSON COMMENT '事件数据',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_business (business_type, business_id)
) ENGINE=InnoDB;
```

## 21.1 事件联动任务 `event_tasks`

```sql
CREATE TABLE event_tasks (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  event_id       BIGINT UNSIGNED NOT NULL COMMENT '关联 business_events',
  task_key       VARCHAR(255) NOT NULL UNIQUE COMMENT '幂等键',
  task_type      VARCHAR(64) NOT NULL COMMENT 'todo/message/cost/update/callback',
  target_type    VARCHAR(64) COMMENT '目标类型',
  target_id      BIGINT UNSIGNED COMMENT '目标 ID',
  status         VARCHAR(16) NOT NULL DEFAULT 'pending' COMMENT 'pending/processing/done/failed',
  retry_count    TINYINT NOT NULL DEFAULT 0,
  last_error     TEXT,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  processed_at   DATETIME,
  INDEX idx_event (event_id),
  INDEX idx_status (status)
) ENGINE=InnoDB;
```

## 21.2 数据一致性检查日志 `consistency_check_logs`

```sql
CREATE TABLE consistency_check_logs (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  check_type     VARCHAR(64) NOT NULL COMMENT 'inventory/project_cost/approval/engineering/supplier/classified/all',
  business_type  VARCHAR(64) COMMENT '异常业务类型',
  business_id    BIGINT UNSIGNED COMMENT '异常业务 ID',
  message        VARCHAR(1000) NOT NULL COMMENT '异常说明',
  severity       VARCHAR(16) NOT NULL DEFAULT 'warning' COMMENT 'info/warning/error/critical',
  status         VARCHAR(16) NOT NULL DEFAULT 'open' COMMENT 'open/ignored/fixed',
  fixed_by       BIGINT UNSIGNED,
  fixed_at       DATETIME,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_type_status (check_type, status),
  INDEX idx_business (business_type, business_id)
) ENGINE=InnoDB;
```

## 22. 审批流程定义 `approval_flows`

```sql
CREATE TABLE approval_flows (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(128) NOT NULL,
  business_type VARCHAR(64) NOT NULL UNIQUE COMMENT '适用业务类型，一对一',
  form_id       BIGINT UNSIGNED COMMENT '关联表单 ID',
  is_active     TINYINT NOT NULL DEFAULT 1,
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME
) ENGINE=InnoDB;
```

## 23. 审批节点定义 `approval_nodes`

```sql
CREATE TABLE approval_nodes (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  flow_id       BIGINT UNSIGNED NOT NULL,
  node_name     VARCHAR(128) NOT NULL,
  node_order    INT NOT NULL DEFAULT 0 COMMENT '节点顺序',
  approver_type VARCHAR(32) NOT NULL COMMENT 'user/role/position/dept_leader/project_owner/self',
  approver_ids  TEXT COMMENT '具体审批人ID列表（JSON），approver_type=user时使用',
  role_id       BIGINT UNSIGNED COMMENT 'approver_type=role时使用',
  position_id   BIGINT UNSIGNED COMMENT 'approver_type=position时使用',
  approve_mode  VARCHAR(16) NOT NULL DEFAULT 'any' COMMENT 'any一人通过/all全部通过',
  condition_rule JSON COMMENT '条件规则（如金额>10000时才触发本节点）',
  timeout_hours INT COMMENT '超时小时数，NULL不限制',
  timeout_action VARCHAR(16) COMMENT 'pass自动通过/reject自动驳回/notify只通知',
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## 24. 审批实例 `approvals`

```sql
CREATE TABLE approvals (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  flow_id       BIGINT UNSIGNED NOT NULL,
  business_type VARCHAR(64) NOT NULL,
  business_id   BIGINT UNSIGNED NOT NULL,
  title         VARCHAR(255) NOT NULL,
  initiator_id  BIGINT UNSIGNED NOT NULL COMMENT '发起人',
  department_id BIGINT UNSIGNED,
  status        VARCHAR(16) NOT NULL DEFAULT 'approving' COMMENT 'approving/approved/rejected/cancelled/withdrawn',
  current_node_id BIGINT UNSIGNED COMMENT '当前节点',
  started_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  finished_at   DATETIME,
  remark        VARCHAR(500),
  INDEX idx_business (business_type, business_id),
  INDEX idx_initiator (initiator_id)
) ENGINE=InnoDB;
```

## 25. 审批任务 `approval_tasks`

```sql
CREATE TABLE approval_tasks (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  approval_id BIGINT UNSIGNED NOT NULL,
  node_id     BIGINT UNSIGNED NOT NULL,
  assignee_id BIGINT UNSIGNED NOT NULL COMMENT '处理人',
  action      VARCHAR(16) COMMENT 'approve/reject/transfer/countersign/withdraw',
  comment     TEXT COMMENT '审批意见',
  status      VARCHAR(16) NOT NULL DEFAULT 'pending' COMMENT 'pending/done/skipped',
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  done_at     DATETIME,
  INDEX idx_assignee_status (assignee_id, status)
) ENGINE=InnoDB;
```
