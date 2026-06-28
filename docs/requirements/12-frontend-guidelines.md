# 涉密含党支部企业管理系统需求文档

> 本文件由根目录 `需求文档.md` 拆分而来，便于 GitHub 直接预览。完整总览请查看 `../../REQUIREMENTS.md`。

## 12. 页面与前端规范

### 12.1 技术选型

| 项目 | 选型 | 来源 |
| --- | --- | --- |
| CSS 框架 | Bootstrap 5.3 | bootcdn |
| 图标库 | Bootstrap Icons | bootcdn |
| 表格组件 | Bootstrap Table 1.22 | bootcdn |
| 日期组件 | Flatpickr | bootcdn |
| 富文本 | Quill 1.3 | bootcdn（仅公告/合同内容使用）|
| 图表 | ECharts 5.x | bootcdn（仅报表页使用）|
| 树形组件 | 原生 Bootstrap + 递归渲染 | 自实现 |
| 文件上传 | 自实现 + `/api/files/upload.php` | — |

### 12.2 页面布局结构

```
+--------------------------------------------------+
| 顶部导航栏（Topbar）                              |
+--------------------------------------------------+
|           |                                      |
|  左侧菜单  |   面包屑导航                         |
|  (Sidebar) |                                      |
|            |   页面内容区                         |
|            |   - 查询条件（Collapse 收纳）         |
|            |   - 操作按钮（新增/导出/批量）         |
|            |   - 数据表格                         |
|            |   - 分页                             |
|            |                                      |
+--------------------------------------------------+
```

- 顶部栏固定高度 56px，包含：系统名称、用户头像、待办徽章、消息图标、退出。
- 侧边栏宽度 240px，支持折叠为 64px。
- 内容区 `padding: 16px`。

### 12.3 公共 CSS 变量（main.css）

```css
:root {
  --primary-color:   #0d6efd;
  --sidebar-width:   240px;
  --topbar-height:   56px;
  --border-radius:   6px;
  --shadow-sm:       0 1px 3px rgba(0,0,0,.1);
}

body { font-size: 14px; font-family: 'Microsoft YaHei', sans-serif; }
.sidebar { width: var(--sidebar-width); min-height: calc(100vh - var(--topbar-height)); background: #1a2035; }
.sidebar .nav-link { color: #a0a8b7; border-radius: var(--border-radius); }
.sidebar .nav-link.active { color: #fff; background: var(--primary-color); }
.content-area { padding: 16px; }
```

### 12.4 数据表格规范

所有列表页使用 Bootstrap Table，统一配置如下：

```javascript
$('#table').bootstrapTable({
  url: '/api/{module}/list.php',
  method: 'get',
  toolbar: '#toolbar',
  search: false,          // 搜索由独立查询表单承担
  pagination: true,
  pageSize: 20,
  pageList: [10, 20, 50, 100],
  sidePagination: 'server',
  queryParams(params) {
    return Object.assign(params, getSearchParams());
  },
  columns: [...],
  onLoadError(status, jqXHR) {
    if (status === 401 || status === 403) window.location.href = '/pages/auth/login.php';
  }
});
```

必须支持：

1. 服务端分页。
2. 点击列头排序。
3. 勾选行批量操作。
4. 导出按钮（有权限时显示）。
5. 空数据时显示"暂无数据"占位。

### 12.5 表单规范

**统一规则：**

1. 必填字段在 `label` 后加 `<span class="text-danger">*</span>`。
2. 前端用 HTML5 `required` + JS 二次校验。
3. 金额字段限制为数字，最多 2 位小数。
4. 日期字段使用 Flatpickr 初始化，格式统一为 `YYYY-MM-DD`。
5. 下拉选项来自 `/api/ref/` 引用接口，不写死。
6. 草稿保存不校验必填，提交时才强校验。
7. 表单提交必须禁用按钮防止重复提交，完成后恢复。

**表单提交模式：**

```javascript
async function handleSubmit(e) {
  e.preventDefault();
  const btn = e.submitter;
  btn.disabled = true;
  btn.textContent = '提交中...';

  try {
    const res = await API.post('/api/{module}/save.php', getFormData());
    if (res.code === 0) {
      showToast('保存成功', 'success');
      setTimeout(() => window.history.back(), 800);
    } else {
      showFieldErrors(res.message, res.data?.fields);
    }
  } finally {
    btn.disabled = false;
    btn.textContent = '提交';
  }
}
```

### 12.6 操作按钮规范

| 操作 | 按钮样式 | 权限点 |
| --- | --- | --- |
| 新增 | `btn-primary` | `{module}.create` |
| 编辑 | `btn-outline-primary btn-sm` | `{module}.update` |
| 删除 | `btn-outline-danger btn-sm` | `{module}.delete` |
| 导出 | `btn-outline-secondary` | `{module}.export` |
| 审批 | `btn-success btn-sm` | 在审批中心操作 |
| 提交审批 | `btn-primary` | `{module}.submit` |
| 撤回 | `btn-outline-warning btn-sm` | 发起人本人操作 |

权限按钮在没有权限时应隐藏，不仅仅是禁用。前端通过 `window.__permissions` 数组判断：

```javascript
// 在 includes/layout.php 输出
window.__permissions = <?php echo json_encode($_SESSION['permissions']); ?>;

function hasPermission(code) {
  return window.__permissions.includes(code);
}
// 不具备权限则移除按钮节点
document.querySelectorAll('[data-perm]').forEach(el => {
  if (!hasPermission(el.dataset.perm)) el.remove();
});
```

### 12.7 状态颜色规范

统一使用 Bootstrap 语义色 + 字典颜色字段：

| 状态 | Badge 样式 |
| --- | --- |
| draft 草稿 | `text-secondary` |
| approving 审批中 | `bg-warning text-dark` |
| approved 已审批 | `bg-info` |
| active/processing 执行中 | `bg-primary` |
| completed 已完成 | `bg-success` |
| rejected 已驳回 | `bg-danger` |
| cancelled 已取消 | `text-muted` |
| archived 已归档 | `bg-secondary` |

### 12.8 消息提示规范

```javascript
// /assets/js/common.js
function showToast(msg, type = 'info') {
  // 使用 Bootstrap Toast 组件
  const toast = document.createElement('div');
  toast.className = `toast align-items-center text-bg-${type} border-0`;
  toast.innerHTML = `
    <div class="d-flex">
      <div class="toast-body">${msg}</div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
    </div>`;
  document.querySelector('#toast-container').appendChild(toast);
  new bootstrap.Toast(toast, { delay: 3000 }).show();
  toast.addEventListener('hidden.bs.toast', () => toast.remove());
}

function confirmDialog(msg) {
  return new Promise(resolve => {
    // 使用 Bootstrap Modal 实现确认对话框
    // 避免使用原生 confirm()，保持 UI 一致性
    const modal = document.querySelector('#confirm-modal');
    document.querySelector('#confirm-msg').textContent = msg;
    const bsModal = new bootstrap.Modal(modal);
    bsModal.show();
    modal.querySelector('.btn-confirm').onclick = () => { bsModal.hide(); resolve(true); };
    modal.querySelector('.btn-cancel').onclick  = () => { bsModal.hide(); resolve(false); };
  });
}
```

### 12.9 敏感字段脱敏展示

客户联系人手机号、身份证等字段默认脱敏，具有查看权限时点击展示：

```javascript
function maskValue(val, type) {
  if (!val) return '-';
  if (type === 'phone') return val.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
  if (type === 'id_card') return val.replace(/(\d{6})\d{8}(\d{4})/, '$1********$2');
  return val;
}
```

### 12.10 禁止事项

1. 禁止在任何页面写死业务数据（哪怕是示例数据）。
2. 禁止使用 `alert()`，统一使用 Toast。
3. 禁止使用 `confirm()`，统一使用确认对话框组件。
4. 禁止直接修改 `window.location.href` 触发整页跳转（列表内操作用局部刷新）。
5. 禁止在 `<script>` 内写内联业务逻辑，统一放在 `/assets/js/pages/{module}.js`。
6. 禁止把文件真实路径返回给前端，所有附件通过 `/api/files/download.php` 下载。
