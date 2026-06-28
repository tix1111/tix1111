# 前端规范、审批引擎、错误码与文件安全

## 1. 错误码体系

所有 API 统一使用以下错误码，前端按 `code` 字段判断处理方式：

| code | 含义 | 前端处理 |
| --- | --- | --- |
| 0 | 成功 | 正常渲染数据 |
| 1001 | 参数缺失 | 提示并定位字段 |
| 1002 | 参数格式错误 | 提示并定位字段 |
| 1003 | 数据不存在 | 提示并返回列表 |
| 1004 | 数据重复 | 提示重复字段 |
| 2001 | 未登录 | 跳转登录页 |
| 2002 | 验证码错误 | 提示刷新验证码 |
| 2003 | 账号被锁定 | 提示联系管理员 |
| 2004 | 账号禁用 | 提示联系管理员 |
| 2005 | Token/会话失效 | 跳转登录页 |
| 3001 | 无菜单权限 | 跳转首页 |
| 3002 | 无操作权限 | 提示无权限 |
| 3003 | 无数据权限 | 提示无权限 |
| 3004 | 无密级权限 | 提示无密级授权 |
| 3005 | 超出知悉范围 | 提示无权查看 |
| 4001 | 业务规则冲突 | 提示具体规则 |
| 4002 | 状态不允许操作 | 提示当前状态 |
| 4003 | 审批流程不存在 | 提示配置审批 |
| 4004 | 库存不足 | 提示库存量 |
| 4005 | 预算超限 | 提示预算余额 |
| 4006 | 金额异常 | 提示金额错误 |
| 4007 | 时间范围错误 | 提示时间约束 |
| 5001 | 服务器内部错误 | 提示稍后重试 |
| 5002 | 数据库操作失败 | 提示稍后重试 |
| 5003 | 文件操作失败 | 提示重新上传 |

## 2. 文件上传安全规范

### 2.1 客户端校验（前端）

1. 检查文件扩展名白名单（从系统参数获取）。
2. 检查文件大小不超过上限。
3. 上传前显示文件名和大小预览。

### 2.2 服务端校验（PHP）

```php
// includes/upload.php 应实现以下校验：
// 1. 检查 $_FILES 是否存在且 error=0
// 2. 检查文件大小 <= system_settings.upload.max_size_mb
// 3. 检查扩展名是否在白名单（不信任客户端扩展名）
// 4. 用 finfo_file 获取真实 MIME 类型，与扩展名交叉验证
// 5. 生成随机存储文件名（不使用原始文件名避免路径遍历）：
//    $stored_name = bin2hex(random_bytes(16)) . '.' . $ext;
// 6. 存储到 upload_path + date('Ym') + '/' 防止单目录过多文件
// 7. 禁止上传到 web 可直接访问的路径，访问必须通过 /api/files/download.php
// 8. 记录到 attachments 表，绑定 business_type 和 business_id
// 9. 写入 operation_logs
```

### 2.3 文件下载安全

```text
/api/files/download.php?id={attachment_id}
```

执行顺序：

1. 校验登录态。
2. 查询 `attachments` 表，确认 `id` 存在且未删除。
3. 查询业务单据权限（`business_type + business_id`）。
4. 查询附件密级，与用户密级授权比对。
5. 查询知悉范围，校验当前用户是否在授权列表。
6. 所有校验通过后，用 `readfile()` 输出文件并设置 `Content-Disposition`。
7. 写入 `classified_audit_logs`（涉密附件）或 `operation_logs`（普通附件）。
8. 更新 `attachments.download_count`。

### 2.4 禁止行为

1. 不得直接 `echo $_FILES['file']['name']` 作为存储文件名。
2. 不得直接暴露 `file_path` 给前端。
3. 不得允许上传 `.php` `.phtml` `.php3` 等可执行文件。
4. 不得使用 `move_uploaded_file` 到 web 可访问目录后直接返回 URL。

## 3. 前端骨架规范

### 3.1 页面模板结构

所有后台页面使用统一布局：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>页面标题 - 企业管理系统</title>
  <!-- Bootstrap CSS from bootcdn -->
  <link href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
  <!-- 自有样式 -->
  <link href="/assets/css/main.css" rel="stylesheet">
</head>
<body class="layout-fixed">
  <!-- 顶部导航 -->
  <?php include '/pages/layout/topbar.php'; ?>

  <div class="d-flex" style="min-height:calc(100vh - 56px)">
    <!-- 左侧菜单（动态渲染） -->
    <?php include '/pages/layout/sidebar.php'; ?>

    <!-- 主内容区 -->
    <main class="flex-grow-1 p-3" id="main-content">
      <!-- 面包屑 -->
      <nav aria-label="breadcrumb" id="breadcrumb-container"></nav>

      <!-- 页面内容 -->
      <div id="page-content">
        <!-- 各页面注入 -->
      </div>
    </main>
  </div>

  <!-- Bootstrap JS from bootcdn -->
  <script src="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
  <!-- 公共 JS -->
  <script src="/assets/js/common.js"></script>
  <script src="/assets/js/api.js"></script>
  <!-- 页面 JS -->
  <script src="/assets/js/pages/{module}.js"></script>
</body>
</html>
```

### 3.2 公共 JS 模块建议

`/assets/js/api.js` 统一封装 AJAX：

```javascript
const API = {
  // 统一请求封装
  request(method, url, data, options = {}) {
    return fetch(url, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
      },
      body: method !== 'GET' ? JSON.stringify(data) : undefined,
    })
      .then(r => r.json())
      .then(res => {
        if (res.code === 2001 || res.code === 2005) {
          window.location.href = '/pages/auth/login.php';
          return;
        }
        return res;
      });
  },
  get: (url, params) => API.request('GET', url + '?' + new URLSearchParams(params)),
  post: (url, data) => API.request('POST', url, data),
  put: (url, data) => API.request('PUT', url, data),
  delete: (url, data) => API.request('DELETE', url, data),
};
```

### 3.3 实时无刷新落地方式

建议一期使用两种方式：

1. **AJAX 局部刷新**：表单提交、列表刷新、详情更新使用 `fetch` + 局部 DOM 更新。
2. **定时轮询**：工作台待办数量、通知未读数量，每 60 秒轮询一次。

二期按需引入 Server-Sent Events：

```javascript
// 待办数量实时推送示例（SSE）
const sse = new EventSource('/api/workbench/sse.php');
sse.onmessage = (e) => {
  const data = JSON.parse(e.data);
  document.querySelector('#todo-count').textContent = data.todo_count;
};
```

## 4. 审批引擎落地规则

### 4.1 发起审批

业务模块提交单据时，调用公共审批服务：

```php
// includes/approval.php
function startApproval($businessType, $businessId, $title, $initiatorId) {
    $flow = findFlowByBusinessType($businessType);
    if (!$flow) return false;
    
    $approvalId = insertApproval($flow, $businessType, $businessId, $title, $initiatorId);
    $firstNode = getFirstNode($flow->id);
    assignTask($approvalId, $firstNode, $initiatorId);
    notifyAssignee($firstNode, $title);
    return $approvalId;
}
```

### 4.2 审批动作

审批任务处理接口 `/api/approval/tasks/action.php`：

1. 校验当前用户是任务处理人。
2. 记录 `approval_tasks.action` 和 `comment`。
3. 判断节点是否全部完成（`approve_mode=all` 时）。
4. 进入下一节点或结束审批。
5. 结束时回调业务模块更新 `approval_status`。
6. 发送通知给发起人和下一节点处理人。

### 4.3 条件分支

节点 `condition_rule` 使用 JSON 描述：

```json
{
  "field": "total_amount",
  "operator": ">",
  "value": 10000
}
```

计算时从关联业务单据中取值。支持：`>` `<` `>=` `<=` `=` `!=` `in` `not_in`。

### 4.4 超时处理

每次审批任务创建时写入 `due_at`。后端定时任务每小时检查：

1. 超时未处理：发送催办通知。
2. 超时时间超过 2 倍：执行 `timeout_action`（pass/reject/notify）。

## 5. PHP 公共工具库建议

### 5.1 `includes/db.php`

```php
class DB {
    private static ?PDO $pdo = null;

    public static function conn(): PDO {
        if (!self::$pdo) {
            self::$pdo = new PDO(
                'mysql:host=127.0.0.1;dbname=lz;charset=utf8mb4',
                'root', 'rootroot',
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]
            );
        }
        return self::$pdo;
    }

    public static function query(string $sql, array $params = []): array {
        $stmt = self::conn()->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function execute(string $sql, array $params = []): int {
        $stmt = self::conn()->prepare($sql);
        $stmt->execute($params);
        return $stmt->rowCount();
    }

    public static function insertId(): string {
        return self::conn()->lastInsertId();
    }
}
```

### 5.2 `includes/response.php`

```php
function respond(int $code, string $message, $data = null): never {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'code'    => $code,
        'message' => $message,
        'data'    => $data,
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

function success($data = null, string $message = 'success'): never {
    respond(0, $message, $data);
}

function fail(int $code, string $message, $data = null): never {
    respond($code, $message, $data);
}
```

### 5.3 `includes/permission.php`

```php
function requireLogin(): int {
    session_start();
    if (empty($_SESSION['user_id'])) {
        fail(2001, '未登录');
    }
    return (int)$_SESSION['user_id'];
}

function requirePermission(string $code): void {
    $userId = requireLogin();
    $perms  = $_SESSION['permissions'] ?? [];
    if (!in_array($code, $perms, true)) {
        fail(3002, '无操作权限');
    }
}

function requireDataScope(string $businessType, int $businessId): void {
    // 查询业务单据归属，与用户数据范围对比
    // 若数据范围不符合，调用 fail(3003, '无数据权限')
}
```
