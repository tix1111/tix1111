-- ============================================================
-- 系统建表脚本
-- 数据库名: lz   字符集: utf8mb4   排序: utf8mb4_unicode_ci
-- MySQL >= 5.7    Engine: InnoDB
-- 执行顺序: schema.sql → init.sql
-- ============================================================

USE lz;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 基础权限体系
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username        VARCHAR(64)  NOT NULL UNIQUE,
  password_hash   VARCHAR(255) NOT NULL,
  phone           VARCHAR(20)  NOT NULL,
  real_name       VARCHAR(64),
  employee_id     BIGINT UNSIGNED,
  account_type    TINYINT NOT NULL DEFAULT 0 COMMENT '0内部 1供应商 2外部协作 3临时',
  supplier_id     BIGINT UNSIGNED,
  status          TINYINT NOT NULL DEFAULT 1 COMMENT '0禁用 1正常 2锁定',
  failed_count    TINYINT NOT NULL DEFAULT 0,
  locked_at       DATETIME,
  last_login_at   DATETIME,
  last_login_ip   VARCHAR(64),
  must_change_pwd TINYINT NOT NULL DEFAULT 1,
  remark          VARCHAR(500),
  created_by      BIGINT UNSIGNED NOT NULL DEFAULT 0,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS roles (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(64) NOT NULL,
  code        VARCHAR(64) NOT NULL UNIQUE,
  description VARCHAR(500),
  is_system   TINYINT NOT NULL DEFAULT 0,
  status      TINYINT NOT NULL DEFAULT 1,
  sort        INT NOT NULL DEFAULT 0,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_roles (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id    BIGINT UNSIGNED NOT NULL,
  role_id    BIGINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_role (user_id, role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS departments (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(128) NOT NULL,
  parent_id   BIGINT UNSIGNED NOT NULL DEFAULT 0,
  leader_id   BIGINT UNSIGNED,
  sort        INT NOT NULL DEFAULT 0,
  level       TINYINT NOT NULL DEFAULT 1,
  path        VARCHAR(500),
  status      TINYINT NOT NULL DEFAULT 1,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS positions (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(128) NOT NULL,
  code          VARCHAR(64) UNIQUE,
  department_id BIGINT UNSIGNED,
  status        TINYINT NOT NULL DEFAULT 1,
  sort          INT NOT NULL DEFAULT 0,
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS modules (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(128) NOT NULL,
  code        VARCHAR(64) NOT NULL UNIQUE,
  icon        VARCHAR(128),
  sort        INT NOT NULL DEFAULT 0,
  status      TINYINT NOT NULL DEFAULT 1,
  is_system   TINYINT NOT NULL DEFAULT 0,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS menus (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  module_id   BIGINT UNSIGNED NOT NULL,
  parent_id   BIGINT UNSIGNED NOT NULL DEFAULT 0,
  name        VARCHAR(128) NOT NULL,
  route       VARCHAR(255),
  icon        VARCHAR(128),
  sort        INT NOT NULL DEFAULT 0,
  level       TINYINT NOT NULL DEFAULT 1,
  is_hidden   TINYINT NOT NULL DEFAULT 0,
  status      TINYINT NOT NULL DEFAULT 1,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS permissions (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  module_id   BIGINT UNSIGNED NOT NULL,
  menu_id     BIGINT UNSIGNED,
  name        VARCHAR(128) NOT NULL,
  code        VARCHAR(128) NOT NULL UNIQUE,
  type        VARCHAR(32) NOT NULL,
  api_path    VARCHAR(255),
  sort        INT NOT NULL DEFAULT 0,
  status      TINYINT NOT NULL DEFAULT 1,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS role_menus (
  id        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_id   BIGINT UNSIGNED NOT NULL,
  menu_id   BIGINT UNSIGNED NOT NULL,
  UNIQUE KEY uk_role_menu (role_id, menu_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS role_permissions (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_id        BIGINT UNSIGNED NOT NULL,
  permission_id  BIGINT UNSIGNED NOT NULL,
  UNIQUE KEY uk_role_perm (role_id, permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS data_scopes (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_id        BIGINT UNSIGNED NOT NULL,
  scope_type     VARCHAR(32) NOT NULL,
  department_ids TEXT,
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by     BIGINT UNSIGNED,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_role_scope (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_departments (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id       BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_dept (user_id, department_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 系统基础
-- ============================================================

CREATE TABLE IF NOT EXISTS dictionaries (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  type        VARCHAR(64) NOT NULL UNIQUE,
  name        VARCHAR(128) NOT NULL,
  description VARCHAR(500),
  is_system   TINYINT NOT NULL DEFAULT 0,
  status      TINYINT NOT NULL DEFAULT 1,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS dictionary_items (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  dictionary_id BIGINT UNSIGNED NOT NULL,
  dict_type     VARCHAR(64) NOT NULL,
  label         VARCHAR(128) NOT NULL,
  value         VARCHAR(128) NOT NULL,
  color         VARCHAR(32),
  sort          INT NOT NULL DEFAULT 0,
  is_default    TINYINT NOT NULL DEFAULT 0,
  status        TINYINT NOT NULL DEFAULT 1,
  remark        VARCHAR(500),
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME,
  UNIQUE KEY uk_type_value (dict_type, value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS system_settings (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  group_name  VARCHAR(64) NOT NULL,
  key_name    VARCHAR(128) NOT NULL,
  value       TEXT,
  description VARCHAR(500),
  is_secret   TINYINT NOT NULL DEFAULT 0,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_group_key (group_name, key_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS login_logs (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT UNSIGNED,
  username    VARCHAR(64) NOT NULL,
  result      TINYINT NOT NULL,
  fail_reason VARCHAR(255),
  ip          VARCHAR(64) NOT NULL,
  user_agent  VARCHAR(500),
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_time (user_id, created_at),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS operation_logs (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id        BIGINT UNSIGNED NOT NULL,
  username       VARCHAR(64) NOT NULL,
  module         VARCHAR(64) NOT NULL,
  action         VARCHAR(64) NOT NULL,
  business_type  VARCHAR(64),
  business_id    BIGINT UNSIGNED,
  description    VARCHAR(500),
  ip             VARCHAR(64) NOT NULL,
  request_method VARCHAR(16),
  api_path       VARCHAR(255),
  before_data    MEDIUMTEXT,
  after_data     MEDIUMTEXT,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_business (business_type, business_id),
  INDEX idx_user_time (user_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS captcha_codes (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  phone      VARCHAR(20),
  session_id VARCHAR(128),
  code       VARCHAR(16) NOT NULL,
  type       VARCHAR(32) NOT NULL,
  used       TINYINT NOT NULL DEFAULT 0,
  expired_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_phone_type (phone, type),
  INDEX idx_session (session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS attachments (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  business_type  VARCHAR(64) NOT NULL,
  business_id    BIGINT UNSIGNED NOT NULL,
  file_name      VARCHAR(255) NOT NULL,
  stored_name    VARCHAR(255) NOT NULL,
  file_path      VARCHAR(500) NOT NULL,
  file_size      INT UNSIGNED NOT NULL,
  mime_type      VARCHAR(128) NOT NULL,
  file_ext       VARCHAR(32),
  security_level TINYINT NOT NULL DEFAULT 0,
  download_count INT UNSIGNED NOT NULL DEFAULT 0,
  uploaded_by    BIGINT UNSIGNED NOT NULL,
  uploaded_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at     DATETIME,
  UNIQUE KEY uk_stored_name (stored_name),
  INDEX idx_business (business_type, business_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS todo_items (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id        BIGINT UNSIGNED NOT NULL,
  type           VARCHAR(64) NOT NULL,
  business_type  VARCHAR(64) NOT NULL,
  business_id    BIGINT UNSIGNED NOT NULL,
  title          VARCHAR(255) NOT NULL,
  source_user_id BIGINT UNSIGNED,
  priority       TINYINT NOT NULL DEFAULT 0,
  status         TINYINT NOT NULL DEFAULT 0,
  due_at         DATETIME,
  read_at        DATETIME,
  completed_at   DATETIME,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_status (user_id, status),
  INDEX idx_business (business_type, business_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS messages (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id        BIGINT UNSIGNED NOT NULL,
  type           VARCHAR(64) NOT NULL,
  business_type  VARCHAR(64),
  business_id    BIGINT UNSIGNED,
  title          VARCHAR(255) NOT NULL,
  content        TEXT,
  is_read        TINYINT NOT NULL DEFAULT 0,
  read_at        DATETIME,
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_read (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS business_events (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  event_type     VARCHAR(64) NOT NULL,
  business_type  VARCHAR(64) NOT NULL,
  business_id    BIGINT UNSIGNED NOT NULL,
  actor_id       BIGINT UNSIGNED,
  payload        JSON,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_business (business_type, business_id),
  INDEX idx_event_type (event_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS event_tasks (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  event_id       BIGINT UNSIGNED NOT NULL,
  task_key       VARCHAR(255) NOT NULL UNIQUE,
  task_type      VARCHAR(64) NOT NULL,
  target_type    VARCHAR(64),
  target_id      BIGINT UNSIGNED,
  status         VARCHAR(16) NOT NULL DEFAULT 'pending',
  retry_count    TINYINT NOT NULL DEFAULT 0,
  last_error     TEXT,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  processed_at   DATETIME,
  INDEX idx_event (event_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS consistency_check_logs (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  check_type     VARCHAR(64) NOT NULL,
  business_type  VARCHAR(64),
  business_id    BIGINT UNSIGNED,
  message        VARCHAR(1000) NOT NULL,
  severity       VARCHAR(16) NOT NULL DEFAULT 'warning',
  status         VARCHAR(16) NOT NULL DEFAULT 'open',
  fixed_by       BIGINT UNSIGNED,
  fixed_at       DATETIME,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_type_status (check_type, status),
  INDEX idx_business (business_type, business_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 审批引擎
-- ============================================================

CREATE TABLE IF NOT EXISTS approval_flows (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name           VARCHAR(128) NOT NULL,
  business_type  VARCHAR(64) NOT NULL UNIQUE,
  form_id        BIGINT UNSIGNED,
  is_active      TINYINT NOT NULL DEFAULT 1,
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by     BIGINT UNSIGNED,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at     DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS approval_nodes (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  flow_id        BIGINT UNSIGNED NOT NULL,
  node_name      VARCHAR(128) NOT NULL,
  node_order     INT NOT NULL DEFAULT 0,
  approver_type  VARCHAR(32) NOT NULL,
  approver_ids   TEXT,
  role_id        BIGINT UNSIGNED,
  position_id    BIGINT UNSIGNED,
  approve_mode   VARCHAR(16) NOT NULL DEFAULT 'any',
  condition_rule JSON,
  timeout_hours  INT,
  timeout_action VARCHAR(16),
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by     BIGINT UNSIGNED,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_flow_order (flow_id, node_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS approval_forms (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(128) NOT NULL,
  business_type VARCHAR(64) NOT NULL,
  fields        JSON NOT NULL COMMENT '表单字段定义',
  version       SMALLINT NOT NULL DEFAULT 1,
  status        TINYINT NOT NULL DEFAULT 1,
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS approvals (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  flow_id          BIGINT UNSIGNED NOT NULL,
  business_type    VARCHAR(64) NOT NULL,
  business_id      BIGINT UNSIGNED NOT NULL,
  title            VARCHAR(255) NOT NULL,
  initiator_id     BIGINT UNSIGNED NOT NULL,
  department_id    BIGINT UNSIGNED,
  status           VARCHAR(16) NOT NULL DEFAULT 'approving',
  current_node_id  BIGINT UNSIGNED,
  started_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  finished_at      DATETIME,
  remark           VARCHAR(500),
  INDEX idx_business (business_type, business_id),
  INDEX idx_initiator (initiator_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS approval_tasks (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  approval_id  BIGINT UNSIGNED NOT NULL,
  node_id      BIGINT UNSIGNED NOT NULL,
  assignee_id  BIGINT UNSIGNED NOT NULL,
  action       VARCHAR(16),
  comment      TEXT,
  status       VARCHAR(16) NOT NULL DEFAULT 'pending',
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  done_at      DATETIME,
  INDEX idx_assignee_status (assignee_id, status),
  INDEX idx_approval (approval_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS approval_delegations (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  delegator_id BIGINT UNSIGNED NOT NULL,
  delegate_id  BIGINT UNSIGNED NOT NULL,
  scope        VARCHAR(64) COMMENT '委托范围，NULL表示全部',
  start_at     DATETIME NOT NULL,
  end_at       DATETIME NOT NULL,
  status       TINYINT NOT NULL DEFAULT 1,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_delegator (delegator_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 人事与组织
-- ============================================================

CREATE TABLE IF NOT EXISTS employees (
  id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id           BIGINT UNSIGNED UNIQUE,
  emp_no            VARCHAR(32) NOT NULL UNIQUE,
  real_name         VARCHAR(64) NOT NULL,
  gender            TINYINT,
  birthday          DATE,
  id_card           VARCHAR(64),
  phone             VARCHAR(20) NOT NULL,
  email             VARCHAR(128),
  department_id     BIGINT UNSIGNED NOT NULL,
  position_id       BIGINT UNSIGNED,
  entry_date        DATE NOT NULL,
  probation_end     DATE,
  confirmed_date    DATE,
  leave_date        DATE,
  emp_status        VARCHAR(16) NOT NULL DEFAULT 'active',
  contract_type     VARCHAR(32),
  photo_url         VARCHAR(500),
  emergency_contact VARCHAR(64),
  emergency_phone   VARCHAR(20),
  address           VARCHAR(500),
  education         VARCHAR(32),
  major             VARCHAR(128),
  graduate_school   VARCHAR(128),
  remark            TEXT,
  created_by        BIGINT UNSIGNED,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by        BIGINT UNSIGNED,
  updated_at        DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at        DATETIME,
  INDEX idx_dept (department_id),
  INDEX idx_status (emp_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS attendance_records (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  employee_id    BIGINT UNSIGNED NOT NULL,
  record_date    DATE NOT NULL,
  check_in_at    DATETIME,
  check_out_at   DATETIME,
  location       VARCHAR(255),
  ip             VARCHAR(64),
  type           VARCHAR(16) NOT NULL DEFAULT 'normal',
  abnormal_reason VARCHAR(255),
  approval_id    BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_emp_date (employee_id, record_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS salary_records (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  employee_id    BIGINT UNSIGNED NOT NULL,
  period         VARCHAR(7) NOT NULL,
  base_salary    DECIMAL(14,2) NOT NULL,
  performance    DECIMAL(14,2),
  allowance      DECIMAL(14,2),
  overtime_pay   DECIMAL(14,2),
  deductions     DECIMAL(14,2),
  social_ins_emp DECIMAL(14,2),
  provident_fund DECIMAL(14,2),
  personal_tax   DECIMAL(14,2),
  net_salary     DECIMAL(14,2) NOT NULL,
  status         VARCHAR(16) NOT NULL DEFAULT 'draft',
  confirmed_by   BIGINT UNSIGNED,
  confirmed_at   DATETIME,
  paid_at        DATETIME,
  remark         TEXT,
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by     BIGINT UNSIGNED,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_emp_period (employee_id, period)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS performance_plans (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(128) NOT NULL,
  period        VARCHAR(7) NOT NULL,
  scope_type    VARCHAR(16) NOT NULL,
  department_id BIGINT UNSIGNED,
  position_id   BIGINT UNSIGNED,
  kpi_rules     JSON,
  status        VARCHAR(16) NOT NULL DEFAULT 'draft',
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS performance_results (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  plan_id       BIGINT UNSIGNED NOT NULL,
  employee_id   BIGINT UNSIGNED NOT NULL,
  self_score    DECIMAL(5,2),
  manager_score DECIMAL(5,2),
  final_score   DECIMAL(5,2),
  rating        VARCHAR(16),
  interview_notes TEXT,
  status        VARCHAR(16) NOT NULL DEFAULT 'pending',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_plan_emp (plan_id, employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 客户管理
-- ============================================================

CREATE TABLE IF NOT EXISTS customers (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_no     VARCHAR(32) NOT NULL UNIQUE,
  name            VARCHAR(255) NOT NULL,
  short_name      VARCHAR(64),
  type            VARCHAR(32) NOT NULL DEFAULT 'enterprise',
  industry        VARCHAR(64),
  region          VARCHAR(128),
  level           VARCHAR(16) NOT NULL DEFAULT 'normal',
  business_status TEXT,
  address         VARCHAR(500),
  website         VARCHAR(255),
  owner_id        BIGINT UNSIGNED NOT NULL,
  department_id   BIGINT UNSIGNED,
  status          VARCHAR(16) NOT NULL DEFAULT 'active',
  source          VARCHAR(32),
  security_level  TINYINT NOT NULL DEFAULT 0,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME,
  INDEX idx_owner (owner_id),
  INDEX idx_level (level),
  FULLTEXT KEY ft_name (name, short_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_contacts (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id     BIGINT UNSIGNED NOT NULL,
  name            VARCHAR(64) NOT NULL,
  title           VARCHAR(128),
  department      VARCHAR(128),
  influence_level VARCHAR(16),
  phone           VARCHAR(20),
  wechat          VARCHAR(64),
  email           VARCHAR(128),
  birthday        DATE,
  preferences     TEXT,
  family_info     TEXT,
  social_networks TEXT,
  taboos          TEXT,
  notes           TEXT,
  is_key          TINYINT NOT NULL DEFAULT 0,
  status          TINYINT NOT NULL DEFAULT 1,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME,
  INDEX idx_customer (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_relationships (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id     BIGINT UNSIGNED NOT NULL,
  contact_id      BIGINT UNSIGNED NOT NULL COMMENT '关联联系人',
  relation_type   VARCHAR(32) COMMENT 'decision/influence/guide/blocker',
  notes           TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_visits (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id      BIGINT UNSIGNED NOT NULL,
  visitor_id       BIGINT UNSIGNED NOT NULL,
  visit_date       DATETIME NOT NULL,
  location         VARCHAR(255),
  contact_ids      TEXT,
  objective        VARCHAR(500),
  content          TEXT,
  result           TEXT,
  next_action      VARCHAR(500),
  next_action_date DATE,
  stage            VARCHAR(32),
  has_opportunity  TINYINT NOT NULL DEFAULT 0,
  opportunity_id   BIGINT UNSIGNED,
  approval_id      BIGINT UNSIGNED,
  created_by       BIGINT UNSIGNED,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by       BIGINT UNSIGNED,
  updated_at       DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at       DATETIME,
  INDEX idx_customer_date (customer_id, visit_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_business_activities (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id   BIGINT UNSIGNED NOT NULL,
  type          VARCHAR(32) NOT NULL,
  purpose       TEXT,
  participants  TEXT COMMENT '参与联系人IDs（JSON）',
  expense       DECIMAL(14,2),
  compliance_ok TINYINT NOT NULL DEFAULT 1,
  approval_id   BIGINT UNSIGNED,
  effect        TEXT,
  next_action   VARCHAR(500),
  activity_date DATETIME NOT NULL,
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME,
  INDEX idx_customer (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_handover_records (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id     BIGINT UNSIGNED NOT NULL,
  from_owner_id   BIGINT UNSIGNED NOT NULL,
  to_owner_id     BIGINT UNSIGNED NOT NULL,
  reason          VARCHAR(255),
  key_contacts    TEXT,
  pending_items   TEXT,
  risks           TEXT,
  suggestions     TEXT,
  handover_at     DATETIME NOT NULL,
  confirmed_at    DATETIME,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS opportunities (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  opportunity_no   VARCHAR(32) NOT NULL UNIQUE,
  customer_id      BIGINT UNSIGNED NOT NULL,
  title            VARCHAR(255) NOT NULL,
  source           VARCHAR(32),
  stage            VARCHAR(32) NOT NULL DEFAULT 'lead',
  expected_amount  DECIMAL(14,2),
  win_rate         TINYINT NOT NULL DEFAULT 0,
  expected_close   DATE,
  owner_id         BIGINT UNSIGNED NOT NULL,
  department_id    BIGINT UNSIGNED,
  pain_point       TEXT,
  budget           DECIMAL(14,2),
  competitor       TEXT,
  lost_reason      VARCHAR(255),
  project_id       BIGINT UNSIGNED,
  contract_id      BIGINT UNSIGNED,
  status           VARCHAR(16) NOT NULL DEFAULT 'open',
  remark           TEXT,
  created_by       BIGINT UNSIGNED,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by       BIGINT UNSIGNED,
  updated_at       DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at       DATETIME,
  INDEX idx_customer (customer_id),
  INDEX idx_owner (owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 项目管理
-- ============================================================

CREATE TABLE IF NOT EXISTS projects (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  project_no      VARCHAR(32) NOT NULL UNIQUE,
  name            VARCHAR(255) NOT NULL,
  customer_id     BIGINT UNSIGNED,
  opportunity_id  BIGINT UNSIGNED,
  type            VARCHAR(32),
  owner_id        BIGINT UNSIGNED NOT NULL,
  department_id   BIGINT UNSIGNED,
  budget          DECIMAL(14,2),
  start_date      DATE,
  end_date        DATE,
  actual_end_date DATE,
  status          VARCHAR(16) NOT NULL DEFAULT 'draft',
  approval_status VARCHAR(16),
  approval_id     BIGINT UNSIGNED,
  security_level  TINYINT NOT NULL DEFAULT 0,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME,
  INDEX idx_customer (customer_id),
  INDEX idx_owner (owner_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS project_members (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  project_id  BIGINT UNSIGNED NOT NULL,
  user_id     BIGINT UNSIGNED NOT NULL,
  role        VARCHAR(32) COMMENT 'manager/member/viewer',
  joined_at   DATE,
  left_at     DATE,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_proj_user (project_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS project_tasks (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  project_id      BIGINT UNSIGNED NOT NULL,
  parent_task_id  BIGINT UNSIGNED,
  title           VARCHAR(255) NOT NULL,
  type            VARCHAR(16) DEFAULT 'task' COMMENT 'milestone/task',
  assignee_id     BIGINT UNSIGNED,
  plan_start      DATE,
  plan_end        DATE,
  actual_start    DATE,
  actual_end      DATE,
  progress        TINYINT NOT NULL DEFAULT 0,
  priority        TINYINT NOT NULL DEFAULT 0,
  status          VARCHAR(16) NOT NULL DEFAULT 'pending',
  predecessor_ids TEXT COMMENT '前置任务IDs（JSON）',
  description     TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME,
  INDEX idx_project (project_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS project_costs (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  project_id    BIGINT UNSIGNED NOT NULL,
  cost_type     VARCHAR(32) NOT NULL COMMENT 'reimburse/payment/material/labor/other',
  source_type   VARCHAR(32) NOT NULL COMMENT '来源业务类型',
  source_id     BIGINT UNSIGNED NOT NULL COMMENT '来源业务 ID',
  amount        DECIMAL(14,2) NOT NULL,
  occurred_at   DATE NOT NULL,
  description   VARCHAR(500),
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_project (project_id),
  INDEX idx_source (source_type, source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS project_documents (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  project_id      BIGINT UNSIGNED NOT NULL,
  title           VARCHAR(255) NOT NULL,
  doc_type        VARCHAR(32) COMMENT '文档类型（字典）',
  version         VARCHAR(32),
  attachment_id   BIGINT UNSIGNED,
  security_level  TINYINT NOT NULL DEFAULT 0,
  status          VARCHAR(16) NOT NULL DEFAULT 'draft',
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME,
  INDEX idx_project (project_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 合同管理
-- ============================================================

CREATE TABLE IF NOT EXISTS contract_templates (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(128) NOT NULL,
  type        VARCHAR(32) NOT NULL,
  content     LONGTEXT,
  status      TINYINT NOT NULL DEFAULT 1,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS contracts (
  id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  contract_no       VARCHAR(64) NOT NULL UNIQUE,
  title             VARCHAR(255) NOT NULL,
  type              VARCHAR(32) NOT NULL,
  counterparty_type VARCHAR(16),
  customer_id       BIGINT UNSIGNED,
  supplier_id       BIGINT UNSIGNED,
  employee_id       BIGINT UNSIGNED,
  project_id        BIGINT UNSIGNED,
  engineering_id    BIGINT UNSIGNED,
  amount            DECIMAL(14,2) NOT NULL,
  currency          VARCHAR(8) NOT NULL DEFAULT 'CNY',
  sign_date         DATE,
  start_date        DATE,
  end_date          DATE,
  payment_terms     TEXT,
  status            VARCHAR(16) NOT NULL DEFAULT 'draft',
  approval_status   VARCHAR(16),
  approval_id       BIGINT UNSIGNED,
  signed_by         BIGINT UNSIGNED,
  owner_id          BIGINT UNSIGNED NOT NULL,
  department_id     BIGINT UNSIGNED,
  security_level    TINYINT NOT NULL DEFAULT 0,
  remark            TEXT,
  created_by        BIGINT UNSIGNED,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by        BIGINT UNSIGNED,
  updated_at        DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at        DATETIME,
  INDEX idx_customer (customer_id),
  INDEX idx_supplier (supplier_id),
  INDEX idx_project (project_id),
  INDEX idx_end_date (end_date),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS contract_execution_records (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  contract_id    BIGINT UNSIGNED NOT NULL,
  record_type    VARCHAR(32) NOT NULL COMMENT 'milestone/payment/delivery/reminder',
  title          VARCHAR(255) NOT NULL,
  planned_at     DATE,
  actual_at      DATE,
  amount         DECIMAL(14,2),
  status         VARCHAR(16) NOT NULL DEFAULT 'pending',
  notes          TEXT,
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by     BIGINT UNSIGNED,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_contract (contract_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS contract_changes (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  contract_id   BIGINT UNSIGNED NOT NULL,
  change_type   VARCHAR(32) NOT NULL COMMENT 'amount/period/scope/terminate/renew',
  description   TEXT NOT NULL,
  old_value     TEXT,
  new_value     TEXT,
  approval_id   BIGINT UNSIGNED,
  status        VARCHAR(16) NOT NULL DEFAULT 'draft',
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME,
  INDEX idx_contract (contract_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 财务管理
-- ============================================================

CREATE TABLE IF NOT EXISTS reimbursements (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reimburse_no     VARCHAR(32) NOT NULL UNIQUE,
  applicant_id     BIGINT UNSIGNED NOT NULL,
  department_id    BIGINT UNSIGNED NOT NULL,
  project_id       BIGINT UNSIGNED,
  engineering_id   BIGINT UNSIGNED,
  expense_category VARCHAR(64) NOT NULL,
  total_amount     DECIMAL(14,2) NOT NULL,
  paid_amount      DECIMAL(14,2),
  invoice_count    TINYINT NOT NULL DEFAULT 0,
  description      TEXT NOT NULL,
  status           VARCHAR(16) NOT NULL DEFAULT 'draft',
  approval_status  VARCHAR(16),
  approval_id      BIGINT UNSIGNED,
  paid_at          DATETIME,
  paid_by          BIGINT UNSIGNED,
  remark           TEXT,
  created_by       BIGINT UNSIGNED,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by       BIGINT UNSIGNED,
  updated_at       DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at       DATETIME,
  INDEX idx_applicant (applicant_id),
  INDEX idx_project (project_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS reimbursement_invoices (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reimbursement_id BIGINT UNSIGNED NOT NULL,
  invoice_type     VARCHAR(32),
  invoice_no       VARCHAR(64),
  invoice_code     VARCHAR(32),
  invoice_date     DATE,
  seller_name      VARCHAR(255),
  amount           DECIMAL(14,2) NOT NULL,
  tax_amount       DECIMAL(14,2),
  total_amount     DECIMAL(14,2) NOT NULL,
  attachment_id    BIGINT UNSIGNED,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_reimbursement (reimbursement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS payment_requests (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  pay_no          VARCHAR(32) NOT NULL UNIQUE,
  applicant_id    BIGINT UNSIGNED NOT NULL,
  department_id   BIGINT UNSIGNED NOT NULL,
  pay_type        VARCHAR(32) NOT NULL,
  contract_id     BIGINT UNSIGNED,
  supplier_id     BIGINT UNSIGNED,
  payee_name      VARCHAR(255) NOT NULL,
  payee_bank      VARCHAR(255),
  payee_account   VARCHAR(64),
  amount          DECIMAL(14,2) NOT NULL,
  purpose         TEXT NOT NULL,
  status          VARCHAR(16) NOT NULL DEFAULT 'draft',
  approval_status VARCHAR(16),
  approval_id     BIGINT UNSIGNED,
  paid_at         DATETIME,
  paid_by         BIGINT UNSIGNED,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME,
  INDEX idx_applicant (applicant_id),
  INDEX idx_supplier (supplier_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS loan_requests (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  loan_no         VARCHAR(32) NOT NULL UNIQUE,
  applicant_id    BIGINT UNSIGNED NOT NULL,
  department_id   BIGINT UNSIGNED NOT NULL,
  amount          DECIMAL(14,2) NOT NULL,
  purpose         TEXT NOT NULL,
  expected_repay  DATE COMMENT '预计还款日期',
  status          VARCHAR(16) NOT NULL DEFAULT 'draft',
  approval_id     BIGINT UNSIGNED,
  balance         DECIMAL(14,2) COMMENT '未还余额',
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS repayment_records (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  loan_id     BIGINT UNSIGNED NOT NULL,
  amount      DECIMAL(14,2) NOT NULL,
  repay_date  DATE NOT NULL,
  confirmed_by BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS receivables (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  contract_id     BIGINT UNSIGNED NOT NULL,
  customer_id     BIGINT UNSIGNED NOT NULL,
  project_id      BIGINT UNSIGNED,
  receivable_no   VARCHAR(32) NOT NULL UNIQUE,
  amount          DECIMAL(14,2) NOT NULL,
  received_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
  due_date        DATE NOT NULL,
  invoice_no      VARCHAR(128),
  status          VARCHAR(16) NOT NULL DEFAULT 'pending',
  overdue_days    INT NOT NULL DEFAULT 0,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME,
  INDEX idx_contract (contract_id),
  INDEX idx_due_date (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS budgets (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  budget_no      VARCHAR(32) NOT NULL UNIQUE,
  subject_type   VARCHAR(16) NOT NULL,
  project_id     BIGINT UNSIGNED,
  department_id  BIGINT UNSIGNED,
  year           SMALLINT,
  period         VARCHAR(7),
  category       VARCHAR(64),
  budget_amount  DECIMAL(14,2) NOT NULL,
  used_amount    DECIMAL(14,2) NOT NULL DEFAULT 0,
  status         VARCHAR(16) NOT NULL DEFAULT 'active',
  approved_by    BIGINT UNSIGNED,
  approved_at    DATETIME,
  remark         TEXT,
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by     BIGINT UNSIGNED,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at     DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 运维管理
-- ============================================================

CREATE TABLE IF NOT EXISTS devices (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  device_no      VARCHAR(64) NOT NULL UNIQUE,
  name           VARCHAR(255) NOT NULL,
  category       VARCHAR(64),
  brand          VARCHAR(128),
  model          VARCHAR(128),
  serial_no      VARCHAR(128),
  supplier_id    BIGINT UNSIGNED,
  purchase_date  DATE,
  warranty_end   DATE,
  location       VARCHAR(255),
  owner_dept_id  BIGINT UNSIGNED,
  responsible_id BIGINT UNSIGNED,
  contract_id    BIGINT UNSIGNED,
  status         VARCHAR(16) NOT NULL DEFAULT 'normal',
  security_level TINYINT NOT NULL DEFAULT 0,
  remark         TEXT,
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by     BIGINT UNSIGNED,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at     DATETIME,
  INDEX idx_dept (owner_dept_id),
  INDEX idx_warranty (warranty_end)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ops_sla_rules (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name             VARCHAR(128) NOT NULL,
  work_order_type  VARCHAR(32),
  priority         TINYINT,
  response_hours   INT NOT NULL COMMENT '响应时限（小时）',
  resolve_hours    INT NOT NULL COMMENT '解决时限（小时）',
  penalty_rule     TEXT COMMENT '超时扣罚规则',
  status           TINYINT NOT NULL DEFAULT 1,
  created_by       BIGINT UNSIGNED,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by       BIGINT UNSIGNED,
  updated_at       DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at       DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ops_knowledge_base (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title        VARCHAR(255) NOT NULL,
  symptom      TEXT NOT NULL COMMENT '故障现象',
  root_cause   TEXT COMMENT '根本原因',
  solution     TEXT NOT NULL COMMENT '处理步骤',
  device_types TEXT COMMENT '适用设备类型',
  tags         VARCHAR(500),
  view_count   INT NOT NULL DEFAULT 0,
  helpful_count INT NOT NULL DEFAULT 0,
  status       TINYINT NOT NULL DEFAULT 1,
  created_by   BIGINT UNSIGNED,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by   BIGINT UNSIGNED,
  updated_at   DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME,
  FULLTEXT KEY ft_content (title, symptom, solution)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS inspection_records (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  device_id      BIGINT UNSIGNED NOT NULL,
  inspector_id   BIGINT UNSIGNED NOT NULL,
  inspect_date   DATETIME NOT NULL,
  result         VARCHAR(16) NOT NULL COMMENT 'normal/abnormal',
  anomaly_desc   TEXT,
  photos         TEXT COMMENT '照片附件IDs（JSON）',
  work_order_id  BIGINT UNSIGNED COMMENT '产生的工单',
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_device (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS work_orders (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_no         VARCHAR(32) NOT NULL UNIQUE,
  type             VARCHAR(32) NOT NULL,
  source           VARCHAR(32) NOT NULL,
  device_id        BIGINT UNSIGNED,
  customer_id      BIGINT UNSIGNED,
  project_id       BIGINT UNSIGNED,
  title            VARCHAR(255) NOT NULL,
  description      TEXT NOT NULL,
  priority         TINYINT NOT NULL DEFAULT 0,
  sla_rule_id      BIGINT UNSIGNED,
  response_deadline DATETIME,
  resolve_deadline  DATETIME,
  responded_at     DATETIME,
  resolved_at      DATETIME,
  assignee_team_id BIGINT UNSIGNED,
  assignee_id      BIGINT UNSIGNED,
  handler_id       BIGINT UNSIGNED,
  resolution       TEXT,
  root_cause       TEXT,
  parts_used       TEXT,
  knowledge_id     BIGINT UNSIGNED,
  status           VARCHAR(16) NOT NULL DEFAULT 'pending',
  close_comment    VARCHAR(500),
  closed_by        BIGINT UNSIGNED,
  closed_at        DATETIME,
  satisfaction     TINYINT,
  department_id    BIGINT UNSIGNED,
  remark           TEXT,
  created_by       BIGINT UNSIGNED,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by       BIGINT UNSIGNED,
  updated_at       DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at       DATETIME,
  INDEX idx_status (status),
  INDEX idx_assignee (assignee_id),
  INDEX idx_device (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS safety_events (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  event_no      VARCHAR(32) NOT NULL UNIQUE,
  type          VARCHAR(32) NOT NULL COMMENT 'hidden/accident/special',
  level         VARCHAR(16) NOT NULL COMMENT 'minor/moderate/serious/critical',
  location      VARCHAR(255),
  occurred_at   DATETIME NOT NULL,
  description   TEXT NOT NULL,
  affected_range TEXT,
  handler_id    BIGINT UNSIGNED NOT NULL,
  resolution    TEXT,
  lessons       TEXT,
  status        VARCHAR(16) NOT NULL DEFAULT 'open',
  closed_at     DATETIME,
  department_id BIGINT UNSIGNED,
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 工程管理
-- ============================================================

CREATE TABLE IF NOT EXISTS engineering_items (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  eng_no          VARCHAR(32) NOT NULL UNIQUE,
  name            VARCHAR(255) NOT NULL,
  type            VARCHAR(16) NOT NULL DEFAULT 'project',
  project_id      BIGINT UNSIGNED,
  customer_id     BIGINT UNSIGNED,
  contract_id     BIGINT UNSIGNED,
  owner_id        BIGINT UNSIGNED NOT NULL,
  department_id   BIGINT UNSIGNED,
  plan_start      DATE,
  plan_end        DATE,
  actual_start    DATE,
  actual_end      DATE,
  scope           TEXT,
  budget          DECIMAL(14,2),
  status          VARCHAR(16) NOT NULL DEFAULT 'draft',
  approval_id     BIGINT UNSIGNED,
  progress        TINYINT NOT NULL DEFAULT 0,
  security_level  TINYINT NOT NULL DEFAULT 0,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME,
  INDEX idx_project (project_id),
  INDEX idx_owner (owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS engineering_plans (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id BIGINT UNSIGNED NOT NULL,
  scope          TEXT,
  milestones     JSON COMMENT '节点计划（JSON）',
  team_ids       TEXT COMMENT '协作团队IDs（JSON）',
  material_needs TEXT COMMENT '材料需求（JSON）',
  risk_notes     TEXT,
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by     BIGINT UNSIGNED,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS engineering_logs (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id BIGINT UNSIGNED NOT NULL,
  log_date       DATE NOT NULL,
  weather        VARCHAR(32),
  workers        TINYINT,
  content        TEXT NOT NULL,
  materials_used TEXT,
  issues         TEXT,
  next_plan      TEXT,
  photos         TEXT,
  reporter_id    BIGINT UNSIGNED NOT NULL,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_eng_date (engineering_id, log_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS engineering_log_shares (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  share_no        VARCHAR(32) NOT NULL UNIQUE,
  token_hash      VARCHAR(255) NOT NULL,
  share_title     VARCHAR(255),
  date_from       DATE,
  date_to         DATE,
  viewer_name     VARCHAR(128),
  viewer_org      VARCHAR(255),
  viewer_phone    VARCHAR(20),
  include_photos  TINYINT NOT NULL DEFAULT 1,
  include_materials TINYINT NOT NULL DEFAULT 0,
  include_issues  TINYINT NOT NULL DEFAULT 1,
  allow_download  TINYINT NOT NULL DEFAULT 0,
  mask_workers    TINYINT NOT NULL DEFAULT 1,
  security_level  TINYINT NOT NULL DEFAULT 0,
  expired_at      DATETIME NOT NULL,
  revoked_at      DATETIME,
  revoked_by      BIGINT UNSIGNED,
  status          VARCHAR(16) NOT NULL DEFAULT 'active',
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_token_hash (token_hash),
  INDEX idx_engineering (engineering_id),
  INDEX idx_status_expired (status, expired_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS engineering_log_share_access_logs (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  share_id        BIGINT UNSIGNED NOT NULL,
  action          VARCHAR(32) NOT NULL,
  ip              VARCHAR(64) NOT NULL,
  user_agent      VARCHAR(500),
  request_path    VARCHAR(500),
  result          TINYINT NOT NULL DEFAULT 1,
  deny_reason     VARCHAR(255),
  accessed_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_share_time (share_id, accessed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS engineering_team_members (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  team_id         BIGINT UNSIGNED,
  member_id       BIGINT UNSIGNED,
  employee_id     BIGINT UNSIGNED,
  role            VARCHAR(32) NOT NULL,
  skill_tags      TEXT,
  entry_status    VARCHAR(16) NOT NULL DEFAULT 'pending',
  entered_at      DATETIME,
  exited_at       DATETIME,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_eng_member (engineering_id, member_id, employee_id),
  INDEX idx_eng (engineering_id),
  INDEX idx_team (team_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS engineering_site_entries (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  entry_date      DATETIME NOT NULL,
  member_ids      TEXT,
  site_condition  TEXT,
  safety_briefing TINYINT NOT NULL DEFAULT 0,
  customer_confirm_user VARCHAR(128),
  photo_ids       TEXT,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_eng (engineering_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS engineering_quality_issues (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  issue_no        VARCHAR(32) NOT NULL UNIQUE,
  issue_type      VARCHAR(32) NOT NULL,
  severity        VARCHAR(16) NOT NULL,
  description     TEXT NOT NULL,
  responsible_id  BIGINT UNSIGNED,
  deadline        DATE,
  rectification   TEXT,
  review_result   VARCHAR(16),
  reviewer_id     BIGINT UNSIGNED,
  reviewed_at     DATETIME,
  status          VARCHAR(16) NOT NULL DEFAULT 'open',
  photo_ids       TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_eng_status (engineering_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS engineering_hidden_acceptance (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  stage_name      VARCHAR(128) NOT NULL,
  check_items     JSON NOT NULL,
  result          VARCHAR(16) NOT NULL,
  acceptor_ids    TEXT,
  photo_ids       TEXT,
  issues          TEXT,
  rectification_required TINYINT NOT NULL DEFAULT 0,
  reviewed_at     DATETIME,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_eng (engineering_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS engineering_material_records (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id BIGINT UNSIGNED NOT NULL,
  material_id    BIGINT UNSIGNED NOT NULL,
  qty_requested  DECIMAL(14,4) NOT NULL,
  qty_received   DECIMAL(14,4),
  qty_used       DECIMAL(14,4),
  request_at     DATE,
  received_at    DATE,
  remark         VARCHAR(500),
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS engineering_change_orders (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id BIGINT UNSIGNED NOT NULL,
  change_no      VARCHAR(32) NOT NULL UNIQUE,
  type           VARCHAR(32) NOT NULL,
  reason         TEXT NOT NULL,
  content        TEXT NOT NULL,
  cost_impact    DECIMAL(14,2),
  days_impact    INT,
  status         VARCHAR(16) NOT NULL DEFAULT 'draft',
  approval_id    BIGINT UNSIGNED,
  approved_at    DATETIME,
  approved_by    BIGINT UNSIGNED,
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by     BIGINT UNSIGNED,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at     DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS engineering_settlements (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  settlement_no   VARCHAR(32) NOT NULL UNIQUE,
  workload_items  JSON,
  material_cost   DECIMAL(14,2) NOT NULL DEFAULT 0,
  team_cost       DECIMAL(14,2) NOT NULL DEFAULT 0,
  change_amount   DECIMAL(14,2) NOT NULL DEFAULT 0,
  other_amount    DECIMAL(14,2) NOT NULL DEFAULT 0,
  total_amount    DECIMAL(14,2) NOT NULL,
  status          VARCHAR(16) NOT NULL DEFAULT 'draft',
  approval_id     BIGINT UNSIGNED,
  payment_req_id  BIGINT UNSIGNED,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME,
  INDEX idx_eng (engineering_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS acceptance_records (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  type            VARCHAR(16) NOT NULL DEFAULT 'final' COMMENT 'interim/final',
  result          VARCHAR(16) NOT NULL COMMENT 'pass/conditional/fail',
  issues          TEXT,
  corrective_actions TEXT,
  accepted_by     BIGINT UNSIGNED,
  accepted_at     DATETIME,
  training_plan_id BIGINT UNSIGNED,
  archived_at     DATETIME,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 协作团队
-- ============================================================

CREATE TABLE IF NOT EXISTS collaboration_teams (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  team_no       VARCHAR(32) NOT NULL UNIQUE,
  name          VARCHAR(255) NOT NULL,
  type          VARCHAR(16) NOT NULL,
  service_scope TEXT,
  region        VARCHAR(128),
  leader_id     BIGINT UNSIGNED,
  fee_standard  TEXT,
  status        VARCHAR(16) NOT NULL DEFAULT 'active',
  level         VARCHAR(16) NOT NULL DEFAULT 'C',
  remark        TEXT,
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS collaboration_members (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  team_id      BIGINT UNSIGNED NOT NULL,
  member_type  VARCHAR(16) NOT NULL COMMENT 'internal/external/contracted',
  employee_id  BIGINT UNSIGNED COMMENT 'internal时关联员工',
  name         VARCHAR(64),
  phone        VARCHAR(20),
  id_card      VARCHAR(64),
  skills       TEXT COMMENT '技能标签（JSON）',
  status       TINYINT NOT NULL DEFAULT 1,
  created_by   BIGINT UNSIGNED,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by   BIGINT UNSIGNED,
  updated_at   DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME,
  INDEX idx_team (team_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS collaboration_companies (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(255) NOT NULL,
  credit_code  VARCHAR(64) COMMENT '统一社会信用代码',
  contact_name VARCHAR(64),
  contact_phone VARCHAR(20),
  service_type TEXT COMMENT '服务类型',
  address      VARCHAR(500),
  status       TINYINT NOT NULL DEFAULT 1,
  created_by   BIGINT UNSIGNED,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by   BIGINT UNSIGNED,
  updated_at   DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS collaboration_qualifications (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  team_id       BIGINT UNSIGNED,
  member_id     BIGINT UNSIGNED,
  company_id    BIGINT UNSIGNED,
  cert_type     VARCHAR(64) NOT NULL COMMENT '资质类型（字典）',
  cert_no       VARCHAR(128),
  issuer        VARCHAR(255),
  issued_date   DATE,
  expiry_date   DATE,
  attachment_id BIGINT UNSIGNED,
  status        VARCHAR(16) NOT NULL DEFAULT 'valid',
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS collaboration_assignments (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  team_id         BIGINT UNSIGNED NOT NULL,
  source_type     VARCHAR(32) NOT NULL COMMENT '来源：project/engineering/work_order/opportunity',
  source_id       BIGINT UNSIGNED NOT NULL,
  task_type       VARCHAR(32) COMMENT '任务类型',
  task_desc       TEXT,
  member_ids      TEXT COMMENT '派工人员IDs（JSON）',
  plan_start      DATE,
  plan_end        DATE,
  actual_start    DATE,
  actual_end      DATE,
  status          VARCHAR(16) NOT NULL DEFAULT 'assigned',
  approval_id     BIGINT UNSIGNED,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME,
  INDEX idx_source (source_type, source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS collaboration_execution_records (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  assignment_id  BIGINT UNSIGNED NOT NULL,
  recorder_id    BIGINT UNSIGNED NOT NULL,
  record_date    DATE NOT NULL,
  content        TEXT NOT NULL,
  work_hours     DECIMAL(5,2),
  work_qty       DECIMAL(14,4),
  photos         TEXT,
  issues         TEXT,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS collaboration_evaluations (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  assignment_id   BIGINT UNSIGNED NOT NULL,
  team_id         BIGINT UNSIGNED NOT NULL,
  quality_score   DECIMAL(3,1),
  timeliness_score DECIMAL(3,1),
  safety_score    DECIMAL(3,1),
  overall_score   DECIMAL(3,1),
  feedback        TEXT,
  eval_by         BIGINT UNSIGNED NOT NULL,
  eval_at         DATETIME NOT NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS collaboration_settlements (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  assignment_id   BIGINT UNSIGNED NOT NULL,
  team_id         BIGINT UNSIGNED NOT NULL,
  settlement_no   VARCHAR(32) NOT NULL UNIQUE,
  basis           TEXT COMMENT '结算依据',
  amount          DECIMAL(14,2) NOT NULL,
  status          VARCHAR(16) NOT NULL DEFAULT 'draft',
  approval_id     BIGINT UNSIGNED,
  payment_req_id  BIGINT UNSIGNED COMMENT '关联付款申请',
  contract_id     BIGINT UNSIGNED,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 供应链采购
-- ============================================================

CREATE TABLE IF NOT EXISTS suppliers (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  supplier_no    VARCHAR(32) NOT NULL UNIQUE,
  name           VARCHAR(255) NOT NULL,
  short_name     VARCHAR(64),
  category       VARCHAR(64),
  credit_code    VARCHAR(64),
  contact_name   VARCHAR(64),
  contact_phone  VARCHAR(20),
  contact_email  VARCHAR(128),
  address        VARCHAR(500),
  bank_name      VARCHAR(255),
  bank_account   VARCHAR(64),
  tax_no         VARCHAR(64),
  level          VARCHAR(16) NOT NULL DEFAULT 'C',
  status         VARCHAR(16) NOT NULL DEFAULT 'pending',
  onboard_date   DATE,
  expiry_date    DATE,
  remark         TEXT,
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by     BIGINT UNSIGNED,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at     DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS supplier_accounts (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  supplier_id  BIGINT UNSIGNED NOT NULL UNIQUE,
  user_id      BIGINT UNSIGNED NOT NULL UNIQUE COMMENT '关联系统账号',
  status       TINYINT NOT NULL DEFAULT 1,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS supplier_products (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  supplier_id   BIGINT UNSIGNED NOT NULL,
  material_id   BIGINT UNSIGNED,
  name          VARCHAR(255) NOT NULL,
  spec          VARCHAR(255),
  unit          VARCHAR(16) NOT NULL,
  list_price    DECIMAL(14,2),
  min_order_qty DECIMAL(14,4),
  lead_time_days INT,
  status        TINYINT NOT NULL DEFAULT 1,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_supplier (supplier_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS supplier_onboarding_requests (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  supplier_name VARCHAR(255) NOT NULL,
  credit_code   VARCHAR(64),
  contact_name  VARCHAR(64),
  contact_phone VARCHAR(20),
  contact_email VARCHAR(128),
  description   TEXT,
  source        VARCHAR(16) NOT NULL COMMENT 'self/admin',
  status        VARCHAR(16) NOT NULL DEFAULT 'pending',
  approval_id   BIGINT UNSIGNED,
  supplier_id   BIGINT UNSIGNED COMMENT '审核通过后创建的供应商',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS purchase_inquiries (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  inquiry_no      VARCHAR(32) NOT NULL UNIQUE,
  source_type     VARCHAR(32) NOT NULL COMMENT '来源：material_request/project/work_order',
  source_id       BIGINT UNSIGNED,
  project_id      BIGINT UNSIGNED,
  items           JSON NOT NULL COMMENT '询价物料列表（JSON）',
  supplier_ids    TEXT COMMENT '邀请供应商IDs（JSON）',
  deadline        DATETIME NOT NULL COMMENT '报价截止时间',
  delivery_addr   VARCHAR(500),
  expected_date   DATE,
  status          VARCHAR(16) NOT NULL DEFAULT 'open' COMMENT 'open/closed/cancelled',
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS supplier_quotations (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  inquiry_id  BIGINT UNSIGNED NOT NULL,
  supplier_id BIGINT UNSIGNED NOT NULL,
  items       JSON NOT NULL COMMENT '报价明细（JSON）',
  total_price DECIMAL(14,2),
  tax_rate    DECIMAL(5,2),
  freight     DECIMAL(14,2),
  lead_days   INT,
  valid_until DATE,
  notes       TEXT,
  status      VARCHAR(16) NOT NULL DEFAULT 'submitted',
  submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_inquiry_supplier (inquiry_id, supplier_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS quotation_compare_lists (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  inquiry_id    BIGINT UNSIGNED NOT NULL,
  compare_rule  VARCHAR(32) NOT NULL DEFAULT 'lowest_price' COMMENT '比价规则',
  result_items  JSON NOT NULL COMMENT '比价结果（JSON，含推荐供应商）',
  snapshot      JSON COMMENT '报价快照，防止供应商修改后影响历史记录',
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS purchase_orders (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_no         VARCHAR(32) NOT NULL UNIQUE,
  inquiry_id       BIGINT UNSIGNED,
  compare_id       BIGINT UNSIGNED,
  supplier_id      BIGINT UNSIGNED NOT NULL,
  project_id       BIGINT UNSIGNED,
  total_amount     DECIMAL(14,2) NOT NULL,
  status           VARCHAR(16) NOT NULL DEFAULT 'draft',
  approval_id      BIGINT UNSIGNED,
  delivery_address VARCHAR(500) NOT NULL,
  expected_date    DATE,
  actual_date      DATE,
  notify_at        DATETIME,
  confirmed_at     DATETIME,
  remark           TEXT,
  created_by       BIGINT UNSIGNED,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by       BIGINT UNSIGNED,
  updated_at       DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at       DATETIME,
  INDEX idx_supplier (supplier_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS purchase_order_items (
  id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  purchase_order_id BIGINT UNSIGNED NOT NULL,
  supplier_id       BIGINT UNSIGNED NOT NULL,
  product_id        BIGINT UNSIGNED COMMENT '供应商商品 ID',
  material_id       BIGINT UNSIGNED COMMENT '平台物料 ID',
  name              VARCHAR(255) NOT NULL,
  spec              VARCHAR(255),
  unit              VARCHAR(16) NOT NULL,
  qty               DECIMAL(14,4) NOT NULL,
  unit_price        DECIMAL(14,2) NOT NULL,
  amount            DECIMAL(14,2) NOT NULL,
  quotation_id      BIGINT UNSIGNED,
  INDEX idx_order (purchase_order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS supplier_performance_records (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  supplier_id     BIGINT UNSIGNED NOT NULL,
  purchase_order_id BIGINT UNSIGNED NOT NULL,
  on_time_rate    DECIMAL(5,2) COMMENT '准时率',
  quality_pass    DECIMAL(5,2) COMMENT '合格率',
  price_deviation DECIMAL(5,2) COMMENT '价格偏差率',
  service_score   DECIMAL(3,1) COMMENT '服务评分1-5',
  breach_count    TINYINT NOT NULL DEFAULT 0 COMMENT '违约次数',
  notes           TEXT,
  eval_by         BIGINT UNSIGNED,
  eval_at         DATETIME,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 库存管理
-- ============================================================

CREATE TABLE IF NOT EXISTS materials (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  material_no  VARCHAR(64) NOT NULL UNIQUE,
  name         VARCHAR(255) NOT NULL,
  category     VARCHAR(64),
  spec         VARCHAR(255),
  unit         VARCHAR(16) NOT NULL,
  brand        VARCHAR(128),
  min_stock    DECIMAL(14,4),
  max_stock    DECIMAL(14,4),
  ref_price    DECIMAL(14,2),
  status       TINYINT NOT NULL DEFAULT 1,
  remark       TEXT,
  created_by   BIGINT UNSIGNED,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by   BIGINT UNSIGNED,
  updated_at   DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS warehouses (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(128) NOT NULL,
  code        VARCHAR(32) NOT NULL UNIQUE,
  address     VARCHAR(500),
  manager_id  BIGINT UNSIGNED,
  type        VARCHAR(16) NOT NULL DEFAULT 'main',
  status      TINYINT NOT NULL DEFAULT 1,
  remark      TEXT,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS material_requests (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  request_no     VARCHAR(32) NOT NULL UNIQUE,
  source_type    VARCHAR(32) NOT NULL COMMENT 'project/engineering/work_order',
  source_id      BIGINT UNSIGNED NOT NULL,
  project_id     BIGINT UNSIGNED,
  items          JSON NOT NULL COMMENT '申请物料列表（JSON）',
  status         VARCHAR(16) NOT NULL DEFAULT 'pending',
  approval_id    BIGINT UNSIGNED,
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by     BIGINT UNSIGNED,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at     DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS inventory_records (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  material_id    BIGINT UNSIGNED NOT NULL,
  warehouse_id   BIGINT UNSIGNED NOT NULL,
  direction      TINYINT NOT NULL COMMENT '1入库 -1出库',
  qty            DECIMAL(14,4) NOT NULL,
  unit_price     DECIMAL(14,2),
  amount         DECIMAL(14,2),
  source_type    VARCHAR(32) NOT NULL,
  source_id      BIGINT UNSIGNED,
  project_id     BIGINT UNSIGNED,
  engineering_id BIGINT UNSIGNED,
  work_order_id  BIGINT UNSIGNED,
  batch_no       VARCHAR(64),
  operator_id    BIGINT UNSIGNED NOT NULL,
  approved_by    BIGINT UNSIGNED,
  remark         VARCHAR(500),
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_material_wh (material_id, warehouse_id),
  INDEX idx_source (source_type, source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 培训管理
-- ============================================================

CREATE TABLE IF NOT EXISTS training_courses (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title           VARCHAR(255) NOT NULL,
  category        VARCHAR(64),
  course_type     VARCHAR(16) NOT NULL DEFAULT 'video',
  cover_image     VARCHAR(500),
  description     TEXT,
  duration_mins   INT,
  instructor      VARCHAR(128),
  difficulty      TINYINT NOT NULL DEFAULT 1,
  is_required     TINYINT NOT NULL DEFAULT 0,
  pass_score      TINYINT NOT NULL DEFAULT 60,
  target_audience TEXT,
  status          VARCHAR(16) NOT NULL DEFAULT 'draft',
  security_level  TINYINT NOT NULL DEFAULT 0,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS training_plans (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title         VARCHAR(255) NOT NULL,
  course_ids    TEXT COMMENT '课程IDs（JSON）',
  target_type   VARCHAR(16) NOT NULL COMMENT 'all/dept/role/custom',
  target_ids    TEXT,
  start_date    DATE,
  end_date      DATE,
  is_required   TINYINT NOT NULL DEFAULT 0,
  status        VARCHAR(16) NOT NULL DEFAULT 'draft',
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS exams (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  course_id    BIGINT UNSIGNED NOT NULL,
  title        VARCHAR(255) NOT NULL,
  questions    JSON NOT NULL COMMENT '题目内容（JSON）',
  duration_mins INT NOT NULL DEFAULT 60,
  pass_score   TINYINT NOT NULL DEFAULT 60,
  max_attempts TINYINT NOT NULL DEFAULT 3,
  status       TINYINT NOT NULL DEFAULT 1,
  created_by   BIGINT UNSIGNED,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by   BIGINT UNSIGNED,
  updated_at   DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS training_records (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  plan_id         BIGINT UNSIGNED,
  course_id       BIGINT UNSIGNED NOT NULL,
  learner_id      BIGINT UNSIGNED NOT NULL,
  progress        TINYINT NOT NULL DEFAULT 0,
  study_duration  INT NOT NULL DEFAULT 0,
  exam_score      DECIMAL(5,2),
  is_passed       TINYINT NOT NULL DEFAULT 0,
  passed_at       DATETIME,
  certificate_no  VARCHAR(128),
  certificate_url VARCHAR(500),
  cert_issued_at  DATETIME,
  cert_expiry     DATE,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_plan_course_learner (plan_id, course_id, learner_id),
  INDEX idx_learner (learner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 通知公告
-- ============================================================

CREATE TABLE IF NOT EXISTS notices (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  type             VARCHAR(32) NOT NULL,
  title            VARCHAR(255) NOT NULL,
  content          LONGTEXT NOT NULL,
  summary          VARCHAR(500),
  cover_image      VARCHAR(500),
  priority         TINYINT NOT NULL DEFAULT 0,
  target_type      VARCHAR(16) NOT NULL DEFAULT 'all',
  target_ids       TEXT,
  publish_at       DATETIME,
  expire_at        DATETIME,
  is_require_read  TINYINT NOT NULL DEFAULT 0,
  is_need_feedback TINYINT NOT NULL DEFAULT 0,
  status           VARCHAR(16) NOT NULL DEFAULT 'draft',
  publisher_id     BIGINT UNSIGNED NOT NULL,
  department_id    BIGINT UNSIGNED,
  security_level   TINYINT NOT NULL DEFAULT 0,
  read_count       INT NOT NULL DEFAULT 0,
  created_by       BIGINT UNSIGNED,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by       BIGINT UNSIGNED,
  updated_at       DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at       DATETIME,
  INDEX idx_status (status),
  INDEX idx_publish (publish_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notice_reads (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  notice_id   BIGINT UNSIGNED NOT NULL,
  user_id     BIGINT UNSIGNED NOT NULL,
  read_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  feedback    TEXT,
  UNIQUE KEY uk_notice_user (notice_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 党建管理
-- ============================================================

CREATE TABLE IF NOT EXISTS party_organizations (
  id                   BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name                 VARCHAR(128) NOT NULL,
  type                 VARCHAR(16) NOT NULL,
  parent_id            BIGINT UNSIGNED NOT NULL DEFAULT 0,
  secretary_id         BIGINT UNSIGNED,
  deputy_secretary_id  BIGINT UNSIGNED,
  member_count         INT NOT NULL DEFAULT 0,
  established_date     DATE,
  next_election        DATE,
  status               TINYINT NOT NULL DEFAULT 1,
  remark               TEXT,
  created_by           BIGINT UNSIGNED,
  created_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by           BIGINT UNSIGNED,
  updated_at           DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at           DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS party_branches (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  org_id       BIGINT UNSIGNED NOT NULL COMMENT '关联 party_organizations',
  department_id BIGINT UNSIGNED COMMENT '对应行政部门',
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS party_members (
  id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  employee_id       BIGINT UNSIGNED NOT NULL UNIQUE,
  party_org_id      BIGINT UNSIGNED NOT NULL,
  inner_title       VARCHAR(64),
  join_apply_date   DATE,
  probation_date    DATE,
  full_date         DATE,
  member_type       VARCHAR(16) NOT NULL DEFAULT 'full',
  dues_standard     DECIMAL(14,2),
  status            VARCHAR(16) NOT NULL DEFAULT 'active',
  transfer_out_at   DATE,
  remark            TEXT,
  created_by        BIGINT UNSIGNED,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by        BIGINT UNSIGNED,
  updated_at        DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at        DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS party_member_developments (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  employee_id     BIGINT UNSIGNED NOT NULL,
  party_org_id    BIGINT UNSIGNED NOT NULL,
  stage           VARCHAR(16) NOT NULL COMMENT 'applicant/activist/candidate/probation/full',
  stage_date      DATE NOT NULL COMMENT '进入该阶段日期',
  notes           TEXT,
  trainer_id      BIGINT UNSIGNED COMMENT '培养联系人',
  meeting_record  TEXT,
  approval_id     BIGINT UNSIGNED,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_employee (employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS party_meetings (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  party_org_id BIGINT UNSIGNED NOT NULL,
  type         VARCHAR(32) NOT NULL COMMENT '会议类型（字典）',
  title        VARCHAR(255) NOT NULL,
  meeting_date DATETIME NOT NULL,
  location     VARCHAR(255),
  agenda       TEXT,
  minutes      TEXT COMMENT '会议纪要',
  attendees    TEXT COMMENT '参会人IDs（JSON）',
  photos       TEXT COMMENT '照片附件IDs（JSON）',
  status       VARCHAR(16) NOT NULL DEFAULT 'planned',
  created_by   BIGINT UNSIGNED,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by   BIGINT UNSIGNED,
  updated_at   DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS party_activities (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  party_org_id BIGINT UNSIGNED NOT NULL,
  title        VARCHAR(255) NOT NULL,
  theme        VARCHAR(255) COMMENT '主题',
  activity_date DATETIME NOT NULL,
  location     VARCHAR(255),
  description  TEXT,
  signins      TEXT COMMENT '签到人IDs（JSON）',
  photos       TEXT,
  summary      TEXT,
  status       VARCHAR(16) NOT NULL DEFAULT 'planned',
  created_by   BIGINT UNSIGNED,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by   BIGINT UNSIGNED,
  updated_at   DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS party_dues (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  party_member_id BIGINT UNSIGNED NOT NULL,
  party_org_id    BIGINT UNSIGNED NOT NULL,
  period          VARCHAR(7) NOT NULL,
  due_amount      DECIMAL(14,2) NOT NULL,
  paid_amount     DECIMAL(14,2) NOT NULL DEFAULT 0,
  pay_date        DATE,
  status          VARCHAR(16) NOT NULL DEFAULT 'pending',
  collector_id    BIGINT UNSIGNED,
  remark          VARCHAR(500),
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_member_period (party_member_id, period)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS party_evaluations (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  party_org_id    BIGINT UNSIGNED NOT NULL,
  period          VARCHAR(7) NOT NULL COMMENT '考核周期',
  member_id       BIGINT UNSIGNED NOT NULL,
  self_review     TEXT,
  peer_reviews    JSON COMMENT '党员互评',
  org_conclusion  TEXT COMMENT '组织评定意见',
  rating          VARCHAR(16) COMMENT '评定等级',
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_period_member (period, member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS party_ledgers (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  party_org_id   BIGINT UNSIGNED NOT NULL,
  type           VARCHAR(32) NOT NULL COMMENT 'rule/minutes/activity/study/other',
  title          VARCHAR(255) NOT NULL,
  content        TEXT,
  attachment_ids TEXT COMMENT '附件IDs（JSON）',
  security_level TINYINT NOT NULL DEFAULT 0,
  archived_at    DATETIME,
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by     BIGINT UNSIGNED,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at     DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS party_study_records (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  party_member_id BIGINT UNSIGNED NOT NULL,
  training_record_id BIGINT UNSIGNED COMMENT '关联培训记录',
  study_type      VARCHAR(32) NOT NULL COMMENT 'course/self/party_class',
  title           VARCHAR(255) NOT NULL,
  study_date      DATE NOT NULL,
  duration_mins   INT,
  notes           TEXT,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 涉密管理
-- ============================================================

CREATE TABLE IF NOT EXISTS security_levels (
  id                           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name                         VARCHAR(64) NOT NULL UNIQUE,
  level                        TINYINT NOT NULL UNIQUE,
  description                  VARCHAR(500),
  default_period_days          INT,
  auto_declassify              TINYINT NOT NULL DEFAULT 0,
  allow_download               TINYINT NOT NULL DEFAULT 1,
  need_approval_for_download   TINYINT NOT NULL DEFAULT 0,
  need_approval_for_share      TINYINT NOT NULL DEFAULT 1,
  audit_all_access             TINYINT NOT NULL DEFAULT 1,
  status                       TINYINT NOT NULL DEFAULT 1,
  created_by                   BIGINT UNSIGNED,
  created_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by                   BIGINT UNSIGNED,
  updated_at                   DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS classified_objects (
  id                   BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  business_type        VARCHAR(64) NOT NULL,
  business_id          BIGINT UNSIGNED NOT NULL,
  security_level       TINYINT NOT NULL,
  classification_status VARCHAR(16) NOT NULL DEFAULT 'pending',
  confidential_until   DATE,
  declassification_at  DATE,
  responsible_id       BIGINT UNSIGNED,
  department_id        BIGINT UNSIGNED,
  approval_id          BIGINT UNSIGNED,
  created_by           BIGINT UNSIGNED,
  created_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by           BIGINT UNSIGNED,
  updated_at           DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_business (business_type, business_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS classified_access_grants (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  object_id      BIGINT UNSIGNED NOT NULL COMMENT '关联 classified_objects',
  user_id        BIGINT UNSIGNED NOT NULL,
  granted_by     BIGINT UNSIGNED NOT NULL,
  access_level   TINYINT NOT NULL COMMENT '授权密级上限',
  valid_until    DATE,
  approval_id    BIGINT UNSIGNED,
  status         TINYINT NOT NULL DEFAULT 1,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_object_user (object_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS classified_carriers (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  carrier_no    VARCHAR(32) NOT NULL UNIQUE,
  type          VARCHAR(16) NOT NULL COMMENT 'usb/disk/cd/paper/device',
  security_level TINYINT NOT NULL,
  keeper_id     BIGINT UNSIGNED NOT NULL COMMENT '保管人',
  department_id BIGINT UNSIGNED,
  location      VARCHAR(255),
  status        VARCHAR(16) NOT NULL DEFAULT 'normal' COMMENT 'normal/borrowed/lost/destroyed',
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS classified_borrow_records (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  object_id     BIGINT UNSIGNED COMMENT '文件涉密对象',
  carrier_id    BIGINT UNSIGNED COMMENT '涉密载体',
  borrower_id   BIGINT UNSIGNED NOT NULL,
  borrow_type   VARCHAR(16) NOT NULL COMMENT 'borrow/share',
  recipient     VARCHAR(255) COMMENT '外发接收方',
  purpose       TEXT,
  expected_return DATE,
  actual_return  DATE,
  approval_id   BIGINT UNSIGNED,
  status        VARCHAR(16) NOT NULL DEFAULT 'borrowed',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS classification_requests (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  request_type   VARCHAR(16) NOT NULL COMMENT 'classify/change/declassify',
  business_type  VARCHAR(64) NOT NULL,
  business_id    BIGINT UNSIGNED NOT NULL,
  current_level  TINYINT,
  requested_level TINYINT,
  reason         TEXT NOT NULL,
  status         VARCHAR(16) NOT NULL DEFAULT 'pending',
  approval_id    BIGINT UNSIGNED,
  created_by     BIGINT UNSIGNED,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS confidentiality_checks (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  plan_no       VARCHAR(32) NOT NULL UNIQUE,
  check_date    DATE NOT NULL,
  scope         TEXT COMMENT '检查范围',
  checker_ids   TEXT COMMENT '检查人IDs（JSON）',
  department_ids TEXT COMMENT '被检查部门IDs（JSON）',
  findings      TEXT,
  result        VARCHAR(16) NOT NULL COMMENT 'pass/issues',
  status        VARCHAR(16) NOT NULL DEFAULT 'planned',
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS confidentiality_issues (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  check_id        BIGINT UNSIGNED NOT NULL,
  department_id   BIGINT UNSIGNED,
  description     TEXT NOT NULL,
  severity        VARCHAR(16) NOT NULL,
  handler_id      BIGINT UNSIGNED,
  deadline        DATE,
  resolution      TEXT,
  resolved_at     DATE,
  status          VARCHAR(16) NOT NULL DEFAULT 'open',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS leak_incidents (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  incident_no     VARCHAR(32) NOT NULL UNIQUE,
  level           VARCHAR(16) NOT NULL COMMENT 'minor/moderate/serious/critical',
  discovery_channel VARCHAR(64),
  occurred_at     DATETIME,
  discovered_at   DATETIME NOT NULL,
  description     TEXT NOT NULL,
  affected_scope  TEXT,
  immediate_action TEXT,
  investigation   TEXT,
  corrective_measures TEXT,
  accountability  TEXT COMMENT '追责结果',
  status          VARCHAR(16) NOT NULL DEFAULT 'open',
  closed_at       DATETIME,
  department_id   BIGINT UNSIGNED,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS confidentiality_education_records (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  employee_id  BIGINT UNSIGNED NOT NULL,
  training_id  BIGINT UNSIGNED COMMENT '关联培训记录',
  pledge_date  DATE COMMENT '保密承诺书签署日期',
  pass_exam    TINYINT NOT NULL DEFAULT 0,
  exam_date    DATE,
  score        DECIMAL(5,2),
  status       VARCHAR(16) NOT NULL DEFAULT 'pending',
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS classified_audit_logs (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id       BIGINT UNSIGNED NOT NULL,
  username      VARCHAR(64) NOT NULL,
  action        VARCHAR(32) NOT NULL,
  business_type VARCHAR(64) NOT NULL,
  business_id   BIGINT UNSIGNED NOT NULL,
  security_level TINYINT NOT NULL,
  object_name   VARCHAR(255),
  ip            VARCHAR(64) NOT NULL,
  device_info   VARCHAR(255),
  result        TINYINT NOT NULL DEFAULT 1,
  deny_reason   VARCHAR(255),
  is_anomaly    TINYINT NOT NULL DEFAULT 0,
  anomaly_reason VARCHAR(255),
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_business (business_type, business_id),
  INDEX idx_user_time (user_id, created_at),
  INDEX idx_anomaly (is_anomaly)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
