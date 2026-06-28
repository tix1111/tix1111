# API 接口规格文档

## 1. 全局规范

### 1.1 基础规则

- 所有接口放在 `/api/` 目录下，PHP 文件形式。
- 所有 POST/PUT/DELETE 请求必须携带 CSRF Token（请求头 `X-CSRF-Token`）。
- 所有响应使用统一 JSON 格式，`Content-Type: application/json; charset=utf-8`。
- 列表接口支持分页（`page` + `page_size`），默认 20 条。
- 所有写操作必须记录操作日志。

### 1.2 通用请求参数

列表接口：

```
page          INT    当前页，默认 1
page_size     INT    每页条数，默认 20，最大 100
order_by      STRING 排序字段
order_dir     STRING asc / desc
```

### 1.3 通用响应格式

```json
{
  "code":    0,
  "message": "success",
  "data": {
    "total": 100,
    "page":  1,
    "page_size": 20,
    "list": [...]
  }
}
```

### 1.4 权限错误码

| code | 说明 |
| --- | --- |
| 2001 | 未登录 |
| 3002 | 无操作权限 |
| 3003 | 无数据权限 |
| 3004 | 无密级权限 |

## 2. 认证模块 `/api/auth/`

### POST `/api/auth/login.php`

```
请求：username, password, captcha_code, captcha_session
响应：{ user, permissions[], menus[], token_csrf }
```

### POST `/api/auth/register.php`

```
请求：username, password, phone, sms_code
权限：无需登录
```

### POST `/api/auth/forgot-password.php`

```
请求：username, phone, sms_code, new_password, confirm_password
权限：无需登录
```

### GET `/api/auth/captcha.php`

```
响应：图形验证码图片（image/png）及 session_id
```

### POST `/api/auth/sms.php`

```
请求：phone, type（register/forgot_password）
限制：同一手机号 60 秒内只能发一次
```

### GET `/api/auth/me.php`

```
响应：当前用户信息、角色、权限点列表、菜单树
```

### POST `/api/auth/logout.php`

```
响应：清除会话
```

### POST `/api/auth/change-password.php`

```
请求：old_password, new_password, confirm_password
权限：登录即可
```

## 3. 菜单与权限 `/api/system/`

### GET `/api/menus/tree.php`

```
响应：当前用户的菜单树（JSON 树形结构）
权限：登录即可
```

### GET `/api/system/users/list.php`

```
参数：keyword, department_id, role_id, status, page
权限：system.user.view
```

### POST `/api/system/users/save.php`

```
请求：username, phone, real_name, department_id, role_ids[]
权限：system.user.create / system.user.update
```

### GET `/api/system/roles/list.php`

```
权限：system.role.view
```

### GET `/api/system/events/tasks.php`

```
参数：status, task_type, event_type, page
权限：system.event_task.view
响应：跨模块联动任务列表，用于查看失败、重试、幂等处理状态
```

### POST `/api/system/events/retry.php`

```
请求：task_id
权限：system.event_task.retry
动作：重试失败的联动任务
```

### GET `/api/system/consistency/check.php`

```
参数：type（inventory/project_cost/approval/engineering/supplier/classified/all）
权限：system.consistency.check
动作：执行数据一致性检查，写入 consistency_check_logs
```

### GET `/api/system/consistency/list.php`

```
参数：check_type, status, severity, page
权限：system.consistency.view
响应：一致性检查异常列表
```

### POST `/api/system/roles/save.php`

```
请求：name, code, description, menu_ids[], permission_ids[], scope_type
权限：system.role.manage
```

### GET `/api/ref/departments.php`

```
参数：keyword
响应：[{id, name, parent_id}]，按数据范围过滤
```

### GET `/api/ref/employees.php`

```
参数：keyword, department_id
响应：[{id, emp_no, real_name, title, department_name}]
```

### GET `/api/ref/projects.php`

```
参数：keyword
响应：[{id, project_no, name}]，只返回用户参与的项目
```

### GET `/api/ref/customers.php`

```
参数：keyword（模糊搜索名称/编号）
响应：[{id, customer_no, name, level}]
```

### GET `/api/ref/contracts.php`

```
参数：keyword, type, status
响应：[{id, contract_no, title, amount}]
```

### GET `/api/ref/materials.php`

```
参数：keyword, category
响应：[{id, material_no, name, unit, spec}]
```

### GET `/api/ref/suppliers.php`

```
参数：keyword, status=active
响应：[{id, supplier_no, name}]
```

### GET `/api/ref/dictionary.php`

```
参数：type（字典类型编码，如 expense_category）
响应：[{value, label, color, sort}]
```

## 4. 工作台 `/api/workbench/`

### GET `/api/workbench/summary.php`

```
响应：{
  todo_count, msg_count,
  recent_todos[], recent_messages[],
  metrics: { 按角色返回不同指标 }
}
```

### GET `/api/workbench/todos.php`

```
参数：type, status, page
响应：待办列表
```

### GET `/api/workbench/counts.php`

```
响应：{ todo_count: N, msg_count: N }
用途：轮询接口，轻量
```

### GET `/api/workbench/messages.php`

```
参数：is_read, page
响应：消息列表
```

### POST `/api/workbench/messages/read.php`

```
请求：ids[] 或 all=1
响应：标记已读
```

## 5. 审批管理 `/api/approval/`

### GET `/api/approval/tasks.php`

```
参数：tab（my_todo/my_initiated/my_done/cc_me）, business_type, keyword, page
响应：审批任务列表
```

### POST `/api/approval/tasks/action.php`

```
请求：task_id, action（approve/reject/transfer/countersign/withdraw）, comment, transfer_to（转交时）
权限：当前任务处理人
```

### GET `/api/approval/flows/list.php`

```
权限：approval.flow.view
响应：审批流程配置列表
```

### POST `/api/approval/flows/save.php`

```
请求：name, business_type, nodes[]（包含节点定义）
权限：approval.flow.manage
```

### GET `/api/approval/reports/summary.php`

```
参数：date_from, date_to, business_type, department_id
权限：approval.report.view
```

## 6. 客户管理 `/api/customers/`

### GET `/api/customers/list.php`

```
参数：keyword, level, status, owner_id, industry, region, page
权限：customer.view
```

### GET `/api/customers/detail.php`

```
参数：id
权限：customer.detail
响应：客户全景（基础信息、最近拜访、商机、合同、回款）
```

### POST `/api/customers/save.php`

```
请求：customer_no（编辑时）, name, type, industry...
权限：customer.create / customer.update
```

### GET `/api/customers/contacts/list.php`

```
参数：customer_id, page
权限：customer.contact.view
```

### POST `/api/customers/contacts/save.php`

```
请求：customer_id, name, title, phone, influence_level...
权限：customer.contact.manage
注意：敏感字段（family_info 等）需要 customer.contact.sensitive 权限
```

### GET `/api/customers/visits/list.php`

```
参数：customer_id, visitor_id, date_from, date_to, page
权限：customer.visit.view
```

### POST `/api/customers/visits/save.php`

```
请求：customer_id, visit_date, contact_ids[], content, result, next_action...
权限：customer.visit.manage
```

### POST `/api/customers/handover/generate.php`

```
请求：customer_id, to_owner_id, reason
权限：customer.handover
响应：生成并返回交接包数据
```

### GET `/api/customers/opportunities/list.php`

```
参数：customer_id, stage, owner_id, page
权限：opportunity.view
```

### POST `/api/customers/opportunities/convert.php`

```
请求：opportunity_id, type（project/contract）
权限：opportunity.manage
响应：创建对应项目或合同
```

## 7. 项目管理 `/api/projects/`

### GET `/api/projects/list.php`

```
参数：keyword, status, owner_id, customer_id, date_from, date_to, page
权限：project.view
数据范围：参与项目
```

### POST `/api/projects/create.php`

```
请求：name, type, customer_id, owner_id, budget, start_date, end_date...
权限：project.create
动作：创建项目 → 发起立项审批
```

### GET `/api/projects/costs/summary.php`

```
参数：project_id
权限：project.cost.view
响应：{ budget, by_type: [{type, amount}], total_used, deviation_rate }
```

### POST `/api/projects/changes/submit.php`

```
请求：project_id, type, reason, cost_impact, days_impact...
权限：project.change
动作：创建变更记录 → 发起审批
```

## 8. 财务管理 `/api/finance/`

### GET `/api/finance/reimbursements/list.php`

```
参数：applicant_id, project_id, expense_category, status, date_from, date_to, page
权限：finance.reimburse.view
```

### POST `/api/finance/reimbursements/create.php`

```
请求：project_id, expense_category, total_amount, description, invoices[]
权限：finance.reimburse.create
```

### POST `/api/finance/reimbursements/submit.php`

```
请求：reimbursement_id
权限：报销人本人
动作：提交 → 发起审批
```

### POST `/api/finance/reimbursements/pay.php`

```
请求：reimbursement_id, paid_amount, paid_at
权限：finance.reimburse.pay
动作：确认付款 → 回写项目成本
```

### GET `/api/finance/payment-requests/list.php`

```
参数：pay_type, supplier_id, contract_id, status, page
权限：finance.payable.view
```

## 9. 库存管理 `/api/inventory/`

### GET `/api/inventory/stock/query.php`

```
参数：material_id, warehouse_id, min_qty（仅低于此值的结果）
权限：inventory.stock.view
```

### POST `/api/inventory/inbound/create.php`

```
请求：material_id, warehouse_id, qty, unit_price, source_type, source_id, batch_no...
权限：inventory.inbound
动作：写入流水 → 更新快照
```

### POST `/api/inventory/outbound/create.php`

```
请求：material_id, warehouse_id, qty, source_type, source_id, project_id...
权限：inventory.outbound
前置：校验库存是否充足
动作：写入流水 → 更新快照 → 触发项目成本事件
```

### GET `/api/inventory/alerts/list.php`

```
权限：inventory.stock.view
响应：库存低于 min_stock 的物料列表
```

## 10. 供应链采购 `/api/suppliers/`

### GET `/api/suppliers/list.php`

```
参数：keyword, status, level, page
权限：supplier.view（平台账号）
```

### GET `/api/suppliers/portal/dashboard.php`

```
权限：供应商账号（account_type=1）
响应：本供应商的报价单、采购订单、履约记录
```

### POST `/api/suppliers/quotations/submit.php`

```
请求：inquiry_id, items[{product_id, unit_price, tax_rate...}], freight, lead_days, valid_until
权限：供应商账号且已接到询价邀请
前置：截止时间未到
```

### POST `/api/suppliers/compare/generate.php`

```
请求：inquiry_id, rule（lowest_price/score），force_regenerate=0/1
权限：purchase.compare
响应：生成并保存比价清单，返回结果
```

### POST `/api/suppliers/orders/create.php`

```
请求：compare_id（来自比价清单）
权限：purchase.order
动作：生成采购订单（按供应商拆单）→ 发起审批
```

### POST `/api/suppliers/orders/notify.php`

```
请求：order_ids[]
权限：审批通过后才可调用
动作：发送通知给供应商账号 → 更新状态为 confirmed
```

## 11. 工程管理 `/api/engineering/`

### GET `/api/engineering/items/list.php`

```
参数：type, project_id, owner_id, status, page
权限：engineering.view
```

### POST `/api/engineering/items/create.php`

```
请求：name, type, project_id, owner_id, plan_start, plan_end, budget...
权限：engineering.create
动作：可选发起立项审批
```

### POST `/api/engineering/plans/save.php`

```
请求：engineering_id, scope, milestones[], team_ids[], material_needs[], risk_notes
权限：engineering.plan.manage
动作：保存施工计划，生成材料需求和团队派工草稿
```

### POST `/api/engineering/teams/assign.php`

```
请求：engineering_id, team_id, member_ids[], roles[], plan_start, plan_end
权限：engineering.team.assign
动作：从协作团队中选择施工队伍，生成工程团队记录和派工待办
```

### POST `/api/engineering/site-entry/confirm.php`

```
请求：engineering_id, entry_date, member_ids[], site_condition, customer_confirm_user, photos[]
权限：engineering.site_entry
前置：施工计划已确认、团队已派工、安全交底已完成
动作：记录进场并将工程状态更新为 mobilized 或 constructing
```

### POST `/api/engineering/materials/request.php`

```
请求：engineering_id, items[{material_id, qty, usage}], required_date
权限：engineering.material.request
动作：生成物料申请，库存不足时进入供应链采购
```

### POST `/api/engineering/materials/sign.php`

```
请求：engineering_id, inventory_record_id, material_id, signed_qty, photos[], remark
权限：engineering.material.sign
动作：确认现场签收，回写工程材料记录
```

### POST `/api/engineering/materials/return.php`

```
请求：engineering_id, material_id, return_qty, reason, photos[]
权限：engineering.material.return
动作：生成退料记录，库存办理入库
```

### POST `/api/engineering/logs/submit.php`

```
请求：engineering_id, log_date, content, weather, workers, materials_used...
权限：engineering.log.submit
```

### POST `/api/engineering/logs/share-create.php`

```
请求：engineering_id, date_from, date_to, viewer_name, viewer_org, viewer_phone, include_photos, include_materials, include_issues, allow_download, expired_at
权限：engineering.log.share
前置：工程负责人或授权管理员；若工程涉密，必须先通过涉密外发/借阅审批
动作：生成随机 token，保存 token_hash，返回一次性明文分享链接
```

### GET `/api/engineering/logs/share-view.php`

```
请求：token
权限：无需登录，但必须校验 token、有效期、状态、IP频率、涉密规则
响应：第三方可见的施工日志数据（脱敏、按范围过滤）
动作：记录 engineering_log_share_access_logs
```

### POST `/api/engineering/logs/share-revoke.php`

```
请求：share_id
权限：engineering.log.share_revoke
动作：撤销分享链接，更新 revoked_at 和 status=revoked
```

### GET `/api/engineering/logs/share-access-logs.php`

```
请求：share_id
权限：engineering.log.share_audit
响应：第三方访问记录
```

### POST `/api/engineering/quality/rectify.php`

```
请求：issue_id, rectification, photos[], completed_at
权限：engineering.quality.rectify
动作：提交质量安全整改结果，等待复查
```

### POST `/api/engineering/hidden-acceptance/submit.php`

```
请求：engineering_id, stage_name, check_items[], result, photos[], acceptor_ids[]
权限：engineering.hidden_acceptance
前置：隐蔽工程覆盖前提交
动作：生成隐蔽验收记录，不通过则生成整改待办
```

### POST `/api/engineering/changes/submit.php`

```
请求：engineering_id, type, reason, content, cost_impact, days_impact
权限：engineering.change
动作：创建变更签证 → 发起审批 → 审批通过后回写项目成本
```

### POST `/api/engineering/acceptance/submit.php`

```
请求：engineering_id, result, issues, corrective_actions
权限：engineering.acceptance
动作：创建验收记录 → 通过后可关闭工程
```

### POST `/api/engineering/settlements/submit.php`

```
请求：engineering_id, workload_items[], material_cost, team_cost, change_amount, total_amount
权限：engineering.settlement
前置：工程已验收，材料已签收或退料，变更签证已处理
动作：生成工程结算，审批通过后进入财务付款或成本归集
```

## 12. 协作团队 `/api/collaboration/`

### GET `/api/collaboration/teams/list.php`

```
参数：type, status, level, keyword, page
权限：collaboration.team.view
```

### POST `/api/collaboration/assignments/create.php`

```
请求：team_id, source_type, source_id, task_type, task_desc, member_ids[], plan_start, plan_end
权限：collaboration.assignment
可选：approval_required=1 时发起审批
```

### POST `/api/collaboration/execution/submit.php`

```
请求：assignment_id, record_date, content, work_hours, photos[]
权限：被派工人员或团队负责人
动作：提交执行记录 → 回写来源模块进度
```

### POST `/api/collaboration/settlements/submit.php`

```
请求：assignment_id, amount, basis
权限：collaboration.settlement
动作：创建结算单 → 发起审批 → 通过后创建付款申请
```

## 13. 党建管理 `/api/party/`

### GET `/api/party/organizations/list.php`

```
权限：party.org.view
响应：党组织树形结构
```

### GET `/api/party/members/list.php`

```
参数：party_org_id, member_type, status, page
权限：party.member.view（普通党员仅查自己）
```

### POST `/api/party/developments/submit.php`

```
请求：employee_id, party_org_id, stage, stage_date, notes, trainer_id
权限：party.member.develop
动作：记录发展阶段 → 可触发审批
```

### GET `/api/party/meetings/list.php`

```
参数：party_org_id, type, date_from, date_to, page
权限：party.meeting.view
```

### POST `/api/party/dues/generate.php`

```
请求：party_org_id, period
权限：party.dues.manage
动作：按党员和缴费标准生成当期党费记录
```

### POST `/api/party/dues/pay.php`

```
请求：due_id, paid_amount, pay_date
权限：party.dues.manage（支部管理员）
```

### GET `/api/party/reports/summary.php`

```
权限：party.report.view
响应：党员人数、组织生活次数、党费统计
```

## 14. 涉密管理 `/api/classified/`

### GET `/api/classified/objects/list.php`

```
参数：business_type, classification_status, security_level, page
权限：classified.object.view
额外校验：密级授权
```

### POST `/api/classified/requests/submit.php`

```
请求：request_type, business_type, business_id, requested_level, reason
权限：classified.request.create
动作：发起定密/变更/解密审批
```

### POST `/api/classified/objects/grant.php`

```
请求：object_id, user_id, access_level, valid_until
权限：classified.grant（涉密管理员）
```

### POST `/api/classified/borrow/submit.php`

```
请求：object_id（文件）或 carrier_id（载体）, borrow_type, purpose, expected_return
权限：classified.borrow.request
动作：发起借阅/外发审批 → 通过后更新借阅状态
```

### GET `/api/classified/audit/list.php`

```
参数：user_id, business_type, action, is_anomaly, date_from, date_to, page
权限：classified.audit.view
限制：普通管理员只能查，不能删除
```

### GET `/api/classified/alerts/list.php`

```
权限：classified.audit.view
响应：最近 24 小时异常访问告警
```

## 15. 运维管理 `/api/ops/`

### POST `/api/ops/work-orders/dispatch.php`

```
请求：order_id, assignee_id, team_id（二选一）
权限：ops.dispatch
动作：更新分配人/团队 → 发送通知 → 记录响应时间
```

### POST `/api/ops/work-orders/close.php`

```
请求：order_id, close_comment, satisfaction（1-5）
权限：ops.work_order.close（验收人或管理员）
前置：status = resolved
动作：关闭工单 → 计算 SLA 达标 → 知识库录入提示
```

### POST `/api/ops/knowledge/save.php`

```
请求：title, symptom, root_cause, solution, device_types, tags
权限：ops.knowledge.manage
```

## 16. 文件管理 `/api/files/`

### POST `/api/files/upload.php`

```
请求：multipart/form-data
参数：file, business_type, business_id, security_level（默认0）
权限：file.upload
校验：文件类型白名单、大小、MIME
响应：{ attachment_id, file_name, file_size }
```

### GET `/api/files/download.php`

```
参数：id（attachment_id）
权限：file.download + 业务数据权限 + 密级鉴权
动作：校验通过后 readfile() 输出文件流
日志：记录下载日志（涉密附件写 classified_audit_logs）
```

### GET `/api/files/preview.php`

```
参数：id
权限：file.view + 密级鉴权
说明：PDF、图片预览，同样记录预览日志
```

### DELETE `/api/files/delete.php`

```
参数：id
权限：file.delete + 业务数据权限
限制：涉密附件原则上不允许物理删除，使用软删除
```
