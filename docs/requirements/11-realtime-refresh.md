# 涉密含党支部企业管理系统需求文档

> 本文件由根目录 `需求文档.md` 拆分而来，便于 GitHub 直接预览。完整总览请查看 `../../REQUIREMENTS.md`。

## 11. 实时无刷新方案

### 11.1 适用场景

所有以下场景不需要整页刷新：

1. 待办数量和徽章更新。
2. 通知公告提醒。
3. 审批状态变化。
4. 工单派工和状态变化。
5. 项目进度、工程进度反馈。
6. 库存预警。
7. 协作团队派工、执行反馈和结算审批提醒。
8. 供应商询价、竞价报价、采购订单、发货到货提醒。
9. 表单字段联动（如费用类别联动预算科目）。
10. 下拉/搜索联想框（如项目、客户、物料搜索）。

### 11.2 技术方案选择

| 方案 | 适用场景 | 优先级 |
| --- | --- | --- |
| AJAX 局部刷新 | 列表重载、详情更新、表单提交、仪表盘卡片 | 最高，所有页面操作 |
| 定时轮询 | 工作台待办数量、顶部消息图标徽章 | 一期首选 |
| Server-Sent Events | 审批状态推送、工单实时通知 | 二期扩展 |
| WebSocket | 多人协同、在线会议、实时讨论 | 后续按需 |

**一期策略**：全部使用 AJAX + 定时轮询。

**二期策略**：待办、消息、审批通知迁移到 SSE。

### 11.3 定时轮询实现

**顶部消息图标轮询**：

```javascript
// /assets/js/polling.js
const Polling = {
  interval: null,

  start() {
    // 首次立即执行
    this.fetchCounts();
    // 每 60 秒轮询一次
    this.interval = setInterval(() => this.fetchCounts(), 60000);
  },

  stop() {
    if (this.interval) clearInterval(this.interval);
  },

  fetchCounts() {
    API.get('/api/workbench/counts.php').then(res => {
      if (res.code !== 0) return;
      document.querySelector('#todo-count').textContent = res.data.todo_count || 0;
      document.querySelector('#msg-count').textContent  = res.data.msg_count  || 0;
      // 有未读时显示徽章
      document.querySelector('#todo-badge').style.display = res.data.todo_count ? '' : 'none';
    });
  }
};

document.addEventListener('DOMContentLoaded', () => Polling.start());
```

**工作台仪表盘局部刷新**：

```javascript
// 仅刷新卡片内容，不刷新整页
function refreshDashboard() {
  API.get('/api/workbench/summary.php').then(res => {
    if (res.code !== 0) return;
    document.querySelector('#todo-list').innerHTML = renderTodos(res.data.todos);
    document.querySelector('#metrics-panel').innerHTML = renderMetrics(res.data.metrics);
  });
}
```

### 11.4 AJAX 表单提交

```javascript
// 统一表单提交，不刷新整页
function submitForm(formEl, apiUrl, onSuccess) {
  const data = Object.fromEntries(new FormData(formEl));
  API.post(apiUrl, data).then(res => {
    if (res.code === 0) {
      showToast('保存成功', 'success');
      if (onSuccess) onSuccess(res.data);
    } else {
      showToast(res.message, 'error');
    }
  });
}
```

### 11.5 SSE 服务端实现（PHP）

```php
// /api/workbench/sse.php
<?php
session_start();
require_once '../../includes/auth.php';
$userId = requireLogin();

header('Content-Type: text/event-stream');
header('Cache-Control: no-cache');
header('X-Accel-Buffering: no');

// 断开连接时清理
register_shutdown_function(function() {
    // 清理资源
});

$lastCheck = time();
while (true) {
    if (connection_aborted()) break;

    $now = time();
    if ($now - $lastCheck >= 5) {
        $data = getNewEvents($userId, $lastCheck);
        if (!empty($data)) {
            echo "data: " . json_encode($data) . "\n\n";
            ob_flush();
            flush();
        }
        $lastCheck = $now;
    }
    sleep(1);
}
```

**前端订阅 SSE**：

```javascript
// 仅高权限或关键业务页面开启 SSE
function startSSE() {
  const evtSource = new EventSource('/api/workbench/sse.php');
  evtSource.onmessage = (e) => {
    const data = JSON.parse(e.data);
    handleRealtimeEvent(data);
  };
  evtSource.onerror = () => {
    // 断线后回退到轮询
    evtSource.close();
    Polling.start();
  };
  return evtSource;
}
```

### 11.6 下拉搜索联想

```javascript
// 客户搜索示例
function initCustomerSearch(inputEl, callback) {
  let timer = null;
  inputEl.addEventListener('input', () => {
    clearTimeout(timer);
    const kw = inputEl.value.trim();
    if (kw.length < 1) return;
    timer = setTimeout(() => {
      API.get('/api/ref/customers.php', { q: kw, limit: 10 })
        .then(res => {
          if (res.code === 0) renderDropdown(inputEl, res.data, callback);
        });
    }, 300); // 防抖 300ms
  });
}
```

### 11.7 注意事项

1. 轮询间隔不应小于 30 秒，避免频繁请求造成服务器压力。
2. 页面隐藏时（`visibilitychange`）应暂停轮询。
3. SSE 连接必须有超时断开机制（建议 5 分钟），断开后客户端重连。
4. 涉密场景下 SSE 推送只能包含元数据（如事件类型、ID），不可推送涉密内容。
5. Nginx 需要关闭 `proxy_buffering off` 以支持 SSE 实时推送。
