# 涉密含党支部企业管理系统需求文档

> 本文件由根目录 `需求文档.md` 拆分而来，便于 GitHub 直接预览。完整总览请查看 `../../REQUIREMENTS.md`。

## 9. 数据库设计原则

### 9.1 基础表建议

| 表名 | 说明 |
| --- | --- |
| users | 用户表 |
| roles | 角色表 |
| user_roles | 用户角色关联表 |
| modules | 模块表 |
| menus | 菜单表 |
| permissions | 权限点表 |
| role_permissions | 角色权限关联表 |
| role_menus | 角色菜单关联表 |
| departments | 部门表 |
| data_scopes | 数据权限范围表 |
| positions | 岗位表 |
| user_departments | 用户多部门授权表 |
| login_logs | 登录日志 |
| operation_logs | 操作日志 |
| captcha_codes | 验证码记录 |
| system_settings | 系统参数 |
| dictionaries | 字典主表 |
| dictionary_items | 字典项表 |
| attachments | 附件表 |
| todo_items | 待办表 |
| messages | 消息提醒表 |
| business_events | 业务事件表 |

### 9.2 业务表建议

| 表名 | 说明 |
| --- | --- |
| approvals | 审批实例 |
| approval_tasks | 审批任务 |
| approval_forms | 审批表单 |
| approval_flows | 审批流程定义 |
| approval_nodes | 审批节点定义 |
| projects | 项目 |
| project_tasks | 项目任务 |
| project_members | 项目成员 |
| project_costs | 项目成本 |
| project_documents | 项目文档 |
| customers | 客户 |
| customer_contacts | 客户联系人 |
| customer_relationships | 客户关系图谱 |
| customer_visits | 客户拜访 |
| customer_business_activities | 客户商务活动 |
| customer_handover_records | 客户交接记录 |
| opportunities | 商机 |
| employees | 员工档案 |
| attendance_records | 考勤记录 |
| reimbursements | 费用报销 |
| reimbursement_invoices | 报销发票 |
| payment_requests | 付款申请 |
| loan_requests | 借款申请 |
| repayment_records | 还款记录 |
| devices | 设备台账 |
| work_orders | 工单 |
| ops_sla_rules | 运维 SLA 规则 |
| ops_knowledge_base | 运维知识库 |
| inspection_records | 巡检记录 |
| safety_events | 安全事件 |
| engineering_items | 工程与零散任务 |
| engineering_logs | 工程施工日志 |
| engineering_plans | 工程施工计划 |
| engineering_material_records | 工程材料设备记录 |
| engineering_change_orders | 工程变更签证 |
| acceptance_records | 验收记录 |
| contracts | 合同 |
| contract_templates | 合同模板 |
| contract_changes | 合同变更 |
| contract_execution_records | 合同执行记录 |
| collaboration_teams | 协作团队 |
| collaboration_members | 协作团队成员 |
| collaboration_companies | 外部协作公司 |
| collaboration_qualifications | 团队资质 |
| collaboration_assignments | 团队派工 |
| collaboration_execution_records | 团队执行记录 |
| collaboration_evaluations | 团队评价 |
| collaboration_settlements | 团队结算 |
| suppliers | 供应商 |
| supplier_accounts | 供应商后台账号 |
| supplier_qualifications | 供应商资质 |
| supplier_products | 供应商商品 |
| supplier_onboarding_requests | 供应商入驻申请 |
| purchase_inquiries | 询价单 |
| purchase_bids | 竞价单 |
| supplier_quotations | 供应商报价 |
| quotation_compare_lists | 比价清单 |
| purchase_orders | 采购订单 |
| purchase_order_items | 采购订单明细 |
| supplier_performance_records | 供应商履约记录 |
| materials | 物料 |
| material_requests | 物料申请 |
| inventory_records | 库存流水 |
| warehouses | 仓库 |
| training_courses | 培训课程 |
| training_plans | 培训计划 |
| exams | 考试 |
| training_records | 学习记录 |
| notices | 通知公告 |
| notice_reads | 通知阅读记录 |
| party_branches | 党支部 |
| party_organizations | 党组织 |
| party_members | 党员信息 |
| party_member_developments | 党员发展流程 |
| party_meetings | 三会一课 |
| party_activities | 主题党日和党建活动 |
| party_dues | 党费记录 |
| party_evaluations | 民主评议 |
| party_ledgers | 党建台账 |
| party_study_records | 党建学习记录 |
| security_levels | 密级规则 |
| classified_objects | 涉密对象 |
| classified_projects | 涉密项目 |
| classified_files | 涉密文件 |
| classified_carriers | 涉密载体 |
| classification_requests | 定密、变更密级、解密申请 |
| classified_access_grants | 涉密授权和知悉范围 |
| classified_borrow_records | 借阅、外发、归还记录 |
| confidentiality_checks | 保密检查 |
| confidentiality_issues | 保密整改问题 |
| confidentiality_education_records | 保密教育记录 |
| leak_incidents | 泄密事件 |
| classified_audit_logs | 涉密审计日志 |

### 9.3 通用字段

业务表建议统一包含：

1. `id`
2. `created_by`
3. `created_at`
4. `updated_by`
5. `updated_at`
6. `deleted_at`
7. `status`
8. `department_id`
9. `remark`

### 9.4 敏感数据要求

1. 密码必须使用 `password_hash` 存储，不允许明文。
2. 手机号、身份证号、银行卡号等敏感字段建议加密或脱敏展示。
3. 附件应按权限下载，禁止直接暴露真实文件路径。
4. 涉密文件需要密级字段、访问日志和下载审批。

### 9.5 关键关联字段建议

跨模块业务必须通过稳定字段关联，避免用文本名称关联。

| 字段 | 说明 | 适用表 |
| --- | --- | --- |
| `business_type` | 业务类型，如 reimbursement、contract、project | approvals、attachments、todo_items、messages |
| `business_id` | 业务单据 ID | approvals、attachments、todo_items、messages |
| `source_type` | 来源类型，如 project、engineering、work_order | material_requests、payment_requests、reimbursements |
| `source_id` | 来源单据 ID | material_requests、payment_requests、reimbursements |
| `project_id` | 关联项目 | contracts、engineering_items、reimbursements、material_requests |
| `engineering_id` | 关联工程或零散任务 | material_requests、reimbursements、acceptance_records |
| `contract_id` | 关联合同 | payment_requests、contract_execution_records |
| `customer_id` | 关联客户 | projects、contracts、opportunities |
| `employee_id` | 关联员工 | users、party_members、training_records |
| `department_id` | 所属部门 | 大部分业务表 |
| `security_level` | 密级 | contracts、attachments、projects、notices |
| `classification_status` | 定密状态 | classified_objects、attachments、projects、contracts |
| `confidential_until` | 保密期限 | classified_objects、classified_files、contracts |
| `declassification_at` | 解密时间 | classified_objects、classified_files |
| `need_to_know_scope` | 知悉范围 | classified_access_grants、classified_objects |
| `carrier_id` | 涉密载体 ID | classified_files、classified_borrow_records |
| `party_org_id` | 党组织 ID | party_members、party_meetings、party_dues、party_ledgers |
| `party_member_id` | 党员 ID | party_dues、party_study_records、party_evaluations |
| `team_id` | 协作团队 ID | collaboration_assignments、engineering_items、work_orders |
| `team_member_id` | 协作团队成员 ID | collaboration_execution_records、collaboration_evaluations |
| `supplier_id` | 供应商 ID | supplier_products、supplier_quotations、purchase_orders、payment_requests |
| `inquiry_id` | 询价单 ID | purchase_bids、supplier_quotations、quotation_compare_lists |
| `quotation_id` | 报价单 ID | quotation_compare_lists、purchase_order_items |
| `purchase_order_id` | 采购订单 ID | purchase_order_items、inventory_records、payment_requests |
| `approval_status` | 审批状态 | 需要审批的业务表 |
| `business_status` | 业务执行状态 | 项目、合同、工程、工单、培训 |

### 9.6 数据归属规则

1. `approvals.business_type + approvals.business_id` 指向原业务单据，审批表不复制业务明细。
2. 附件使用 `attachments.business_type + attachments.business_id` 关联原业务单据，并单独保存密级、上传人、下载次数和访问日志。
3. 待办使用 `todo_items` 聚合生成，待办处理完成后保留历史状态，不直接删除。
4. 消息提醒使用 `messages` 记录阅读状态；公告阅读使用 `notice_reads` 记录。
5. 项目成本不应手工随意录入，应优先来自报销、付款、物料出库、人工成本等业务事件汇总。
6. 库存数量只由库存流水计算或定期汇总生成，不允许直接修改实时库存结果。
7. 合同金额、项目预算、报销金额、付款金额必须使用定点小数类型，不使用浮点类型。
8. 删除业务数据默认采用软删除，涉密数据和审批完成数据原则上不允许物理删除。
9. 党建党员档案以员工档案为基础，不重复保存姓名、手机号、身份证等员工主数据，只保存党务属性。
10. 涉密对象使用 `classified_objects.business_type + classified_objects.business_id` 关联原业务对象，不迁移原业务数据。
11. 涉密授权使用单独授权表记录授权人、被授权人、授权范围、有效期和审批来源。
12. 涉密审计日志不可由普通管理员删除，只允许按制度归档和备份。
13. 协作团队成员中的内部人员只引用员工 ID，不复制员工主档案。
14. 外部公司如果作为服务执行主体，记录在 `collaboration_companies`；如果作为商品供货主体，记录在 `suppliers`。
15. 供应商商品可关联平台物料编码，无法匹配时进入待映射状态，由后台审核。
16. 比价清单应保存生成规则和报价快照，避免供应商后续改价影响历史采购依据。
17. 采购订单按供应商拆单，订单明细必须保留来源询价、报价和比价清单 ID。
