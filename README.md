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
│   ├── requirements/  # 按章节拆分的详细需求文档
│   └── development/   # 开发细则与页面到数据库映射
└── 开发总结.md        # 开发记录、变更摘要与后续建议
```

## 当前文档

1. [REQUIREMENTS.md](./REQUIREMENTS.md)：英文文件名可查看版，适合在 GitHub、编辑器或本地系统中稳定打开。
2. [需求文档.md](./需求文档.md)：GitHub 可预览目录页，包含详细章节链接。
3. [docs/requirements](./docs/requirements)：按章节拆分的详细需求文档。
4. [docs/development/development-guidelines.md](./docs/development/development-guidelines.md)：开发细则，包含开发顺序、目录结构、API、页面、数据库、审批、附件、日志和涉密规范。
5. [docs/development/page-database-mapping.md](./docs/development/page-database-mapping.md)：页面到数据库映射，包含页面、API、主表、关联表和权限点。
6. [开发总结.md](./开发总结.md)：记录本次文档化工作内容和后续开发建议。

## 查看说明

如果 GitHub 提示文件太大无法预览，请打开 `需求文档.md` 的目录页，或直接查看 `docs/requirements` 下的拆分章节。快速总览请查看 `REQUIREMENTS.md`。
