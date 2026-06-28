# 涉密含党支部企业管理系统需求文档

> 本文件由根目录 `需求文档.md` 拆分而来，便于 GitHub 直接预览。完整总览请查看 `../../REQUIREMENTS.md`。

## 10. API 设计规范

### 10.1 路径规范

所有接口统一放在 `/api` 路径下，例如：

| API | 说明 |
| --- | --- |
| `/api/auth/login.php` | 登录 |
| `/api/auth/register.php` | 注册 |
| `/api/auth/captcha.php` | 获取验证码 |
| `/api/auth/forgot-password.php` | 找回密码 |
| `/api/auth/logout.php` | 退出登录 |
| `/api/auth/me.php` | 当前用户信息 |
| `/api/menus/tree.php` | 当前用户菜单树 |
| `/api/modules/list.php` | 模块列表 |
| `/api/roles/list.php` | 角色列表 |
| `/api/users/list.php` | 用户列表 |
| `/api/approvals/list.php` | 审批列表 |
| `/api/projects/list.php` | 项目列表 |
| `/api/notices/list.php` | 通知公告列表 |
| `/api/party/organizations/list.php` | 党组织列表 |
| `/api/party/members/list.php` | 党员列表 |
| `/api/classified/objects/list.php` | 涉密对象列表 |
| `/api/classified/audit/list.php` | 涉密审计列表 |
| `/api/collaboration/teams/list.php` | 协作团队列表 |
| `/api/suppliers/list.php` | 供应商列表 |
| `/api/suppliers/products/list.php` | 供应商商品列表 |

### 10.2 返回格式

```json
{
  "code": 0,
  "message": "success",
  "data": {}
}
```

错误示例：

```json
{
  "code": 403,
  "message": "无权限访问",
  "data": null
}
```

### 10.3 API 安全

1. 所有写操作必须校验登录态和 CSRF Token。
2. 所有 SQL 使用预处理语句。
3. 所有上传文件校验类型、大小、后缀和实际 MIME。
4. 所有接口统一记录操作日志。
5. 权限校验放在 API 层，不依赖前端菜单隐藏。

### 10.4 API 分层建议

API 按职责分层，避免一个接口同时处理菜单、审批、业务和统计：

| API 分组 | 职责 | 示例 |
| --- | --- | --- |
| `/api/auth` | 登录、注册、验证码、会话 | `/api/auth/login.php` |
| `/api/system` | 用户、角色、模块、菜单、字典、参数 | `/api/system/users/list.php` |
| `/api/workbench` | 工作台聚合、待办、消息、快捷入口 | `/api/workbench/summary.php` |
| `/api/approval` | 流程定义、审批实例、审批任务 | `/api/approval/tasks.php` |
| `/api/business` | 通用业务引用和关联查询 | `/api/business/relations.php` |
| `/api/files` | 附件上传、预览、下载、访问日志 | `/api/files/upload.php` |
| `/api/reports` | 报表、统计、看板 | `/api/reports/project-cost.php` |
| `/api/party` | 党组织、党员、党员发展、组织生活、党费、党建台账 | `/api/party/members/list.php` |
| `/api/classified` | 密级、涉密对象、载体、定密、借阅外发、保密检查、涉密审计 | `/api/classified/objects/list.php` |
| `/api/collaboration` | 协作团队、人员、公司、资质、派工、执行记录、评价、结算 | `/api/collaboration/teams/list.php` |
| `/api/suppliers` | 供应商、入驻、商品、询价、竞价、报价、比价、订单、履约评价 | `/api/suppliers/list.php` |

业务模块可按模块继续拆分，例如 `/api/projects`、`/api/contracts`、`/api/inventory`、`/api/party`、`/api/classified`、`/api/collaboration`、`/api/suppliers`。

### 10.5 业务单据与审批 API 协作

以费用报销为例：

1. 前端调用 `/api/finance/reimbursements/create.php` 创建报销草稿。
2. 前端调用 `/api/files/upload.php` 上传发票和附件，附件绑定 `business_type=reimbursement` 和报销单 ID。
3. 前端调用 `/api/finance/reimbursements/submit.php` 提交报销单。
4. 报销 API 校验业务字段和权限后，调用审批服务创建审批实例。
5. 审批任务进入 `/api/approval/tasks.php` 和 `/api/workbench/todos.php`。
6. 审批通过后，审批服务回调或标记报销单为 `approved`。
7. 财务人员在财务模块确认付款或入账。
8. 入账事件写入 `business_events`，项目成本统计按事件汇总。

关键要求：

1. 业务模块负责校验业务字段。
2. 审批模块负责校验审批动作。
3. 工作台只聚合待办和消息，不直接改变业务单据。
4. 报表接口只读取已授权范围内的数据。

### 10.6 统一引用数据 API

为了避免页面写死下拉框和测试数据，应提供统一引用接口：

| 接口 | 用途 |
| --- | --- |
| `/api/ref/departments.php` | 部门下拉 |
| `/api/ref/employees.php` | 员工下拉 |
| `/api/ref/projects.php` | 项目下拉 |
| `/api/ref/contracts.php` | 合同下拉 |
| `/api/ref/customers.php` | 客户下拉 |
| `/api/ref/materials.php` | 物料下拉 |
| `/api/ref/collaboration-teams.php` | 协作团队下拉 |
| `/api/ref/suppliers.php` | 供应商下拉 |
| `/api/ref/supplier-products.php` | 供应商商品下拉 |
| `/api/ref/dictionary.php?type=expense_category` | 字典项下拉 |
| `/api/ref/party-organizations.php` | 党组织下拉 |
| `/api/ref/security-levels.php` | 密级下拉 |

引用接口必须执行权限过滤，例如普通用户只能选择本人参与的项目，部门管理员只能选择本部门授权项目。

### 10.7 党建管理 API 建议

| API | 说明 |
| --- | --- |
| `/api/party/organizations/list.php` | 党组织列表 |
| `/api/party/organizations/save.php` | 新增或编辑党组织 |
| `/api/party/members/list.php` | 党员列表 |
| `/api/party/members/detail.php` | 党员详情 |
| `/api/party/developments/submit.php` | 提交党员发展流程 |
| `/api/party/meetings/list.php` | 三会一课列表 |
| `/api/party/activities/list.php` | 主题党日活动列表 |
| `/api/party/dues/list.php` | 党费记录 |
| `/api/party/ledgers/list.php` | 党建台账 |
| `/api/party/reports/summary.php` | 党建统计 |

党建 API 必须复用员工、附件、通知、培训和涉密权限，不重复建设员工主档案、附件上传和通知发布能力。

### 10.8 涉密管理 API 建议

| API | 说明 |
| --- | --- |
| `/api/classified/levels/list.php` | 密级规则列表 |
| `/api/classified/objects/list.php` | 涉密对象列表 |
| `/api/classified/objects/grant.php` | 涉密对象授权 |
| `/api/classified/requests/submit.php` | 提交定密、变更密级或解密申请 |
| `/api/classified/files/list.php` | 涉密文件列表 |
| `/api/classified/carriers/list.php` | 涉密载体列表 |
| `/api/classified/borrow/submit.php` | 借阅或外发申请 |
| `/api/classified/checks/list.php` | 保密检查列表 |
| `/api/classified/incidents/list.php` | 泄密事件列表 |
| `/api/classified/audit/list.php` | 涉密审计日志 |
| `/api/classified/alerts/list.php` | 涉密异常告警 |

涉密 API 的校验顺序为：登录态 -> 菜单/API 权限 -> 数据范围 -> 密级授权 -> 知悉范围 -> 操作级审批。任何一步失败都应返回明确错误码并写入审计日志。

### 10.9 协作团队管理 API 建议

| API | 说明 |
| --- | --- |
| `/api/collaboration/teams/list.php` | 协作团队列表 |
| `/api/collaboration/teams/save.php` | 新增或编辑团队 |
| `/api/collaboration/members/list.php` | 团队成员列表 |
| `/api/collaboration/companies/list.php` | 外部公司列表 |
| `/api/collaboration/qualifications/list.php` | 资质列表 |
| `/api/collaboration/assignments/create.php` | 创建团队派工 |
| `/api/collaboration/assignments/list.php` | 派工列表 |
| `/api/collaboration/execution/submit.php` | 提交执行记录 |
| `/api/collaboration/evaluations/submit.php` | 提交团队评价 |
| `/api/collaboration/settlements/submit.php` | 提交团队结算 |

协作团队 API 必须支持来源模块和来源单据字段，例如项目、工程、运维工单、客户商机。内部人员通过员工 ID 引用，外部人员和外部公司使用协作团队档案。

### 10.10 供应链采购管理 API 建议

| API | 说明 |
| --- | --- |
| `/api/suppliers/onboarding/submit.php` | 提交供应商入驻申请 |
| `/api/suppliers/onboarding/review.php` | 审核供应商入驻 |
| `/api/suppliers/list.php` | 供应商列表 |
| `/api/suppliers/detail.php` | 供应商详情 |
| `/api/suppliers/products/list.php` | 供应商商品列表 |
| `/api/suppliers/products/save.php` | 供应商商品新增或编辑 |
| `/api/suppliers/inquiries/create.php` | 创建询价单 |
| `/api/suppliers/bids/create.php` | 创建竞价单 |
| `/api/suppliers/quotations/submit.php` | 供应商提交报价 |
| `/api/suppliers/compare/generate.php` | 生成比价清单 |
| `/api/suppliers/orders/create.php` | 根据比价清单一键下单 |
| `/api/suppliers/orders/approve.php` | 采购订单审批 |
| `/api/suppliers/orders/notify.php` | 通知供应商供货 |
| `/api/suppliers/performance/submit.php` | 提交履约评价 |

供应商 API 必须区分平台后台账号和供应商后台账号。供应商账号只能维护本供应商资料、商品、报价和订单反馈，不能查看其他供应商报价明细；平台管理员可查看比价结果和生成采购方案。

### 10.11 客户管理 API 建议

| API | 说明 |
| --- | --- |
| `/api/customers/list.php` | 客户列表 |
| `/api/customers/detail.php` | 客户详情和客户全景 |
| `/api/customers/contacts/list.php` | 联系人画像列表 |
| `/api/customers/relationships/map.php` | 客户关系图谱 |
| `/api/customers/visits/list.php` | 拜访记录 |
| `/api/customers/business-activities/list.php` | 商务活动记录 |
| `/api/customers/opportunities/list.php` | 客户商机 |
| `/api/customers/handover/generate.php` | 生成客户交接包 |
| `/api/customers/handover/confirm.php` | 确认客户交接 |

客户管理 API 必须按客户负责人、协同人员、部门和数据权限过滤。联系人画像、家庭情况、社会关系等敏感字段需要独立权限和访问日志。

### 10.12 运维管理 API 建议

| API | 说明 |
| --- | --- |
| `/api/ops/devices/list.php` | 设备台账 |
| `/api/ops/plans/list.php` | 运维计划 |
| `/api/ops/inspections/list.php` | 巡检记录 |
| `/api/ops/work-orders/list.php` | 工单列表 |
| `/api/ops/work-orders/dispatch.php` | 工单派工 |
| `/api/ops/sla/list.php` | SLA 规则 |
| `/api/ops/spare-parts/usage.php` | 备件使用记录 |
| `/api/ops/knowledge/list.php` | 运维知识库 |
| `/api/ops/reports/summary.php` | 运维统计 |

运维 API 应能引用协作团队、库存备件、合同 SLA 和客户服务记录，工单关闭前必须保留处理记录和验收结果。

### 10.13 工程管理 API 建议

| API | 说明 |
| --- | --- |
| `/api/engineering/items/list.php` | 工程列表 |
| `/api/engineering/items/create.php` | 新建工程或零散工程 |
| `/api/engineering/plans/save.php` | 保存施工计划 |
| `/api/engineering/logs/submit.php` | 提交施工日志 |
| `/api/engineering/materials/list.php` | 工程材料设备记录 |
| `/api/engineering/quality/issues.php` | 质量安全问题 |
| `/api/engineering/changes/submit.php` | 提交变更签证 |
| `/api/engineering/acceptance/submit.php` | 提交验收交付 |
| `/api/engineering/reports/summary.php` | 工程统计 |

工程 API 应能引用项目、协作团队、库存、供应链采购、合同、培训和涉密资料。工程变更签证必须保留费用影响、工期影响和审批记录。
