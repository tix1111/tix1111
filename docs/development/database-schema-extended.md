# 数据库字段详细定义（扩展模块表）

## 1. 物料 `materials`

```sql
CREATE TABLE materials (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  material_no   VARCHAR(64) NOT NULL UNIQUE COMMENT '物料编码',
  name          VARCHAR(255) NOT NULL,
  category      VARCHAR(64) COMMENT '物料分类（字典）',
  spec          VARCHAR(255) COMMENT '规格型号',
  unit          VARCHAR(16) NOT NULL COMMENT '单位：个/米/吨...',
  brand         VARCHAR(128) COMMENT '品牌',
  min_stock     DECIMAL(14,4) COMMENT '最低库存预警数量',
  max_stock     DECIMAL(14,4) COMMENT '最高库存',
  ref_price     DECIMAL(14,2) COMMENT '参考单价',
  status        TINYINT NOT NULL DEFAULT 1 COMMENT '1正常 0停用',
  remark        TEXT,
  created_by    BIGINT UNSIGNED,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by    BIGINT UNSIGNED,
  updated_at    DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME
) ENGINE=InnoDB;
```

## 2. 仓库 `warehouses`

```sql
CREATE TABLE warehouses (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(128) NOT NULL,
  code        VARCHAR(32) NOT NULL UNIQUE,
  address     VARCHAR(500) COMMENT '仓库地址',
  manager_id  BIGINT UNSIGNED COMMENT '仓管负责人',
  type        VARCHAR(16) NOT NULL DEFAULT 'main' COMMENT 'main/project/transit',
  status      TINYINT NOT NULL DEFAULT 1,
  remark      TEXT,
  created_by  BIGINT UNSIGNED,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by  BIGINT UNSIGNED,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at  DATETIME
) ENGINE=InnoDB;
```

## 3. 库存流水 `inventory_records`

```sql
CREATE TABLE inventory_records (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  material_id     BIGINT UNSIGNED NOT NULL,
  warehouse_id    BIGINT UNSIGNED NOT NULL,
  direction       TINYINT NOT NULL COMMENT '1入库 -1出库',
  qty             DECIMAL(14,4) NOT NULL COMMENT '数量（正值）',
  unit_price      DECIMAL(14,2) COMMENT '单价',
  amount          DECIMAL(14,2) COMMENT '金额',
  source_type     VARCHAR(32) NOT NULL COMMENT '来源：purchase/return/outbound/transfer/stocktake',
  source_id       BIGINT UNSIGNED COMMENT '来源单据 ID',
  project_id      BIGINT UNSIGNED COMMENT '项目归属',
  engineering_id  BIGINT UNSIGNED COMMENT '工程归属',
  work_order_id   BIGINT UNSIGNED COMMENT '工单归属',
  batch_no        VARCHAR(64) COMMENT '批次号',
  operator_id     BIGINT UNSIGNED NOT NULL,
  approved_by     BIGINT UNSIGNED COMMENT '审批人（部分操作需审批）',
  remark          VARCHAR(500),
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_material_warehouse (material_id, warehouse_id),
  INDEX idx_source (source_type, source_id)
) ENGINE=InnoDB;
```

## 4. 供应商 `suppliers`

```sql
CREATE TABLE suppliers (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  supplier_no     VARCHAR(32) NOT NULL UNIQUE,
  name            VARCHAR(255) NOT NULL,
  short_name      VARCHAR(64),
  category        VARCHAR(64) COMMENT '供应商分类（字典）',
  credit_code     VARCHAR(64) COMMENT '统一社会信用代码',
  contact_name    VARCHAR(64) COMMENT '主要联系人',
  contact_phone   VARCHAR(20),
  contact_email   VARCHAR(128),
  address         VARCHAR(500),
  bank_name       VARCHAR(255) COMMENT '开户行',
  bank_account    VARCHAR(64) COMMENT '银行账号（建议加密）',
  tax_no          VARCHAR(64) COMMENT '税务登记号',
  level           VARCHAR(16) NOT NULL DEFAULT 'C' COMMENT '等级：S/A/B/C/D',
  status          VARCHAR(16) NOT NULL DEFAULT 'pending' COMMENT 'pending/active/suspended/blacklist',
  onboard_date    DATE COMMENT '入驻通过日期',
  expiry_date     DATE COMMENT '合作有效期截止',
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 5. 供应商商品 `supplier_products`

```sql
CREATE TABLE supplier_products (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  supplier_id     BIGINT UNSIGNED NOT NULL,
  material_id     BIGINT UNSIGNED COMMENT '关联平台物料（未映射时为空）',
  name            VARCHAR(255) NOT NULL COMMENT '供应商商品名称',
  spec            VARCHAR(255) COMMENT '规格参数',
  unit            VARCHAR(16) NOT NULL,
  list_price      DECIMAL(14,2) COMMENT '目录价格',
  min_order_qty   DECIMAL(14,4) COMMENT '最小订货量',
  lead_time_days  INT COMMENT '交货周期（天）',
  status          TINYINT NOT NULL DEFAULT 1 COMMENT '1上架 0下架',
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## 6. 采购订单 `purchase_orders`

```sql
CREATE TABLE purchase_orders (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_no        VARCHAR(32) NOT NULL UNIQUE,
  inquiry_id      BIGINT UNSIGNED COMMENT '来源询价单',
  compare_id      BIGINT UNSIGNED COMMENT '来源比价清单',
  supplier_id     BIGINT UNSIGNED NOT NULL,
  project_id      BIGINT UNSIGNED COMMENT '关联项目',
  total_amount    DECIMAL(14,2) NOT NULL,
  status          VARCHAR(16) NOT NULL DEFAULT 'draft' COMMENT 'draft/approving/confirmed/delivering/received/closed/cancelled',
  approval_id     BIGINT UNSIGNED,
  delivery_address VARCHAR(500) NOT NULL,
  expected_date   DATE COMMENT '要求到货日期',
  actual_date     DATE COMMENT '实际到货日期',
  notify_at       DATETIME COMMENT '发送供应商通知时间',
  confirmed_by    BIGINT UNSIGNED COMMENT '供应商确认接单时间对应的系统用户（供应商账号）',
  confirmed_at    DATETIME,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 7. 协作团队 `collaboration_teams`

```sql
CREATE TABLE collaboration_teams (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  team_no         VARCHAR(32) NOT NULL UNIQUE,
  name            VARCHAR(255) NOT NULL,
  type            VARCHAR(16) NOT NULL COMMENT 'internal/external/contracted/company',
  service_scope   TEXT COMMENT '服务范围',
  region          VARCHAR(128) COMMENT '服务区域',
  leader_id       BIGINT UNSIGNED COMMENT '团队负责人',
  fee_standard    TEXT COMMENT '费用标准（JSON）',
  status          VARCHAR(16) NOT NULL DEFAULT 'active' COMMENT 'active/suspended/blacklist',
  level           VARCHAR(16) NOT NULL DEFAULT 'C' COMMENT '评级 S/A/B/C',
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 8. 培训课程 `training_courses`

```sql
CREATE TABLE training_courses (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title           VARCHAR(255) NOT NULL,
  category        VARCHAR(64) COMMENT '课程分类（字典）：技术/安全/党建/保密/综合',
  course_type     VARCHAR(16) NOT NULL DEFAULT 'video' COMMENT 'video/doc/live/exam',
  cover_image     VARCHAR(500),
  description     TEXT,
  duration_mins   INT COMMENT '课程时长（分钟）',
  instructor      VARCHAR(128) COMMENT '讲师',
  difficulty      TINYINT NOT NULL DEFAULT 1 COMMENT '1初级 2中级 3高级',
  is_required     TINYINT NOT NULL DEFAULT 0 COMMENT '1必修',
  pass_score      TINYINT NOT NULL DEFAULT 60 COMMENT '考试通过分数',
  target_audience TEXT COMMENT '适用对象说明',
  status          VARCHAR(16) NOT NULL DEFAULT 'draft' COMMENT 'draft/published/archived',
  security_level  TINYINT NOT NULL DEFAULT 0,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 9. 学习记录 `training_records`

```sql
CREATE TABLE training_records (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  plan_id         BIGINT UNSIGNED COMMENT '来源培训计划',
  course_id       BIGINT UNSIGNED NOT NULL,
  learner_id      BIGINT UNSIGNED NOT NULL COMMENT '学员（employee_id）',
  progress        TINYINT NOT NULL DEFAULT 0 COMMENT '学习进度0-100',
  study_duration  INT NOT NULL DEFAULT 0 COMMENT '学习时长（分钟）',
  exam_score      DECIMAL(5,2) COMMENT '考试得分',
  is_passed       TINYINT NOT NULL DEFAULT 0 COMMENT '1已通过',
  passed_at       DATETIME,
  certificate_no  VARCHAR(128) COMMENT '证书编号',
  certificate_url VARCHAR(500) COMMENT '证书附件',
  cert_issued_at  DATETIME,
  cert_expiry     DATE COMMENT '证书有效期',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_plan_course_learner (plan_id, course_id, learner_id)
) ENGINE=InnoDB;
```

## 10. 党组织 `party_organizations`

```sql
CREATE TABLE party_organizations (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(128) NOT NULL,
  type            VARCHAR(16) NOT NULL COMMENT 'committee/branch/group（党委/党支部/党小组）',
  parent_id       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '上级党组织',
  secretary_id    BIGINT UNSIGNED COMMENT '书记（employee_id）',
  deputy_secretary_id BIGINT UNSIGNED COMMENT '副书记',
  member_count    INT NOT NULL DEFAULT 0,
  established_date DATE,
  next_election    DATE COMMENT '下次换届日期',
  status          TINYINT NOT NULL DEFAULT 1,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 11. 党员信息 `party_members`

```sql
CREATE TABLE party_members (
  id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  employee_id         BIGINT UNSIGNED NOT NULL UNIQUE COMMENT '关联员工档案',
  party_org_id        BIGINT UNSIGNED NOT NULL COMMENT '所属党组织',
  inner_title         VARCHAR(64) COMMENT '党内职务，如支委、书记等',
  join_apply_date     DATE COMMENT '申请入党日期',
  probation_date      DATE COMMENT '预备党员日期',
  full_date           DATE COMMENT '转正日期',
  member_type         VARCHAR(16) NOT NULL DEFAULT 'full' COMMENT 'applicant/probation/full',
  dues_standard       DECIMAL(14,2) COMMENT '月党费基准',
  status              VARCHAR(16) NOT NULL DEFAULT 'active' COMMENT 'active/suspended/transferred/expelled',
  transfer_out_at     DATE COMMENT '组织关系转出日期',
  remark              TEXT,
  created_by          BIGINT UNSIGNED,
  created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by          BIGINT UNSIGNED,
  updated_at          DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at          DATETIME
) ENGINE=InnoDB;
```

## 12. 党费记录 `party_dues`

```sql
CREATE TABLE party_dues (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  party_member_id BIGINT UNSIGNED NOT NULL COMMENT '关联党员',
  party_org_id    BIGINT UNSIGNED NOT NULL,
  period          VARCHAR(7) NOT NULL COMMENT '缴费周期，如 2025-06',
  due_amount      DECIMAL(14,2) NOT NULL COMMENT '应缴',
  paid_amount     DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '实缴',
  pay_date        DATE COMMENT '缴费日期',
  status          VARCHAR(16) NOT NULL DEFAULT 'pending' COMMENT 'pending/partial/paid/overdue',
  collector_id    BIGINT UNSIGNED COMMENT '收缴人',
  remark          VARCHAR(500),
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_member_period (party_member_id, period)
) ENGINE=InnoDB;
```

## 13. 密级规则 `security_levels`

```sql
CREATE TABLE security_levels (
  id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name              VARCHAR(64) NOT NULL UNIQUE COMMENT '密级名称，如：内部/秘密/机密/绝密',
  level             TINYINT NOT NULL UNIQUE COMMENT '等级值（越大越高）',
  description       VARCHAR(500),
  default_period_days INT COMMENT '默认保密期限（天）',
  auto_declassify   TINYINT NOT NULL DEFAULT 0 COMMENT '1到期自动解密',
  allow_download    TINYINT NOT NULL DEFAULT 1 COMMENT '0不允许普通下载',
  need_approval_for_download TINYINT NOT NULL DEFAULT 0 COMMENT '1下载需要审批',
  need_approval_for_share    TINYINT NOT NULL DEFAULT 1 COMMENT '1外发需要审批',
  audit_all_access  TINYINT NOT NULL DEFAULT 1 COMMENT '1所有访问均记录审计',
  status            TINYINT NOT NULL DEFAULT 1,
  created_by        BIGINT UNSIGNED,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by        BIGINT UNSIGNED,
  updated_at        DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## 14. 涉密审计日志 `classified_audit_logs`

```sql
CREATE TABLE classified_audit_logs (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         BIGINT UNSIGNED NOT NULL,
  username        VARCHAR(64) NOT NULL,
  action          VARCHAR(32) NOT NULL COMMENT 'view/download/export/print/copy/share/delete_attempt',
  business_type   VARCHAR(64) NOT NULL COMMENT '业务对象类型',
  business_id     BIGINT UNSIGNED NOT NULL,
  security_level  TINYINT NOT NULL,
  object_name     VARCHAR(255) COMMENT '被访问对象名称',
  ip              VARCHAR(64) NOT NULL,
  device_info     VARCHAR(255) COMMENT '终端信息',
  result          TINYINT NOT NULL DEFAULT 1 COMMENT '1成功 0拒绝',
  deny_reason     VARCHAR(255) COMMENT '拒绝原因',
  is_anomaly      TINYINT NOT NULL DEFAULT 0 COMMENT '1异常标记',
  anomaly_reason  VARCHAR(255),
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_business (business_type, business_id),
  INDEX idx_user_time (user_id, created_at)
) ENGINE=InnoDB;
-- 注意：此表禁止普通管理员删除，只允许归档和备份。
```

## 15. 应收管理 `receivables`（原文档缺失财务子表，本次补充）

```sql
CREATE TABLE receivables (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  contract_id     BIGINT UNSIGNED NOT NULL COMMENT '来源合同',
  customer_id     BIGINT UNSIGNED NOT NULL,
  project_id      BIGINT UNSIGNED COMMENT '关联项目',
  receivable_no   VARCHAR(32) NOT NULL UNIQUE,
  amount          DECIMAL(14,2) NOT NULL COMMENT '应收金额',
  received_amount DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '已收金额',
  due_date        DATE NOT NULL COMMENT '应收账款到期日',
  invoice_no      VARCHAR(128) COMMENT '发票号',
  status          VARCHAR(16) NOT NULL DEFAULT 'pending' COMMENT 'pending/partial/completed/overdue/written_off',
  overdue_days    INT NOT NULL DEFAULT 0,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```

## 16. 预算 `budgets`（原文档缺失，本次补充）

```sql
CREATE TABLE budgets (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  budget_no       VARCHAR(32) NOT NULL UNIQUE,
  subject_type    VARCHAR(16) NOT NULL COMMENT 'project/dept/annual',
  project_id      BIGINT UNSIGNED,
  department_id   BIGINT UNSIGNED,
  year            SMALLINT COMMENT '年度预算时使用',
  period          VARCHAR(7) COMMENT '月度预算时使用',
  category        VARCHAR(64) COMMENT '预算科目（字典）',
  budget_amount   DECIMAL(14,2) NOT NULL COMMENT '预算金额',
  used_amount     DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '已使用金额',
  status          VARCHAR(16) NOT NULL DEFAULT 'active' COMMENT 'draft/active/closed',
  approved_by     BIGINT UNSIGNED,
  approved_at     DATETIME,
  remark          TEXT,
  created_by      BIGINT UNSIGNED,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by      BIGINT UNSIGNED,
  updated_at      DATETIME ON UPDATE CURRENT_TIMESTAMP,
  deleted_at      DATETIME
) ENGINE=InnoDB;
```
