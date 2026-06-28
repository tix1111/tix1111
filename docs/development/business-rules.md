# 业务规则补充文档

## 1. 编号规则

系统所有业务单据编号必须由服务端统一生成，不允许前端自定义。编号必须保证唯一且可追溯。

### 1.1 编号规则定义

在 `system_settings` 表中维护编号规则（`group_name = 'no_rules'`）：

```
no_rules.project      → P{YYYY}{MM}{SEQ5}   示例: P2025060001
no_rules.contract     → C{YYYY}{MM}{SEQ5}   示例: C2025060001
no_rules.engineering  → E{YYYY}{MM}{SEQ5}   示例: E2025060001
no_rules.work_order   → WO{YYYY}{MMDD}{SEQ4} 示例: WO202506150001
no_rules.reimbursement→ R{YYYY}{MMDD}{SEQ4} 示例: R202506150001
no_rules.payment      → PA{YYYY}{MMDD}{SEQ4} 示例: PA202506150001
no_rules.purchase     → PO{YYYY}{MMDD}{SEQ4} 示例: PO202506150001
no_rules.inquiry      → IQ{YYYY}{MMDD}{SEQ4} 示例: IQ202506150001
no_rules.customer     → CUS{YYYY}{SEQ5}     示例: CUS202500001
no_rules.supplier     → SUP{YYYY}{SEQ5}     示例: SUP202500001
no_rules.employee     → EMP{DEPT3}{SEQ4}    示例: EMPTR0001（其中TR为部门代码）
no_rules.material     → M{CATE3}{SEQ5}      示例: MELE00001
no_rules.settlement   → S{YYYY}{MMDD}{SEQ4} 示例: S202506150001
no_rules.change_order → EC{YYYY}{MM}{SEQ4}  示例: EC202506001
no_rules.party_check  → PC{YYYY}{MM}{SEQ3}  示例: PC202506001
no_rules.leak_incident→ LK{YYYY}{MM}{SEQ3}  示例: LK202506001
```

`SEQ{N}` 表示当天或当月从 1 开始的序号，补零到 N 位。

### 1.2 编号生成 PHP 实现

```php
// includes/no_generator.php

function generateNo(string $ruleKey): string {
    $db = DB::conn();
    
    // 使用 SELECT FOR UPDATE 防并发重复
    $db->beginTransaction();
    try {
        // 读取计数器（按前缀+日期分组）
        $prefix = buildPrefix($ruleKey);
        $row = DB::query(
            'SELECT id, current_seq FROM no_counters WHERE prefix = ? FOR UPDATE',
            [$prefix]
        );
        
        if (empty($row)) {
            DB::execute(
                'INSERT INTO no_counters (prefix, current_seq) VALUES (?, 1)',
                [$prefix]
            );
            $seq = 1;
        } else {
            $seq = $row[0]['current_seq'] + 1;
            DB::execute(
                'UPDATE no_counters SET current_seq = ? WHERE id = ?',
                [$seq, $row[0]['id']]
            );
        }
        
        $db->commit();
        return buildNo($ruleKey, $prefix, $seq);
    } catch (\Exception $e) {
        $db->rollBack();
        throw $e;
    }
}
```

### 1.3 编号计数器表 `no_counters`

```sql
CREATE TABLE no_counters (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  prefix      VARCHAR(32) NOT NULL UNIQUE COMMENT '编号前缀（含日期）',
  current_seq INT UNSIGNED NOT NULL DEFAULT 0,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

## 2. 财务科目体系

财务科目使用字典维护，`dict_type = 'account_subject'`：

| 一级 | 说明 | 包含子科目 |
| --- | --- | --- |
| 1001 | 库存现金 | — |
| 1002 | 银行存款 | 按账户拆分 |
| 1122 | 应收账款 | 按客户拆分 |
| 1221 | 其他应收款 | 员工借款、押金 |
| 1401 | 原材料 | 关联库存物料 |
| 2202 | 应付账款 | 按供应商拆分 |
| 2211 | 应付职工薪酬 | 工资、社保、公积金 |
| 2221 | 应交税费 | 增值税、个税 |
| 5001 | 主营业务收入 | 按项目/合同拆分 |
| 5101 | 其他业务收入 | — |
| 6001 | 主营业务成本 | 关联项目成本 |
| 6401 | 管理费用 | 关联部门 |
| 6402 | 销售费用 | 关联客户/商机 |
| 6403 | 财务费用 | — |

> 初期系统不需要完整实现总账、凭证，只需要报销/付款/应收/应付等业务台账，总账模块作为后续扩展。

## 3. 库存实时数量计算

库存实时数量不存储在独立字段，由库存流水聚合计算：

```sql
-- 查询物料 {material_id} 在仓库 {warehouse_id} 的实时库存
SELECT
  SUM(direction * qty) AS stock_qty
FROM inventory_records
WHERE material_id = ? AND warehouse_id = ?
  AND id <= ?  -- 截止到某条流水
;

-- 或直接查当前库存
SELECT
  SUM(direction * qty) AS stock_qty
FROM inventory_records
WHERE material_id = ? AND warehouse_id = ?;
```

**库存快照表**（性能优化，非必须）：

```sql
CREATE TABLE inventory_snapshots (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  material_id  BIGINT UNSIGNED NOT NULL,
  warehouse_id BIGINT UNSIGNED NOT NULL,
  qty          DECIMAL(14,4) NOT NULL,
  snapshot_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_mat_wh (material_id, warehouse_id)
) ENGINE=InnoDB;
```

每次库存操作后更新快照：

```php
// 插入库存流水后执行：
DB::execute(
  'INSERT INTO inventory_snapshots (material_id, warehouse_id, qty)
   VALUES (?, ?, (SELECT SUM(direction*qty) FROM inventory_records WHERE material_id=? AND warehouse_id=?))
   ON DUPLICATE KEY UPDATE qty = VALUES(qty), snapshot_at = NOW()',
  [$materialId, $warehouseId, $materialId, $warehouseId]
);
```

## 4. 合同到期预警与定时任务

### 4.1 到期预警规则

合同到期前 90/30/7 天分别触发提醒通知给合同负责人和部门管理员：

```php
// cron/contract_reminder.php（每天执行一次）
$alerts = DB::query(
    'SELECT c.*, u.phone, u.real_name
     FROM contracts c
     JOIN users u ON u.id = c.owner_id
     WHERE c.status = "active"
       AND c.end_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 90 DAY)
       AND c.deleted_at IS NULL'
);

foreach ($alerts as $c) {
    $days = (strtotime($c['end_date']) - time()) / 86400;
    if (in_array((int)$days, [90, 30, 7, 0])) {
        createMessage($c['owner_id'], 'contract', $c['id'], "合同《{$c['title']}》将于{$days}天后到期");
    }
}
```

### 4.2 推荐定时任务（cron）

```bash
# /etc/crontab 或宝塔面板定时任务
# 每天 09:00 执行合同到期提醒
0  9  * * *  php /path/to/cron/contract_reminder.php

# 每天 09:30 执行资质到期提醒（协作团队和供应商）
30 9  * * *  php /path/to/cron/qualification_reminder.php

# 每天 10:00 执行库存预警检查
0 10  * * *  php /path/to/cron/inventory_alert.php

# 每天 23:00 执行审批超时处理
0 23  * * *  php /path/to/cron/approval_timeout.php

# 每月 1 日 08:00 执行党费催缴提醒
0  8  1 * *  php /path/to/cron/party_dues_reminder.php

# 每天 00:00 更新合同逾期天数
0  0  * * *  php /path/to/cron/receivable_overdue.php
```

## 5. 数据导出规范

所有导出必须通过权限控制：

```php
// /api/{module}/export.php
requirePermission('{module}.export');

// 导出数量限制
$maxRows = 10000;
$data = DB::query('SELECT ... LIMIT ' . $maxRows);

// 记录导出日志
logOperation('export', '{module}', null, "导出" . count($data) . "条记录");

// 输出 CSV 或 Excel
header('Content-Type: application/vnd.ms-excel');
header('Content-Disposition: attachment; filename="export_' . date('YmdHis') . '.xlsx"');
```

导出字段不得包含：

1. 密码、密钥。
2. 密级高于导出人授权密级的字段。
3. 联系人家庭情况、社会关系（需要单独更高权限）。

## 6. 密码策略落地

```php
// includes/auth.php

function validatePassword(string $password): ?string {
    $minLen = (int)getSetting('security', 'password_min_length', 8);
    $complex = (int)getSetting('security', 'password_complexity', 1);
    
    if (mb_strlen($password) < $minLen) {
        return "密码长度不少于{$minLen}位";
    }
    if ($complex && !preg_match('/(?=.*[A-Z])(?=.*[a-z])(?=.*\d)/', $password)) {
        return '密码需包含大写字母、小写字母和数字';
    }
    // 检查是否和用户名相同
    return null;
}

function checkPasswordExpiry(int $userId): bool {
    $expireDays = (int)getSetting('security', 'password_expire_days', 90);
    if ($expireDays === 0) return false;
    
    $row = DB::query('SELECT updated_at FROM users WHERE id = ?', [$userId]);
    if (empty($row)) return false;
    
    $lastChange = strtotime($row[0]['updated_at']);
    return (time() - $lastChange) / 86400 >= $expireDays;
}
```

## 7. 供应商竞价规则详细说明

### 7.1 询价流程

1. 平台填写物料需求（物料、规格、数量、收货地址、要求到货日期）。
2. 选择询价供应商范围（指定供应商或按分类）。
3. 设置报价截止时间。
4. 系统发送询价通知给相关供应商账号。

### 7.2 供应商报价规则

1. 供应商可以对询价单中的部分商品报价，不必全部。
2. 未报价的商品不进入该供应商的比价。
3. 供应商只能看到自己的报价，不能查看其他供应商的报价。
4. 在截止时间前可以修改报价，截止后锁定。
5. 报价字段：单价、数量、税率、运费、交货期、备注。

### 7.3 平台比价规则

系统按以下默认规则生成比价清单（可在系统设置中配置）：

1. 默认规则：同等参数下，取有效报价中最低的含税总价，推荐对应供应商。
2. 综合评分规则（可选）：综合价格（60%）、历史履约（30%）、交货期（10%）。
3. 比价清单允许同一询价单拆分给多个供应商（不同商品可来自不同供应商）。
4. 比价结果必须保存报价快照（JSON），不随供应商后续改价变化。

### 7.4 一键下单规则

1. 一键下单将比价清单按供应商拆单。
2. 下单后自动生成多个采购订单（每个供应商一个）。
3. 所有订单统一进入审批，审批通过后批量通知供应商。
4. 供应商确认接单后状态变更为"备货中"。
5. 若某供应商订单被驳回，不影响其他供应商订单。
