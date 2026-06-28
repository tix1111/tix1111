# 协同联动与全链路编排设计

## 1. 设计目标

系统不是多个模块的简单集合，而是多个业务域通过事件、状态、待办、消息和回写规则组成的端到端闭环。

本设计用于解决：

1. 哪个模块触发事件。
2. 哪些模块订阅事件。
3. 哪些数据需要回写。
4. 哪些待办和消息需要生成。
5. 异常失败后如何补偿。
6. 重复触发如何保证幂等。

## 2. 全链路主流程

### 2.1 客户到项目到工程到回款

```text
客户档案
  -> 拜访记录
  -> 商机
  -> 项目立项审批
  -> 项目计划
  -> 合同起草/送审
  -> 工程创建
  -> 协作团队派工
  -> 材料申请
  -> 供应链采购
  -> 库存入库/出库/签收
  -> 工程施工日志
  -> 工程验收
  -> 工程结算
  -> 财务付款/收款
  -> 项目成本和利润分析
  -> 客户复购和服务
```

### 2.2 运维到工单到备件到知识库

```text
设备台账
  -> 运维计划
  -> 巡检记录
  -> 异常转工单
  -> 工单派工
  -> 协作团队/内部人员处理
  -> 备件领用
  -> 库存出库
  -> 工单验收
  -> SLA 统计
  -> 知识库沉淀
  -> 运维报表
```

### 2.3 供应链采购到库存到财务

```text
物料需求
  -> 采购申请
  -> 供应商询价/竞价
  -> 报价提交
  -> 比价清单
  -> 一键下单
  -> 采购订单审批
  -> 供应商发货
  -> 到货验收
  -> 库存入库/直发签收
  -> 付款申请
  -> 财务付款
  -> 供应商履约评价
```

## 3. 事件总线模型

系统使用 `business_events` 表作为轻量事件总线。

### 3.1 事件字段

| 字段 | 说明 |
| --- | --- |
| event_type | 事件类型，如 `project.approved` |
| business_type | 业务对象类型 |
| business_id | 业务对象 ID |
| actor_id | 触发人 |
| payload | 事件快照 |
| created_at | 触发时间 |

### 3.2 事件处理原则

1. 业务模块完成关键状态变化后写入 `business_events`。
2. 事件处理器读取未处理事件。
3. 根据事件类型执行联动动作。
4. 联动动作必须幂等。
5. 失败事件进入补偿队列。
6. 所有事件处理写入联动日志。

## 4. 核心事件清单

| 事件 | 触发模块 | 订阅模块 | 联动动作 |
| --- | --- | --- | --- |
| customer.visit.created | 客户管理 | 工作台、商机 | 生成下一步待办，可转商机 |
| opportunity.won | 客户管理 | 项目管理 | 创建项目草稿 |
| project.submitted | 项目管理 | 审批管理 | 创建立项审批 |
| project.approved | 审批管理/项目管理 | 合同、工程、工作台 | 通知项目负责人，可创建合同或工程 |
| contract.approved | 合同管理 | 财务、项目、工作台 | 生成履约计划、收付款提醒 |
| engineering.created | 工程管理 | 协作团队、库存 | 生成施工计划待办、材料计划待办 |
| engineering.plan.approved | 工程管理 | 协作团队、库存 | 创建派工草稿和物料申请 |
| engineering.team.assigned | 协作团队 | 工作台、工程 | 通知施工队伍 |
| engineering.site.entered | 工程管理 | 项目、工作台 | 工程状态变更为施工中 |
| engineering.material.requested | 工程管理 | 库存、供应链采购 | 库存不足时进入采购 |
| inventory.outbound.created | 库存管理 | 工程、项目成本 | 回写工程材料记录和项目成本 |
| purchase.order.approved | 供应链采购 | 供应商、库存、工作台 | 通知供应商供货 |
| purchase.order.received | 库存管理 | 财务、供应链采购 | 更新履约、可发起付款 |
| engineering.log.created | 工程管理 | 项目、工作台 | 更新工程进度，通知关注人 |
| engineering.hidden.accepted | 工程管理 | 工程、工作台 | 允许进入下一阶段 |
| engineering.accepted | 工程管理 | 项目、财务、培训 | 触发交付培训和结算 |
| engineering.settlement.approved | 工程管理 | 财务、项目成本 | 生成付款申请或成本归集 |
| work_order.created | 运维管理 | 工作台、协作团队 | 生成处理待办 |
| work_order.closed | 运维管理 | 知识库、报表 | 沉淀知识、更新 SLA |
| classified.object.created | 涉密管理 | 工作台、审计 | 通知责任人和授权人 |
| party.meeting.created | 党建管理 | 通知公告、工作台 | 发布通知、生成签到待办 |

## 5. 状态回写规则

| 来源事件 | 回写目标 | 回写字段 |
| --- | --- | --- |
| project.approved | projects | status=active, approval_status=approved |
| contract.approved | contracts | status=active, approval_status=approved |
| engineering.site.entered | engineering_items | status=constructing, actual_start |
| engineering.accepted | engineering_items | status=accepted, actual_end |
| engineering.settlement.approved | engineering_items | status=settled |
| inventory.outbound.created | project_costs | 新增 material 成本 |
| reimbursement.paid | project_costs | 新增 reimbursement 成本 |
| payment.paid | project_costs | 新增 payment 成本 |
| purchase.order.received | purchase_orders | status=received |
| supplier.performance.updated | suppliers | level 重新计算 |
| work_order.closed | devices | 如维修完成，status=normal |

## 6. 待办与消息生成规则

| 场景 | 待办接收人 | 消息 |
| --- | --- | --- |
| 审批任务创建 | 审批人 | 您有新的审批任务 |
| 项目立项通过 | 项目负责人 | 项目已通过，可编制计划 |
| 工程计划待确认 | 工程负责人 | 请确认施工计划 |
| 团队派工 | 团队负责人/成员 | 您有新的工程任务 |
| 材料待出库 | 仓库管理员 | 工程材料待出库 |
| 采购订单审批通过 | 供应商账号 | 您有新的采购订单 |
| 工程待验收 | 验收人 | 工程待验收 |
| 工程整改 | 整改责任人 | 您有整改任务 |
| 合同即将到期 | 合同负责人 | 合同到期提醒 |
| 涉密异常访问 | 涉密管理员 | 涉密异常告警 |

## 7. 幂等设计

事件处理必须幂等，避免重复消息、重复成本、重复出库。

### 7.1 幂等键

建议使用：

```text
event_type + business_type + business_id + target_type + target_id
```

### 7.2 联动任务表 `event_tasks`

```sql
CREATE TABLE event_tasks (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  event_id       BIGINT UNSIGNED NOT NULL,
  task_key       VARCHAR(255) NOT NULL UNIQUE,
  task_type      VARCHAR(64) NOT NULL COMMENT 'todo/message/cost/update/callback',
  target_type    VARCHAR(64),
  target_id      BIGINT UNSIGNED,
  status         VARCHAR(16) NOT NULL DEFAULT 'pending',
  retry_count    TINYINT NOT NULL DEFAULT 0,
  last_error     TEXT,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  processed_at   DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## 8. 异常补偿

### 8.1 失败原因

1. 数据库锁冲突。
2. 目标业务数据被删除或状态变化。
3. 外部账号或用户不存在。
4. 附件或涉密授权校验失败。
5. 业务规则冲突，如预算超限。

### 8.2 重试规则

| 失败类型 | 重试 |
| --- | --- |
| 数据库锁冲突 | 自动重试 3 次 |
| 短暂网络失败 | 自动重试 3 次 |
| 业务规则冲突 | 不自动重试，进入人工处理 |
| 权限/涉密校验失败 | 不重试，记录告警 |

### 8.3 补偿操作

| 场景 | 补偿 |
| --- | --- |
| 付款成功但项目成本未写入 | 重新触发成本归集任务 |
| 出库成功但工程材料未回写 | 重新回写工程材料记录 |
| 审批通过但业务状态未更新 | 调用业务模块状态同步接口 |
| 供应商订单通知失败 | 重发通知，超过 3 次人工处理 |

## 9. 事件处理器伪代码

```php
function handlePendingEvents() {
    $events = DB::query('SELECT * FROM business_events WHERE processed_at IS NULL ORDER BY id ASC LIMIT 100');
    foreach ($events as $event) {
        try {
            DB::conn()->beginTransaction();
            $tasks = buildTasksFromEvent($event);
            foreach ($tasks as $task) {
                if (eventTaskExists($task['task_key'])) {
                    continue;
                }
                insertEventTask($event['id'], $task);
                executeEventTask($task);
            }
            markEventProcessed($event['id']);
            DB::conn()->commit();
        } catch (Throwable $e) {
            DB::conn()->rollBack();
            recordEventError($event['id'], $e->getMessage());
        }
    }
}
```

## 10. 全链路测试场景

### 10.1 客户到工程到回款

1. 新增客户。
2. 新增拜访记录。
3. 创建商机。
4. 商机转项目。
5. 项目立项审批通过。
6. 创建合同并审批。
7. 创建工程。
8. 施工计划确认。
9. 协作团队派工。
10. 材料申请。
11. 供应链采购。
12. 库存入库/出库。
13. 施工日志。
14. 隐蔽验收。
15. 工程验收。
16. 工程结算。
17. 财务付款/收款。
18. 项目成本报表更新。

### 10.2 运维到知识库

1. 设备巡检异常。
2. 自动生成工单。
3. 工单派工。
4. 备件领用。
5. 工单处理。
6. 工单关闭。
7. 生成知识库条目。
8. SLA 报表更新。

## 11. 监控指标

| 指标 | 说明 |
| --- | --- |
| pending_event_count | 未处理事件数量 |
| failed_event_count | 处理失败事件数量 |
| event_retry_count | 重试次数 |
| duplicate_event_count | 幂等拦截次数 |
| todo_generate_count | 待办生成数量 |
| message_generate_count | 消息生成数量 |
| event_process_avg_ms | 事件平均处理耗时 |

## 12. 开发约束

1. 业务模块不得直接修改其他模块主表，必须通过事件或明确 API。
2. 回写必须记录 `business_events` 和 `operation_logs`。
3. 成本、库存、付款等关键回写必须事务处理。
4. 涉密事件只推送元数据，不推送涉密正文。
5. 所有联动任务必须有幂等键。
