# tix1111

## 项目说明

本仓库用于建设一个 PC 端涉密企业后台管理系统，系统包含 RBAC 权限管理、动态菜单、审批、项目、客户、人事、财务、运维、工程、合同、协作团队、供应链采购、库存、培训、通知公告、系统管理、涉密管理与党建管理等模块。

技术约束：

- 前端：HTML + Bootstrap 原生开发
- 后端：PHP API
- 数据库：MySQL，数据库名 `lz`
- API：统一存放在 `/api`
- 前端资源：CSS 和 JS 统一使用 bootcdn

## 项目结构目录

```text
.
├── README.md          # 项目说明与项目结构目录
├── REQUIREMENTS.md    # 英文文件名可查看版需求文档
├── 需求文档.md        # GitHub 可预览的需求文档目录页
├── docs/
│   ├── requirements/  # 按章节拆分的详细需求文档（16个章节）
│   └── development/   # 开发细则、字段定义、API规格、报表、部署等
├── sql/
│   ├── schema.sql     # 完整建表脚本（70+张表）
│   └── init.sql       # 初始化数据（字典、密级、参数、账号）
└── 开发总结.md        # 开发记录、变更摘要与后续建议
```

## 当前文档

1. [REQUIREMENTS.md](./REQUIREMENTS.md)：英文文件名可查看版，适合在 GitHub、编辑器或本地系统中稳定打开。
2. [需求文档.md](./需求文档.md)：GitHub 可预览目录页，包含详细章节链接。
3. [docs/requirements](./docs/requirements)：按章节拆分的详细需求文档。
4. [docs/development/development-guidelines.md](./docs/development/development-guidelines.md)：开发细则，包含开发顺序、目录结构、API、页面、数据库、审批、附件、日志和涉密规范。
5. [docs/development/page-database-mapping.md](./docs/development/page-database-mapping.md)：页面到数据库映射，包含页面、API、主表、关联表和权限点。
6. [docs/development/database-schema-base.md](./docs/development/database-schema-base.md)：基础表、权限表、审批表完整字段定义。
7. [docs/development/database-schema-business.md](./docs/development/database-schema-business.md)：员工、客户、项目、合同、财务、工单、工程等核心业务表字段。
8. [docs/development/database-schema-extended.md](./docs/development/database-schema-extended.md)：物料、库存、供应商、培训、党建、涉密、应收、预算等扩展表字段。
9. [docs/development/frontend-and-engineering-specs.md](./docs/development/frontend-and-engineering-specs.md)：错误码、文件安全、前端骨架、实时无刷新、审批引擎、PHP 工具库规范。
10. [docs/development/api-specification.md](./docs/development/api-specification.md)：完整 API 接口规格。
11. [docs/development/business-rules.md](./docs/development/business-rules.md)：编号规则、财务科目、库存计算、定时任务和竞价规则。
12. [docs/development/deployment-guide.md](./docs/development/deployment-guide.md)：部署与环境配置。
13. [docs/development/reporting-requirements.md](./docs/development/reporting-requirements.md)：报表统计需求规格。
14. [docs/development/role-permission-matrix.md](./docs/development/role-permission-matrix.md)：角色权限矩阵。
15. [docs/development/test-and-acceptance-plan.md](./docs/development/test-and-acceptance-plan.md)：测试与验收计划。
16. [docs/development/data-governance-and-migration.md](./docs/development/data-governance-and-migration.md)：数据治理、迁移与发布方案。
17. [docs/development/traceability-and-risk-register.md](./docs/development/traceability-and-risk-register.md)：需求追溯矩阵与风险清单。
18. [docs/development/security-threat-model.md](./docs/development/security-threat-model.md)：安全威胁模型。
19. [sql/schema.sql](./sql/schema.sql)：完整建表脚本。
20. [sql/init.sql](./sql/init.sql)：SQL 初始化脚本（字典、密级、参数、初始账号）。
21. [sql/seed_modules_menus_permissions.sql](./sql/seed_modules_menus_permissions.sql)：模块、菜单和权限点种子数据。
22. [开发总结.md](./开发总结.md)：记录本次文档化工作内容和后续开发建议。

## 查看说明

如果 GitHub 提示文件太大无法预览，请打开 `需求文档.md` 的目录页，或直接查看 `docs/requirements` 下的拆分章节。快速总览请查看 `REQUIREMENTS.md`。
