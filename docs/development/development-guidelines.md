# 企业管理系统开发细则

## 1. 开发顺序

本项目接受并固化“先基础能力、再主数据、再流程、再业务闭环”的开发建议。

推荐顺序：

1. 基础框架：数据库连接、统一响应、会话、CSRF、日志、附件。
2. 权限体系：用户、角色、部门、岗位、菜单、权限点、数据范围、动态菜单。
3. 主数据：员工、客户、物料、设备、合同元数据、供应商、协作团队、密级、党组织。
4. 公共能力：审批、待办、消息、通知、附件、字典、编号规则。
5. 核心业务：项目、客户、工程、运维、财务、合同、库存。
6. 扩展业务：协作团队、供应链采购、培训、党建、涉密。
7. 报表治理：看板、统计、审计、备份、安全策略。

## 2. 推荐项目结构

```text
.
├── api/                         # 所有 PHP API
│   ├── auth/                    # 登录、注册、验证码
│   ├── system/                  # 用户、角色、权限、菜单、字典
│   ├── approval/                # 审批流程、任务、日志
│   ├── workbench/               # 工作台聚合
│   ├── customers/               # 客户管理
│   ├── projects/                # 项目管理
│   ├── engineering/             # 工程管理
│   ├── ops/                     # 运维管理
│   ├── collaboration/           # 协作团队管理
│   ├── suppliers/               # 供应链采购管理
│   ├── inventory/               # 库存管理
│   ├── finance/                 # 财务管理
│   ├── contracts/               # 合同管理
│   ├── training/                # 培训管理
│   ├── party/                   # 党建管理
│   ├── classified/              # 涉密管理
│   ├── files/                   # 附件上传、下载、预览
│   ├── ref/                     # 下拉引用数据
│   └── reports/                 # 报表统计
├── pages/                       # HTML 页面
│   ├── layout/                  # 顶部栏、侧边栏、公共布局
│   ├── auth/
│   ├── workbench/
│   ├── customers/
│   └── ...
├── assets/                      # 自有静态文件，第三方 CSS/JS 仍按要求来自 bootcdn
├── config/                      # 数据库、会话、系统配置
├── includes/                    # 公共 PHP 工具
│   ├── db.php
│   ├── response.php
│   ├── auth.php
│   ├── permission.php
│   ├── csrf.php
│   ├── logger.php
│   └── upload.php
├── docs/                        # 项目文档
└── sql/                         # 初始化和迁移 SQL
```

## 3. API 开发规范

### 3.1 统一响应

成功：

```json
{
  "code": 0,
  "message": "success",
  "data": {}
}
```

失败：

```json
{
  "code": 403,
  "message": "无权限访问",
  "data": null
}
```

### 3.2 API 必须执行的校验

所有 API 必须按顺序执行：

1. 请求方法校验。
2. 登录态校验。
3. CSRF 校验，写操作必须校验。
4. 菜单/API 权限校验。
5. 操作权限校验。
6. 数据范围校验。
7. 涉密对象额外校验密级和知悉范围。
8. 参数校验。
9. 业务规则校验。
10. 数据库事务。
11. 操作日志。

### 3.3 API 命名

推荐：

```text
/api/{module}/{resource}/{action}.php
```

示例：

```text
/api/customers/contacts/list.php
/api/engineering/changes/submit.php
/api/suppliers/compare/generate.php
/api/classified/objects/grant.php
```

## 4. 页面开发规范

### 4.1 页面不得写测试数据

所有数据必须来自 `/api`。

页面可以有空状态展示，例如：

```text
暂无数据
```

但不能在 HTML 或 JS 中写死业务测试数据。

### 4.2 页面标准结构

每个列表页建议包含：

1. 面包屑。
2. 查询条件。
3. 操作按钮。
4. 数据表格。
5. 分页。
6. 批量操作。
7. 导出按钮，需受权限控制。

每个详情页建议包含：

1. 基础信息。
2. 业务明细。
3. 附件。
4. 审批记录。
5. 操作日志。
6. 关联业务。

每个表单页建议包含：

1. 必填校验。
2. 字段格式校验。
3. 引用数据下拉。
4. 附件上传。
5. 保存草稿。
6. 提交审批。

## 5. 数据库设计规范

### 5.1 通用字段

业务表建议包含：

```text
id
created_by
created_at
updated_by
updated_at
deleted_at
department_id
status
approval_status
business_status
security_level
remark
```

### 5.2 金额和数量

1. 金额使用 `decimal(14,2)` 或更高精度。
2. 数量使用 `decimal(14,4)`。
3. 禁止使用浮点类型保存金额。

### 5.3 关联字段

跨模块统一使用：

```text
business_type
business_id
source_type
source_id
project_id
engineering_id
contract_id
customer_id
supplier_id
team_id
department_id
security_level
```

### 5.4 软删除

默认使用 `deleted_at` 软删除。

以下数据原则上不允许物理删除：

1. 审批完成数据。
2. 涉密数据。
3. 合同数据。
4. 财务数据。
5. 审计日志。

## 6. 状态流转规范

统一状态：

| 状态 | 含义 |
| --- | --- |
| draft | 草稿 |
| submitted | 已提交 |
| approving | 审批中 |
| rejected | 已驳回 |
| approved | 已审批 |
| processing | 执行中 |
| completed | 已完成 |
| cancelled | 已取消 |
| archived | 已归档 |

业务模块只维护业务状态，审批模块只维护审批任务和审批流转。

## 7. 审批集成规范

需要审批的业务单据必须包含：

```text
approval_status
approval_instance_id
submitted_at
submitted_by
```

审批实例通过以下字段关联业务：

```text
business_type
business_id
```

审批通过后，只能由原业务模块执行业务状态变更，审批模块不得直接修改业务明细。

## 8. 附件规范

附件统一存储在 `attachments` 表，通过以下字段关联业务：

```text
business_type
business_id
file_name
file_path
file_size
mime_type
security_level
uploaded_by
uploaded_at
```

下载附件必须校验：

1. 登录态。
2. 业务数据权限。
3. 附件权限。
4. 涉密密级。
5. 知悉范围。

## 9. 日志与审计

必须记录：

1. 登录、退出、登录失败。
2. 新增、修改、删除。
3. 提交审批、审批动作。
4. 附件上传、预览、下载。
5. 导出。
6. 涉密访问、外发、打印、复制、下载。
7. 权限和角色变更。

## 10. 涉密开发规范

涉密对象必须额外包含：

```text
security_level
need_to_know_scope
confidential_until
classification_status
classified_object_id
```

访问顺序：

1. RBAC 权限。
2. 数据范围。
3. 密级授权。
4. 知悉范围。
5. 操作审批。

## 11. 分模块开发模板

每个模块开发前必须先补齐以下清单：

1. 页面清单。
2. API 清单。
3. 主表。
4. 明细表。
5. 关联表。
6. 权限点。
7. 数据范围。
8. 状态流转。
9. 附件规则。
10. 审批规则。
11. 日志规则。
12. 报表指标。

## 12. 测试验收规范

每个模块至少验证：

1. 无权限不可见菜单。
2. 无权限访问 API 返回 403。
3. 本人、本部门、参与项目等数据范围正确。
4. 新增、编辑、删除、审批、导出有日志。
5. 附件权限正确。
6. 涉密数据不可越权访问。
7. 页面无静态测试数据。
8. 列表、详情、表单、分页、查询、排序正常。
