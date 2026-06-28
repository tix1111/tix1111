# 需求追溯矩阵与风险清单

## 1. 需求追溯矩阵

| 需求编号 | 需求名称 | 文档位置 | 开发文档 | 验收点 |
| --- | --- | --- | --- | --- |
| REQ-001 | RBAC 动态菜单 | `05-rbac-permissions.md`、`06-menu-structure.md` | `role-permission-matrix.md`、`page-database-mapping.md` | admin 全菜单，其他角色按授权菜单 |
| REQ-002 | 注册/登录/找回密码验证码 | `04-authentication.md` | `api-specification.md`、`development-guidelines.md` | 三个流程均需验证码 |
| REQ-003 | 审批中心 | `08-module-breakdown.md` | `database-schema-base.md`、`api-specification.md` | 审批任务不复制业务明细 |
| REQ-004 | 客户摧龙六式 | `08-module-breakdown.md` | `page-database-mapping.md`、`database-schema-business.md` | 客户档案、拜访、交接包完整 |
| REQ-005 | 项目管理 | `08-module-breakdown.md` | `database-schema-business.md` | 立项、计划、成本、文档闭环 |
| REQ-006 | 运维管理 | `08-module-breakdown.md` | `api-specification.md`、`reporting-requirements.md` | SLA、工单、备件、知识库闭环 |
| REQ-007 | 工程管理 | `08-module-breakdown.md` | `database-schema-business.md`、`engineering-construction-design.md` | 施工团队、进场、领料、日志、隐蔽验收、变更签证、验收交付 |
| REQ-021 | 施工日志第三方分享 | `engineering-construction-design.md` | `api-specification.md`、`security-threat-model.md` | 分享有效期、撤销、脱敏、审计、涉密审批 |
| REQ-008 | 协作团队管理 | `08-module-breakdown.md` | `database-schema-extended.md`、`role-permission-matrix.md` | 团队派工、执行记录、评价、结算 |
| REQ-009 | 供应链采购管理 | `08-module-breakdown.md` | `api-specification.md`、`business-rules.md` | 询价、竞价、比价、一键下单 |
| REQ-010 | 库存管理 | `08-module-breakdown.md` | `business-rules.md` | 库存流水计算，低库存预警 |
| REQ-011 | 合同管理 | `08-module-breakdown.md` | `business-rules.md`、`reporting-requirements.md` | 合同执行、到期预警 |
| REQ-012 | 财务管理 | `08-module-breakdown.md` | `database-schema-business.md` | 报销、付款、应收、预算 |
| REQ-013 | 培训管理 | `08-module-breakdown.md` | `database-schema-extended.md` | 课程、计划、考试、证书 |
| REQ-014 | 党建管理 | `08-module-breakdown.md` | `database-schema-extended.md` | 党组织、党员、三会一课、党费 |
| REQ-015 | 涉密管理 | `13-security-compliance.md` | `database-schema-extended.md`、`security-threat-model.md` | 密级、知悉范围、审计 |
| REQ-016 | 报表统计 | `reporting-requirements.md` | `api-specification.md` | 报表受数据权限控制 |
| REQ-017 | 页面无测试数据 | `12-frontend-guidelines.md` | `development-guidelines.md` | 页面数据全部来自 API |
| REQ-018 | 文件上传与下载安全 | `13-security-compliance.md` | `frontend-and-engineering-specs.md` | 文件下载走鉴权接口 |
| REQ-019 | 部署与备份 | `deployment-guide.md` | `deployment-guide.md` | 可执行部署、备份、健康检查 |
| REQ-020 | SQL 初始化 | `database-schema-*.md` | `sql/schema.sql`、`sql/init.sql` | 可从空库初始化 |

## 2. 需求变更控制

新增需求必须补齐：

1. 需求编号。
2. 业务归属模块。
3. 页面入口。
4. API。
5. 数据库表。
6. 权限点。
7. 数据范围。
8. 审批规则。
9. 附件规则。
10. 涉密规则。
11. 验收标准。

## 3. 风险清单

| 风险编号 | 风险 | 影响 | 缓解措施 | 状态 |
| --- | --- | --- | --- | --- |
| RISK-001 | 涉密环境使用 bootcdn 可能产生外联风险 | 高 | 生产涉密环境使用内网镜像或本地静态资源 | 开放 |
| RISK-002 | 使用 root 数据库账号 | 高 | 生产环境创建最小权限账号 | 开放 |
| RISK-003 | 供应商账号越权查看其他报价 | 高 | API 强制按 supplier_id 过滤，增加测试用例 | 开放 |
| RISK-004 | 客户联系人画像涉及隐私 | 高 | 字段权限、脱敏、访问日志、合规说明 | 开放 |
| RISK-005 | 文件上传可执行脚本 | 高 | MIME 校验、扩展名白名单、非 Web 目录存储 | 已缓解 |
| RISK-006 | 审批流程配置错误导致业务卡住 | 中 | 审批流启用前校验节点和审批人 | 开放 |
| RISK-007 | 库存并发出库导致负库存 | 高 | 库存操作事务 + 行锁 + 出库前校验 | 开放 |
| RISK-008 | 报表查询影响业务库性能 | 中 | 分页、索引、导出任务、只读库 | 开放 |
| RISK-009 | SQL schema 和文档字段不一致 | 中 | 每次字段变更同步更新 schema 和字段文档 | 开放 |
| RISK-010 | 大文件文档 GitHub 无法预览 | 低 | 已拆分 docs/requirements 和目录页 | 已缓解 |
| RISK-011 | 外部协作账号访问内部资料 | 高 | 独立账号类型、最小权限、数据范围测试 | 开放 |
| RISK-012 | 合同/财务数据误删除 | 高 | 软删除，审批完成数据禁止物理删除 | 开放 |
| RISK-013 | 工程现场领料与实际使用不一致 | 中 | 领料、签收、使用、退料分开记录，验收前核对 | 开放 |
| RISK-014 | 隐蔽工程未验收即覆盖 | 高 | 隐蔽验收为前置条件，不通过禁止进入下一阶段 | 开放 |
| RISK-015 | 外部施工团队进入涉密现场未授权 | 高 | 施工团队进场前校验涉密授权和知悉范围 | 开放 |
| RISK-016 | 施工日志分享链接泄露 | 高 | token hash、有效期、撤销、水印、审计、noindex、频率限制 | 开放 |
| RISK-017 | 第三方通过施工日志看到成本或个人隐私 | 高 | 分享字段白名单、脱敏、默认禁止下载 | 开放 |
| RISK-018 | 涉密工程日志未经审批分享 | 极高 | 涉密工程分享前必须走涉密外发/借阅审批 | 开放 |

## 4. 待确认事项

| 编号 | 待确认事项 | 影响 |
| --- | --- | --- |
| TODO-001 | 生产环境是否允许访问公网 bootcdn | 影响前端资源部署 |
| TODO-002 | 短信验证码是否接入公网短信网关 | 影响注册和找回密码 |
| TODO-003 | 涉密密级名称和保密期限是否采用内部制度 | 影响涉密规则初始化 |
| TODO-004 | 财务科目是否采用企业现有科目体系 | 影响财务报表 |
| TODO-005 | 供应商评分权重是否固定 | 影响比价规则 |
| TODO-006 | 客户联系人敏感字段允许记录范围 | 影响客户画像 |
| TODO-007 | 数据保留期限是否有内部制度 | 影响日志和审计归档 |

## 5. 需求优先级建议

| 优先级 | 范围 | 原因 |
| --- | --- | --- |
| P0 | 登录、权限、动态菜单、数据库、API 基础、日志 | 系统底座 |
| P1 | 客户、项目、审批、财务、合同、库存 | 核心业务闭环 |
| P2 | 运维、工程、协作团队、供应链采购 | 业务扩展闭环 |
| P3 | 培训、党建、涉密、报表 | 管理和治理增强 |
| P4 | SSE、在线会议、高级分析 | 后续优化 |
