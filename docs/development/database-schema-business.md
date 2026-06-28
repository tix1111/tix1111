# 数据库字段详细定义（核心业务表）

## 1. 员工档案 `employees`

```sql
CREATE TABLE employees (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         BIGINT UNSIGNED UNIQUE COMMENT '关联用户账号',
  emp_no          VARCHAR(32) NOT NULL UNIQUE COMMENT '工号',
  real_name       VARCHAR(64) NOT NULL COMMENT '姓名',
  gender          TINYINT COMMENT '0未知 1男 2女',
  birthday        DATE,
  id_card         VARCHAR(64) COMMENT '身份证（建议加密存储）',
  phone           VARCHAR(20) NOT NULL,
  email           VARCHAR(128),
  department_id   BIGINT UNSIGNED NOT NULL,
  position_id     BIGINT UNSIGNED,
  entry_date      DATE NOT NULL COMMENT '入职日期',
  probation_end   DATE COMMENT '试用期截止',
  confirmed_date  DATE COMMENT '转正日期',
  leave_date      DATE COMMENT '离职日期',
  emp_status      VARCHAR(16) NOT NULL DEFAULT 'active' COMMENT 'active/probation/on_leave/resigned',
  contract_type   VARCHAR(32) COMMENT '劳动合同类型',
  photo_url       VARCHAR(500) COMMENT '头像',
  emergency_contact VARCHAR(64) COMMENT '紧急联系人',
  emergency_phone VARCHAR(20),
  address         VARCHAR(500) COMMENT '家庭住址',
  education       VARCHAR(32) COMMENT '最高学历',
  major           VARCHAR(128) COMMENT '专业',
  graduate_school VARCHAR(128) COMMENT '毕业院校',
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 2. 考勤记录 `attendance_records`

```sql
CREATE TABLE attendance_records (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  employee_id     BIGINT UNSIGNED NOT NULL,
  record_date     DATE NOT NULL,
  check_in_at     DATETIME,
  check_out_at    DATETIME,
  location        VARCHAR(255) COMMENT '打卡位置',
  ip              VARCHAR(64),
  type            VARCHAR(16) NOT NULL DEFAULT 'normal' COMMENT 'normal/overtime/leave',
  abnormal_reason VARCHAR(255) COMMENT '异常原因',
  approval_id     BIGINT UNSIGNED COMMENT '关联请假/加班审批',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_emp_date (employee_id, record_date)
) ENGINE=InnoDB;
```

## 3. 客户档案 `customers`

```sql
CREATE TABLE customers (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_no     VARCHAR(32) NOT NULL UNIQUE COMMENT '客户编号',
  name            VARCHAR(255) NOT NULL COMMENT '客户名称',
  short_name      VARCHAR(64) COMMENT '简称',
  type            VARCHAR(32) NOT NULL COMMENT 'enterprise/individual',
  industry        VARCHAR(64) COMMENT '行业',
  region          VARCHAR(128) COMMENT '区域',
  level           VARCHAR(16) NOT NULL DEFAULT 'normal' COMMENT 'key/important/normal/potential',
  business_status TEXT COMMENT '业务现状描述',
  address         VARCHAR(500),
  website         VARCHAR(255),
  owner_id        BIGINT UNSIGNED NOT NULL COMMENT '当前负责人',
  department_id   BIGINT UNSIGNED,
  status          VARCHAR(16) NOT NULL DEFAULT 'active' COMMENT 'active/inactive/blacklist',
  source          VARCHAR(32) COMMENT '客户来源',
  security_level  TINYINT NOT NULL DEFAULT 0,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 4. 客户联系人 `customer_contacts`

```sql
CREATE TABLE customer_contacts (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id     BIGINT UNSIGNED NOT NULL,
  name            VARCHAR(64) NOT NULL,
  title           VARCHAR(128) COMMENT '职务',
  department      VARCHAR(128) COMMENT '所在部门',
  influence_level VARCHAR(16) COMMENT 'decision/influence/use/execute/finance COMMENT 决策/影响/使用/执行/财务',
  phone           VARCHAR(20),
  wechat          VARCHAR(64) COMMENT '微信',
  email           VARCHAR(128),
  birthday        DATE COMMENT '生日（敏感字段，需权限查看）',
  preferences     TEXT COMMENT '喜好（敏感字段）',
  family_info     TEXT COMMENT '家庭情况（敏感字段，加密或权限控制）',
  social_networks TEXT COMMENT '社会关系（敏感字段）',
  taboos          TEXT COMMENT '禁忌事项',
  notes           TEXT COMMENT '其他备注',
  is_key          TINYINT NOT NULL DEFAULT 0 COMMENT '1是关键联系人',
  status          TINYINT NOT NULL DEFAULT 1 COMMENT '1在职 0离职',
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 5. 客户拜访 `customer_visits`

```sql
CREATE TABLE customer_visits (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id     BIGINT UNSIGNED NOT NULL,
  visitor_id      BIGINT UNSIGNED NOT NULL COMMENT '拜访人',
  visit_date      DATETIME NOT NULL,
  location        VARCHAR(255) COMMENT '拜访地点/方式',
  contact_ids     TEXT COMMENT '拜访联系人 ID 列表（JSON）',
  objective       VARCHAR(500) COMMENT '拜访目的',
  content         TEXT COMMENT '拜访内容',
  result          TEXT COMMENT '取得效果',
  next_action     VARCHAR(500) COMMENT '下一步动作',
  next_action_date DATE COMMENT '下一步计划日期',
  stage           VARCHAR(32) COMMENT '对应摧龙六式阶段',
  has_opportunity TINYINT NOT NULL DEFAULT 0 COMMENT '是否产生商机',
  opportunity_id  BIGINT UNSIGNED COMMENT '产生的商机 ID',
  approval_id     BIGINT UNSIGNED COMMENT '商务活动审批（如涉及费用）',
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 6. 商机 `opportunities`

```sql
CREATE TABLE opportunities (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  opportunity_no  VARCHAR(32) NOT NULL UNIQUE,
  customer_id     BIGINT UNSIGNED NOT NULL,
  title           VARCHAR(255) NOT NULL,
  source          VARCHAR(32) COMMENT '来源：visit/referral/marketing/inbound',
  stage           VARCHAR(32) NOT NULL DEFAULT 'lead' COMMENT 'lead/qualify/proposal/negotiation/won/lost',
  expected_amount DECIMAL(14,2) COMMENT '预计合同金额',
  win_rate        TINYINT NOT NULL DEFAULT 0 COMMENT '赢率0-100',
  expected_close  DATE COMMENT '预计成交日期',
  owner_id        BIGINT UNSIGNED NOT NULL,
  department_id   BIGINT UNSIGNED,
  pain_point      TEXT COMMENT '客户痛点',
  budget          DECIMAL(14,2) COMMENT '客户预算',
  competitor      TEXT COMMENT '竞争对手信息',
  lost_reason     VARCHAR(255) COMMENT '丢单原因',
  project_id      BIGINT UNSIGNED COMMENT '转项目后关联',
  contract_id     BIGINT UNSIGNED COMMENT '转合同后关联',
  status          VARCHAR(16) NOT NULL DEFAULT 'open' COMMENT 'open/won/lost',
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 7. 项目 `projects`

```sql
CREATE TABLE projects (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  project_no      VARCHAR(32) NOT NULL UNIQUE,
  name            VARCHAR(255) NOT NULL,
  customer_id     BIGINT UNSIGNED,
  opportunity_id  BIGINT UNSIGNED COMMENT '来源商机',
  type            VARCHAR(32) COMMENT '项目类型：implementation/maintenance/development/market',
  owner_id        BIGINT UNSIGNED NOT NULL COMMENT '项目经理',
  department_id   BIGINT UNSIGNED,
  budget          DECIMAL(14,2) COMMENT '项目总预算',
  start_date      DATE,
  end_date        DATE COMMENT '计划完成日期',
  actual_end_date DATE,
  status          VARCHAR(16) NOT NULL DEFAULT 'draft' COMMENT 'draft/approving/active/suspended/completed/cancelled',
  approval_status VARCHAR(16) COMMENT '立项审批状态',
  approval_id     BIGINT UNSIGNED,
  security_level  TINYINT NOT NULL DEFAULT 0,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 8. 合同 `contracts`

```sql
CREATE TABLE contracts (
  id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  contract_no       VARCHAR(64) NOT NULL UNIQUE,
  title             VARCHAR(255) NOT NULL,
  type              VARCHAR(32) NOT NULL COMMENT '合同类型：sales/purchase/service/employment/maintenance/lease/other',
  counterparty_type VARCHAR(16) COMMENT 'customer/supplier/employee/other',
  customer_id       BIGINT UNSIGNED COMMENT '甲方/客户',
  supplier_id       BIGINT UNSIGNED COMMENT '供应商',
  employee_id       BIGINT UNSIGNED COMMENT '关联员工（劳动合同）',
  project_id        BIGINT UNSIGNED COMMENT '关联项目',
  engineering_id    BIGINT UNSIGNED COMMENT '关联工程',
  amount            DECIMAL(14,2) NOT NULL COMMENT '合同金额',
  currency          VARCHAR(8) NOT NULL DEFAULT 'CNY',
  sign_date         DATE,
  start_date        DATE COMMENT '执行开始日期',
  end_date          DATE COMMENT '到期日期',
  payment_terms     TEXT COMMENT '付款条款',
  status            VARCHAR(16) NOT NULL DEFAULT 'draft' COMMENT 'draft/reviewing/active/completed/terminated/archived',
  approval_status   VARCHAR(16),
  approval_id       BIGINT UNSIGNED,
  signed_by         BIGINT UNSIGNED COMMENT '签署人',
  owner_id          BIGINT UNSIGNED NOT NULL,
  department_id     BIGINT UNSIGNED,
  security_level    TINYINT NOT NULL DEFAULT 0,
  remark            TEXT,
  created_by        BIGINT UNSIGNED,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by        BIGINT UNSIGNED,
  updated_at        DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at        DATETIME
) ENGINE=InnoDB;
```

## 9. 费用报销 `reimbursements`

```sql
CREATE TABLE reimbursements (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reimburse_no    VARCHAR(32) NOT NULL UNIQUE,
  applicant_id    BIGINT UNSIGNED NOT NULL COMMENT '报销申请人',
  department_id   BIGINT UNSIGNED NOT NULL,
  project_id      BIGINT UNSIGNED COMMENT '关联项目（项目报销时必填）',
  engineering_id  BIGINT UNSIGNED COMMENT '关联工程（可选）',
  expense_category VARCHAR(64) NOT NULL COMMENT '费用类别（字典）',
  total_amount    DECIMAL(14,2) NOT NULL,
  paid_amount     DECIMAL(14,2) COMMENT '实际付款金额',
  invoice_count   TINYINT NOT NULL DEFAULT 0 COMMENT '发票张数',
  description     TEXT NOT NULL COMMENT '报销说明',
  status          VARCHAR(16) NOT NULL DEFAULT 'draft',
  approval_status VARCHAR(16) COMMENT 'approving/approved/rejected',
  approval_id     BIGINT UNSIGNED,
  paid_at         DATETIME,
  paid_by         BIGINT UNSIGNED,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 10. 报销发票 `reimbursement_invoices`

```sql
CREATE TABLE reimbursement_invoices (
  id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reimbursement_id  BIGINT UNSIGNED NOT NULL,
  invoice_type      VARCHAR(32) COMMENT '发票类型：vat_special/vat_general/receipt/other',
  invoice_no        VARCHAR(64) COMMENT '发票号码',
  invoice_code      VARCHAR(32) COMMENT '发票代码',
  invoice_date      DATE,
  seller_name       VARCHAR(255) COMMENT '销方名称',
  amount            DECIMAL(14,2) NOT NULL COMMENT '不含税金额',
  tax_amount        DECIMAL(14,2) COMMENT '税额',
  total_amount      DECIMAL(14,2) NOT NULL COMMENT '价税合计',
  attachment_id     BIGINT UNSIGNED COMMENT '发票附件',
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## 11. 付款申请 `payment_requests`

```sql
CREATE TABLE payment_requests (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  pay_no          VARCHAR(32) NOT NULL UNIQUE,
  applicant_id    BIGINT UNSIGNED NOT NULL,
  department_id   BIGINT UNSIGNED NOT NULL,
  pay_type        VARCHAR(32) NOT NULL COMMENT 'contract/purchase/collaboration/other',
  contract_id     BIGINT UNSIGNED COMMENT '关联合同',
  supplier_id     BIGINT UNSIGNED COMMENT '收款供应商',
  payee_name      VARCHAR(255) NOT NULL COMMENT '收款方名称',
  payee_bank      VARCHAR(255) COMMENT '开户行',
  payee_account   VARCHAR(64) COMMENT '银行账号（建议加密）',
  amount          DECIMAL(14,2) NOT NULL,
  purpose         TEXT NOT NULL COMMENT '付款事由',
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
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 12. 设备台账 `devices`

```sql
CREATE TABLE devices (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  device_no       VARCHAR(64) NOT NULL UNIQUE,
  name            VARCHAR(255) NOT NULL,
  category        VARCHAR(64) COMMENT '设备分类（字典）',
  brand           VARCHAR(128) COMMENT '品牌',
  model           VARCHAR(128) COMMENT '型号',
  serial_no       VARCHAR(128) COMMENT '序列号',
  supplier_id     BIGINT UNSIGNED COMMENT '供货商',
  purchase_date   DATE,
  warranty_end    DATE COMMENT '质保到期',
  location        VARCHAR(255) COMMENT '存放位置',
  owner_dept_id   BIGINT UNSIGNED COMMENT '使用部门',
  responsible_id  BIGINT UNSIGNED COMMENT '责任人',
  contract_id     BIGINT UNSIGNED COMMENT '采购合同',
  status          VARCHAR(16) NOT NULL DEFAULT 'normal' COMMENT 'normal/fault/repair/scrapped',
  security_level  TINYINT NOT NULL DEFAULT 0,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 13. 工单 `work_orders`

```sql
CREATE TABLE work_orders (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_no        VARCHAR(32) NOT NULL UNIQUE,
  type            VARCHAR(32) NOT NULL COMMENT 'repair/maintenance/inspection/service',
  source          VARCHAR(32) NOT NULL COMMENT 'user/inspection/plan/customer',
  device_id       BIGINT UNSIGNED COMMENT '关联设备',
  customer_id     BIGINT UNSIGNED COMMENT '客户服务工单',
  project_id      BIGINT UNSIGNED COMMENT '关联项目',
  title           VARCHAR(255) NOT NULL,
  description     TEXT NOT NULL COMMENT '问题描述',
  priority        TINYINT NOT NULL DEFAULT 0 COMMENT '0普通 1重要 2紧急',
  sla_rule_id     BIGINT UNSIGNED COMMENT '适用SLA规则',
  response_deadline DATETIME COMMENT '响应截止',
  resolve_deadline  DATETIME COMMENT '处理截止',
  responded_at    DATETIME,
  resolved_at     DATETIME,
  assignee_team_id BIGINT UNSIGNED COMMENT '分配协作团队',
  assignee_id     BIGINT UNSIGNED COMMENT '分配处理人',
  handler_id      BIGINT UNSIGNED COMMENT '实际处理人',
  resolution      TEXT COMMENT '处理结果',
  root_cause      TEXT COMMENT '根本原因',
  parts_used      TEXT COMMENT '使用备件（JSON）',
  knowledge_id    BIGINT UNSIGNED COMMENT '关联知识库',
  status          VARCHAR(16) NOT NULL DEFAULT 'pending' COMMENT 'pending/assigned/processing/resolved/closed/rejected',
  close_comment   VARCHAR(500),
  closed_by       BIGINT UNSIGNED,
  closed_at       DATETIME,
  satisfaction    TINYINT COMMENT '满意度评分1-5',
  department_id   BIGINT UNSIGNED,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 14. 工程 `engineering_items`

```sql
CREATE TABLE engineering_items (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  eng_no          VARCHAR(32) NOT NULL UNIQUE,
  name            VARCHAR(255) NOT NULL,
  type            VARCHAR(16) NOT NULL DEFAULT 'project' COMMENT 'project正式工程/loose零散任务',
  project_id      BIGINT UNSIGNED COMMENT '来源项目（零散任务可为空）',
  customer_id     BIGINT UNSIGNED,
  contract_id     BIGINT UNSIGNED,
  owner_id        BIGINT UNSIGNED NOT NULL COMMENT '工程负责人',
  department_id   BIGINT UNSIGNED,
  plan_start      DATE,
  plan_end        DATE,
  actual_start    DATE,
  actual_end      DATE,
  scope           TEXT COMMENT '施工范围',
  budget          DECIMAL(14,2) COMMENT '工程预算',
  status          VARCHAR(16) NOT NULL DEFAULT 'draft' COMMENT 'draft/planning/active/paused/completed/cancelled',
  approval_id     BIGINT UNSIGNED COMMENT '立项审批',
  progress        TINYINT NOT NULL DEFAULT 0 COMMENT '进度0-100',
  security_level  TINYINT NOT NULL DEFAULT 0,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 15. 工程施工日志 `engineering_logs`

```sql
CREATE TABLE engineering_logs (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  log_date        DATE NOT NULL,
  weather         VARCHAR(32) COMMENT '天气',
  workers         TINYINT COMMENT '当日施工人数',
  content         TEXT NOT NULL COMMENT '施工内容',
  materials_used  TEXT COMMENT '使用材料（JSON）',
  issues          TEXT COMMENT '发现问题',
  next_plan       TEXT COMMENT '明日计划',
  photos          TEXT COMMENT '现场照片附件ID（JSON）',
  reporter_id     BIGINT UNSIGNED NOT NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## 16. 工程变更签证 `engineering_change_orders`

```sql
CREATE TABLE engineering_change_orders (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  change_no       VARCHAR(32) NOT NULL UNIQUE,
  type            VARCHAR(32) NOT NULL COMMENT 'scope/cost/schedule/other',
  reason          TEXT NOT NULL COMMENT '变更原因',
  content         TEXT NOT NULL COMMENT '变更内容',
  cost_impact     DECIMAL(14,2) COMMENT '费用影响，负数减少',
  days_impact     INT COMMENT '工期影响（天），负数缩短',
  status          VARCHAR(16) NOT NULL DEFAULT 'draft',
  approval_id     BIGINT UNSIGNED,
  approved_at     DATETIME,
  approved_by     BIGINT UNSIGNED,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 17. 工程施工团队 `engineering_team_members`

```sql
CREATE TABLE engineering_team_members (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  team_id         BIGINT UNSIGNED COMMENT '协作团队 ID',
  member_id       BIGINT UNSIGNED COMMENT '协作团队成员 ID',
  employee_id     BIGINT UNSIGNED COMMENT '内部员工 ID',
  role            VARCHAR(32) NOT NULL COMMENT 'captain/worker/safety/quality/document',
  skill_tags      TEXT COMMENT '技能标签（JSON）',
  entry_status    VARCHAR(16) NOT NULL DEFAULT 'pending' COMMENT 'pending/entered/exited',
  entered_at      DATETIME,
  exited_at       DATETIME,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_eng_member (engineering_id, member_id, employee_id)
) ENGINE=InnoDB;
```

## 18. 工程进场记录 `engineering_site_entries`

```sql
CREATE TABLE engineering_site_entries (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  entry_date      DATETIME NOT NULL COMMENT '进场时间',
  member_ids      TEXT COMMENT '到场施工成员IDs（JSON）',
  site_condition  TEXT COMMENT '现场条件：水电、网络、场地、许可等',
  safety_briefing TINYINT NOT NULL DEFAULT 0 COMMENT '是否完成安全交底',
  customer_confirm_user VARCHAR(128) COMMENT '客户现场确认人',
  photo_ids       TEXT COMMENT '进场照片附件IDs（JSON）',
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## 19. 工程质量安全问题 `engineering_quality_issues`

```sql
CREATE TABLE engineering_quality_issues (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  issue_no        VARCHAR(32) NOT NULL UNIQUE,
  issue_type      VARCHAR(32) NOT NULL COMMENT 'quality/safety/hidden_danger/accident',
  severity        VARCHAR(16) NOT NULL COMMENT 'normal/serious/critical',
  description     TEXT NOT NULL,
  responsible_id  BIGINT UNSIGNED COMMENT '整改责任人',
  deadline        DATE,
  rectification   TEXT COMMENT '整改说明',
  review_result   VARCHAR(16) COMMENT 'pass/fail',
  reviewer_id     BIGINT UNSIGNED,
  reviewed_at     DATETIME,
  status          VARCHAR(16) NOT NULL DEFAULT 'open' COMMENT 'open/rectifying/reviewing/closed',
  photo_ids       TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## 20. 隐蔽工程验收 `engineering_hidden_acceptance`

```sql
CREATE TABLE engineering_hidden_acceptance (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  stage_name      VARCHAR(128) NOT NULL COMMENT '隐蔽阶段名称',
  check_items     JSON NOT NULL COMMENT '验收检查项',
  result          VARCHAR(16) NOT NULL COMMENT 'pass/conditional/fail',
  acceptor_ids    TEXT COMMENT '验收人IDs（JSON）',
  photo_ids       TEXT COMMENT '验收照片附件IDs（JSON）',
  issues          TEXT COMMENT '问题说明',
  rectification_required TINYINT NOT NULL DEFAULT 0,
  reviewed_at     DATETIME,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## 21. 工程结算 `engineering_settlements`

```sql
CREATE TABLE engineering_settlements (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  engineering_id  BIGINT UNSIGNED NOT NULL,
  settlement_no   VARCHAR(32) NOT NULL UNIQUE,
  workload_items  JSON COMMENT '工程量明细',
  material_cost   DECIMAL(14,2) NOT NULL DEFAULT 0,
  team_cost       DECIMAL(14,2) NOT NULL DEFAULT 0,
  change_amount   DECIMAL(14,2) NOT NULL DEFAULT 0,
  other_amount    DECIMAL(14,2) NOT NULL DEFAULT 0,
  total_amount    DECIMAL(14,2) NOT NULL,
  status          VARCHAR(16) NOT NULL DEFAULT 'draft',
  approval_id     BIGINT UNSIGNED,
  payment_req_id  BIGINT UNSIGNED COMMENT '关联付款申请',
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 17. 薪酬记录 `salary_records`（原文档缺失，本次补充）

```sql
CREATE TABLE salary_records (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  employee_id     BIGINT UNSIGNED NOT NULL,
  period          VARCHAR(7) NOT NULL COMMENT '薪酬周期，如 2025-06',
  base_salary     DECIMAL(14,2) NOT NULL COMMENT '基本工资',
  performance     DECIMAL(14,2) COMMENT '绩效奖金',
  allowance       DECIMAL(14,2) COMMENT '津贴',
  overtime_pay    DECIMAL(14,2) COMMENT '加班费',
  deductions      DECIMAL(14,2) COMMENT '扣款小计',
  social_ins_emp  DECIMAL(14,2) COMMENT '个人社保',
  provident_fund  DECIMAL(14,2) COMMENT '个人公积金',
  personal_tax    DECIMAL(14,2) COMMENT '个税',
  net_salary      DECIMAL(14,2) NOT NULL COMMENT '实发工资',
  status          VARCHAR(16) NOT NULL DEFAULT 'draft' COMMENT 'draft/confirmed/paid',
  confirmed_by    BIGINT UNSIGNED,
  confirmed_at    DATETIME,
  paid_at         DATETIME,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_emp_period (employee_id, period)
) ENGINE=InnoDB;
```

## 18. 绩效方案 `performance_plans`（原文档缺失，本次补充）

```sql
CREATE TABLE performance_plans (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(128) NOT NULL,
  period          VARCHAR(7) NOT NULL COMMENT '考核周期如 2025-Q2',
  scope_type      VARCHAR(16) NOT NULL COMMENT 'dept/position/individual',
  department_id   BIGINT UNSIGNED COMMENT '适用部门',
  position_id     BIGINT UNSIGNED COMMENT '适用岗位',
  kpi_rules       JSON COMMENT '考核指标及权重',
  status          VARCHAR(16) NOT NULL DEFAULT 'draft' COMMENT 'draft/active/closed',
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 19. 绩效结果 `performance_results`（原文档缺失，本次补充）

```sql
CREATE TABLE performance_results (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  plan_id         BIGINT UNSIGNED NOT NULL,
  employee_id     BIGINT UNSIGNED NOT NULL,
  self_score      DECIMAL(5,2) COMMENT '自评分',
  manager_score   DECIMAL(5,2) COMMENT '上级评分',
  final_score     DECIMAL(5,2) COMMENT '综合得分',
  rating          VARCHAR(16) COMMENT '等级：S/A/B/C/D',
  interview_notes TEXT COMMENT '绩效面谈记录',
  status          VARCHAR(16) NOT NULL DEFAULT 'pending' COMMENT 'pending/self/manager/done',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_plan_emp (plan_id, employee_id)
) ENGINE=InnoDB;
```

## 20. 通知公告 `notices`（补充完整字段）

```sql
CREATE TABLE notices (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  type            VARCHAR(32) NOT NULL COMMENT 'notice/announcement/party/training_remind',
  title           VARCHAR(255) NOT NULL,
  content         LONGTEXT NOT NULL,
  summary         VARCHAR(500) COMMENT '摘要',
  cover_image     VARCHAR(500) COMMENT '封面图',
  priority        TINYINT NOT NULL DEFAULT 0 COMMENT '0普通 1重要 2置顶',
  target_type     VARCHAR(16) NOT NULL DEFAULT 'all' COMMENT 'all/dept/role/custom',
  target_ids      TEXT COMMENT '目标部门或用户 ID（JSON）',
  publish_at      DATETIME COMMENT '定时发布时间，NULL=立即',
  expire_at       DATETIME COMMENT '过期时间',
  is_require_read TINYINT NOT NULL DEFAULT 0 COMMENT '1需要确认已读',
  is_need_feedback TINYINT NOT NULL DEFAULT 0 COMMENT '1需要反馈',
  status          VARCHAR(16) NOT NULL DEFAULT 'draft' COMMENT 'draft/scheduled/published/archived',
  publisher_id    BIGINT UNSIGNED NOT NULL,
  department_id   BIGINT UNSIGNED COMMENT '发布部门',
  security_level  TINYINT NOT NULL DEFAULT 0,
  read_count      INT NOT NULL DEFAULT 0,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```
