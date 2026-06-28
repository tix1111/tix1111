# 页面到数据库映射细则

## 1. 说明

本文档用于把页面开发、API、数据库表、权限点和业务归属连接起来。后续开发页面时，应先查本表，确认数据来源和主归属，避免重复建表、重复接口和重复菜单。

字段说明：

| 字段 | 说明 |
| --- | --- |
| 页面 | 前端页面或二级菜单页面 |
| API | 页面主要调用的接口 |
| 主表 | 业务主数据表 |
| 关联表 | 明细、附件、审批、日志或跨模块关联表 |
| 权限点 | 建议的操作权限 |
| 说明 | 业务边界和注意事项 |

## 2. 公共页面映射

| 页面 | API | 主表 | 关联表 | 权限点 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 登录 | `/api/auth/login.php` | users | login_logs、captcha_codes | auth.login | 登录成功后返回用户、角色、菜单 |
| 注册 | `/api/auth/register.php` | users | captcha_codes、operation_logs | auth.register | 注册后可进入待审核 |
| 找回密码 | `/api/auth/forgot-password.php` | users | captcha_codes、operation_logs | auth.forgot_password | 重置后清理旧会话 |
| 当前用户 | `/api/auth/me.php` | users | roles、user_roles | auth.me | 返回当前用户和权限摘要 |
| 动态菜单 | `/api/menus/tree.php` | menus | role_menus、permissions | menu.view | 服务端计算菜单树 |
| 附件上传 | `/api/files/upload.php` | attachments | classified_objects、operation_logs | file.upload | 附件必须绑定业务类型和业务 ID |
| 附件下载 | `/api/files/download.php` | attachments | classified_audit_logs、operation_logs | file.download | 涉密附件需额外鉴密 |

## 3. 工作台

| 页面 | API | 主表 | 关联表 | 权限点 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 首页仪表盘 | `/api/workbench/summary.php` | business_events | todo_items、messages | workbench.view | 聚合数据，不保存业务明细 |
| 待办中心 | `/api/workbench/todos.php` | todo_items | approvals、work_orders、training_plans | todo.view | 待办按权限和数据范围过滤 |
| 通知中心 | `/api/workbench/messages.php` | messages | notices、notice_reads | message.view | 系统消息和通知阅读状态 |
| 常用功能 | `/api/workbench/shortcuts.php` | menus | role_menus | shortcut.view | 只返回有权限入口 |
| 个人日程 | `/api/workbench/calendar.php` | messages | customer_visits、party_activities、training_plans | calendar.view | 聚合业务日期事项 |
| 数据看板 | `/api/workbench/metrics.php` | business_events | reports | dashboard.view | 数据权限控制指标范围 |

## 4. 审批管理

| 页面 | API | 主表 | 关联表 | 权限点 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 审批中心 | `/api/approval/tasks.php` | approval_tasks | approvals | approval.task.view | 展示任务，详情跳转原模块 |
| 我发起的 | `/api/approval/instances/my.php` | approvals | approval_tasks | approval.instance.view | 按 created_by 过滤 |
| 流程配置 | `/api/approval/flows/list.php` | approval_flows | approval_nodes | approval.flow.manage | 管理审批流程 |
| 表单配置 | `/api/approval/forms/list.php` | approval_forms | dictionaries | approval.form.manage | 表单版本需要保留 |
| 审批委托 | `/api/approval/delegations/list.php` | approval_delegations | operation_logs | approval.delegate | 委托影响处理人 |
| 审批报表 | `/api/approval/reports/summary.php` | approvals | approval_tasks | approval.report.view | 统计审批效率 |
| 审批日志 | `/api/approval/logs.php` | approval_tasks | operation_logs | approval.log.view | 不允许普通用户删除 |

## 5. 客户管理

| 页面 | API | 主表 | 关联表 | 权限点 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 客户档案 | `/api/customers/list.php` | customers | customer_contacts、customer_relationships | customer.view | 客户主数据入口 |
| 客户详情 | `/api/customers/detail.php` | customers | customer_visits、opportunities、contracts | customer.detail | 客户全景视图 |
| 联系人画像 | `/api/customers/contacts/list.php` | customer_contacts | customer_relationships、operation_logs | customer.contact.view | 敏感字段需权限和日志 |
| 客户关系图谱 | `/api/customers/relationships/map.php` | customer_relationships | customer_contacts | customer.relationship.view | 记录决策链、向导、影响人 |
| 客户拜访 | `/api/customers/visits/list.php` | customer_visits | attachments、todo_items | customer.visit.manage | 可生成待办和商机 |
| 商务活动 | `/api/customers/business-activities/list.php` | customer_business_activities | approvals、attachments | customer.activity.manage | 需要合规审批和效果记录 |
| 商机管理 | `/api/customers/opportunities/list.php` | opportunities | customer_contacts、projects | opportunity.manage | 成熟商机可转项目 |
| 客户合同关联 | `/api/customers/contracts.php` | contracts | contract_execution_records | customer.contract.view | 只读合同摘要 |
| 客户交接 | `/api/customers/handover/generate.php` | customer_handover_records | customers、customer_contacts、opportunities | customer.handover | 负责人变更时生成交接包 |
| 客户分析 | `/api/customers/reports/summary.php` | customers | opportunities、contracts、payment_requests | customer.report.view | 统计客户价值和转化 |
| 客户服务 | `/api/customers/services/list.php` | customer_service_records | work_orders、notices | customer.service.manage | 可关联运维工单 |

## 6. 项目管理

| 页面 | API | 主表 | 关联表 | 权限点 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 项目立项 | `/api/projects/create.php` | projects | approvals、customers | project.create | 立项可进入审批 |
| 项目列表 | `/api/projects/list.php` | projects | project_members | project.view | 按参与项目过滤 |
| 项目计划 | `/api/projects/tasks/list.php` | project_tasks | projects | project.plan.manage | 任务、里程碑、前置任务 |
| 项目执行 | `/api/projects/progress/list.php` | project_tasks | business_events | project.execute | 记录进度和问题 |
| 项目资源 | `/api/projects/resources/list.php` | project_members | collaboration_assignments、materials | project.resource.manage | 关联人员、团队、设备、材料 |
| 项目成本 | `/api/projects/costs/summary.php` | project_costs | reimbursements、payment_requests、inventory_records | project.cost.view | 成本来自财务和库存 |
| 项目文档 | `/api/projects/documents/list.php` | project_documents | attachments、classified_objects | project.document.manage | 涉密文档接入涉密管理 |
| 项目变更 | `/api/projects/changes/submit.php` | project_changes | approvals | project.change | 影响范围、费用和工期 |

## 7. 运维管理

| 页面 | API | 主表 | 关联表 | 权限点 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 设备台账 | `/api/ops/devices/list.php` | devices | contracts、attachments | ops.device.view | 设备主数据 |
| 运维计划 | `/api/ops/plans/list.php` | ops_plans | devices、work_orders | ops.plan.manage | 可生成巡检或工单 |
| 巡检管理 | `/api/ops/inspections/list.php` | inspection_records | devices、work_orders | ops.inspection.manage | 异常可转工单 |
| 工单管理 | `/api/ops/work-orders/list.php` | work_orders | collaboration_assignments、inventory_records | ops.work_order.manage | 可派工、领备件、验收 |
| 工单派工 | `/api/ops/work-orders/dispatch.php` | work_orders | collaboration_assignments | ops.dispatch | 可派内部人员或协作团队 |
| SLA 管理 | `/api/ops/sla/list.php` | ops_sla_rules | contracts、work_orders | ops.sla.manage | 响应和处理时限 |
| 备件使用 | `/api/ops/spare-parts/usage.php` | inventory_records | work_orders、materials | ops.part.use | 实物库存归库存管理 |
| 安全事件 | `/api/ops/safety-events/list.php` | safety_events | attachments、todo_items | ops.safety.manage | 运维安全闭环 |
| 运维知识库 | `/api/ops/knowledge/list.php` | ops_knowledge_base | work_orders、attachments | ops.knowledge.manage | 工单复盘沉淀 |
| 运维报表 | `/api/ops/reports/summary.php` | work_orders | ops_sla_rules、devices | ops.report.view | SLA、故障率、可用率 |

## 8. 工程管理

| 页面 | API | 主表 | 关联表 | 权限点 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 工程列表 | `/api/engineering/items/list.php` | engineering_items | projects、contracts | engineering.view | 工程或零散任务 |
| 新建工程 | `/api/engineering/items/create.php` | engineering_items | projects | engineering.create | 可从项目创建 |
| 施工计划 | `/api/engineering/plans/save.php` | engineering_plans | collaboration_assignments、material_requests | engineering.plan.manage | 明确团队和材料需求 |
| 施工团队 | `/api/engineering/teams/assign.php` | engineering_team_members | collaboration_teams、collaboration_members | engineering.team.assign | 从协作团队组成施工队伍 |
| 进场管理 | `/api/engineering/site-entry/confirm.php` | engineering_site_entries | engineering_team_members、attachments | engineering.site_entry | 记录人员进场和现场条件 |
| 领料管理 | `/api/engineering/materials/request.php` | engineering_material_records | material_requests、inventory_records | engineering.material.request | 领料申请、出库、现场签收、退料 |
| 过程跟踪 | `/api/engineering/progress/list.php` | engineering_logs | engineering_items | engineering.progress | 节点、照片、问题 |
| 施工日志 | `/api/engineering/logs/submit.php` | engineering_logs | attachments | engineering.log.submit | 每日施工追溯 |
| 材料设备 | `/api/engineering/materials/list.php` | engineering_material_records | inventory_records、materials | engineering.material.view | 库存负责实物流转 |
| 质量安全 | `/api/engineering/quality/issues.php` | engineering_quality_issues | todo_items、attachments | engineering.quality.manage | 整改闭环 |
| 隐蔽验收 | `/api/engineering/hidden-acceptance/submit.php` | engineering_hidden_acceptance | attachments、todo_items | engineering.hidden_acceptance | 覆盖前验收，不通过生成整改 |
| 变更签证 | `/api/engineering/changes/submit.php` | engineering_change_orders | approvals、project_costs | engineering.change | 影响费用和工期 |
| 验收交付 | `/api/engineering/acceptance/submit.php` | acceptance_records | training_plans、attachments | engineering.acceptance | 验收和交付资料 |
| 工程结算 | `/api/engineering/settlements/submit.php` | engineering_settlements | collaboration_settlements、payment_requests、project_costs | engineering.settlement | 验收后结算并进入财务 |
| 工程报表 | `/api/engineering/reports/summary.php` | engineering_items | engineering_logs、project_costs | engineering.report.view | 进度、成本、验收率 |

## 9. 协作团队管理

| 页面 | API | 主表 | 关联表 | 权限点 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 团队档案 | `/api/collaboration/teams/list.php` | collaboration_teams | collaboration_members | collaboration.team.view | 统一团队入口 |
| 内部人员 | `/api/collaboration/members/internal.php` | collaboration_members | employees | collaboration.member.manage | 只引用员工主档案 |
| 外部人员 | `/api/collaboration/members/external.php` | collaboration_members | collaboration_qualifications | collaboration.external.manage | 外部个人协作 |
| 外聘人员 | `/api/collaboration/members/contracted.php` | collaboration_members | contracts | collaboration.contracted.manage | 外聘专家、顾问 |
| 外部公司 | `/api/collaboration/companies/list.php` | collaboration_companies | collaboration_qualifications | collaboration.company.manage | 服务执行主体 |
| 资质管理 | `/api/collaboration/qualifications/list.php` | collaboration_qualifications | attachments | collaboration.qualification.manage | 到期预警 |
| 团队派工 | `/api/collaboration/assignments/create.php` | collaboration_assignments | projects、engineering_items、work_orders | collaboration.assignment | 来源模块必须明确 |
| 执行记录 | `/api/collaboration/execution/submit.php` | collaboration_execution_records | attachments | collaboration.execution | 回写来源任务 |
| 质量评价 | `/api/collaboration/evaluations/submit.php` | collaboration_evaluations | collaboration_assignments | collaboration.evaluation | 影响后续派工 |
| 结算管理 | `/api/collaboration/settlements/submit.php` | collaboration_settlements | payment_requests、contracts | collaboration.settlement | 进入财务付款 |

## 10. 供应链采购管理

| 页面 | API | 主表 | 关联表 | 权限点 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 供应商入驻 | `/api/suppliers/onboarding/submit.php` | supplier_onboarding_requests | approvals、supplier_qualifications | supplier.onboard | 支持申请或后台添加 |
| 供应商档案 | `/api/suppliers/list.php` | suppliers | supplier_accounts、supplier_qualifications | supplier.view | 供应商主数据 |
| 供应商后台 | `/api/suppliers/portal/dashboard.php` | supplier_accounts | supplier_products、purchase_orders | supplier.portal | 供应商只能看本方数据 |
| 商品目录 | `/api/suppliers/products/list.php` | supplier_products | materials | supplier.product.manage | 可映射平台物料 |
| 询价管理 | `/api/suppliers/inquiries/create.php` | purchase_inquiries | material_requests、projects | purchase.inquiry | 平台发起询价 |
| 竞价管理 | `/api/suppliers/bids/create.php` | purchase_bids | supplier_quotations | purchase.bid | 多轮报价 |
| 报价管理 | `/api/suppliers/quotations/submit.php` | supplier_quotations | supplier_products | supplier.quote | 支持部分商品报价 |
| 比价清单 | `/api/suppliers/compare/generate.php` | quotation_compare_lists | supplier_quotations | purchase.compare | 保存报价快照 |
| 采购下单 | `/api/suppliers/orders/create.php` | purchase_orders | purchase_order_items、approvals | purchase.order | 一键下单后审批 |
| 履约评价 | `/api/suppliers/performance/submit.php` | supplier_performance_records | purchase_orders、inventory_records | supplier.performance | 影响评级 |

## 11. 库存管理

| 页面 | API | 主表 | 关联表 | 权限点 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 物料管理 | `/api/inventory/materials/list.php` | materials | dictionaries | inventory.material.view | 平台物料主数据 |
| 物料采购申请 | `/api/inventory/requests/create.php` | material_requests | purchase_inquiries | inventory.request | 可触发供应链采购 |
| 入库管理 | `/api/inventory/inbound/create.php` | inventory_records | purchase_orders、materials | inventory.inbound | 形成库存流水 |
| 出库管理 | `/api/inventory/outbound/create.php` | inventory_records | engineering_items、work_orders | inventory.outbound | 领用出库 |
| 库存调拨 | `/api/inventory/transfers/create.php` | inventory_records | warehouses | inventory.transfer | 调拨流水 |
| 库存盘点 | `/api/inventory/stocktaking/list.php` | inventory_stocktaking | inventory_records | inventory.stocktaking | 差异处理 |
| 库存查询 | `/api/inventory/stock/query.php` | inventory_records | materials、warehouses | inventory.stock.view | 汇总库存 |
| 物料签收 | `/api/inventory/sign/confirm.php` | inventory_records | purchase_orders | inventory.sign | 到货签收 |

## 12. 财务管理

| 页面 | API | 主表 | 关联表 | 权限点 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 费用报销 | `/api/finance/reimbursements/list.php` | reimbursements | reimbursement_invoices、attachments | finance.reimburse | 可关联项目 |
| 应收管理 | `/api/finance/receivables/list.php` | receivables | contracts、customers | finance.receivable | 合同回款 |
| 应付管理 | `/api/finance/payables/list.php` | payment_requests | suppliers、purchase_orders | finance.payable | 供应商付款 |
| 借款管理 | `/api/finance/loans/list.php` | loan_requests | repayment_records | finance.loan | 借款和还款 |
| 预算管理 | `/api/finance/budgets/list.php` | budgets | projects、departments | finance.budget | 预算控制 |
| 财务报表 | `/api/finance/reports/summary.php` | finance_reports | payment_requests、receivables | finance.report | 导出受控 |

## 13. 合同管理

| 页面 | API | 主表 | 关联表 | 权限点 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 合同起草 | `/api/contracts/create.php` | contracts | contract_templates、attachments | contract.create | 合同主入口 |
| 合同流程 | `/api/contracts/workflow.php` | contracts | approvals、approval_tasks | contract.workflow | 审批任务归审批管理 |
| 合同执行 | `/api/contracts/execution/list.php` | contract_execution_records | payment_requests、receivables | contract.execute | 履约和收付款 |
| 合同归档 | `/api/contracts/archive.php` | contracts | attachments、classified_objects | contract.archive | 涉密合同接入涉密 |
| 合同查询 | `/api/contracts/list.php` | contracts | customers、suppliers | contract.view | 多条件检索 |
| 合同元数据 | `/api/contracts/metadata/list.php` | contract_templates | dictionaries | contract.metadata | 模板和条款 |

## 14. 人事、培训、党建、涉密

| 页面 | API | 主表 | 关联表 | 权限点 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 员工管理 | `/api/hr/employees/list.php` | employees | users、departments | hr.employee.view | 员工主档案 |
| 考勤管理 | `/api/hr/attendance/list.php` | attendance_records | approvals | hr.attendance | 请假加班可审批 |
| 培训资源 | `/api/training/courses/list.php` | training_courses | attachments | training.course.view | 通用课程 |
| 培训计划 | `/api/training/plans/list.php` | training_plans | training_records | training.plan | 可被党建、涉密引用 |
| 党建组织 | `/api/party/organizations/list.php` | party_organizations | party_members | party.org.view | 独立党组织树 |
| 党员管理 | `/api/party/members/list.php` | party_members | employees | party.member.view | 引用员工档案 |
| 党建台账 | `/api/party/ledgers/list.php` | party_ledgers | attachments、classified_objects | party.ledger | 可涉密 |
| 涉密对象 | `/api/classified/objects/list.php` | classified_objects | classified_access_grants | classified.object.view | 横切业务对象 |
| 涉密审计 | `/api/classified/audit/list.php` | classified_audit_logs | users | classified.audit.view | 不允许普通删除 |

## 15. 页面开发落地步骤

开发任一页面前按以下顺序执行：

1. 确认页面归属模块。
2. 确认主表和关联表。
3. 确认 API 路径。
4. 确认权限点。
5. 确认数据范围。
6. 确认是否需要审批。
7. 确认是否需要附件。
8. 确认是否涉密。
9. 确认列表字段、详情字段、表单字段。
10. 确认日志和审计要求。
