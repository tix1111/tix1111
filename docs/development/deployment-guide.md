# 部署与环境配置指南

## 1. 环境要求

| 组件 | 版本要求 | 说明 |
| --- | --- | --- |
| PHP | >= 7.4（推荐 8.1） | 必须启用 PDO、json、mbstring、fileinfo 扩展 |
| MySQL | >= 5.7（推荐 8.0） | 必须支持 JSON 数据类型和 FULLTEXT |
| Nginx | >= 1.18 | 推荐，也可用 Apache 2.4 |
| 操作系统 | CentOS 7+、Debian 10+、Ubuntu 20.04+ | — |

## 2. 数据库初始化

```bash
mysql -uroot -p << 'EOF'
CREATE DATABASE IF NOT EXISTS lz
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;
EOF

# 执行建表
mysql -uroot -p lz < sql/schema.sql

# 执行初始化数据
mysql -uroot -p lz < sql/init.sql

# 初始化编号计数器表
mysql -uroot -p lz << 'EOF'
CREATE TABLE IF NOT EXISTS no_counters (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  prefix      VARCHAR(32) NOT NULL UNIQUE,
  current_seq INT UNSIGNED NOT NULL DEFAULT 0,
  updated_at  DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
EOF

# 初始化管理员密码（在代码中执行，不在 SQL 中写明文）
php sql/init_passwords.php
```

## 3. `sql/init_passwords.php`

```php
<?php
require_once __DIR__ . '/../includes/db.php';

$passwords = [
    'admin' => 'Admin@2025!',  // 首次登录必须修改
    'dpt1'  => 'Dpt1@2025!',
    'user1' => 'User1@2025!',
];

foreach ($passwords as $username => $pwd) {
    $hash = password_hash($pwd, PASSWORD_BCRYPT);
    DB::execute(
        'UPDATE users SET password_hash = ? WHERE username = ?',
        [$hash, $username]
    );
}
echo "密码初始化完成\n";
```

## 4. Nginx 配置

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    root /var/www/html;
    index index.php index.html;

    # 涉密内网部署推荐只监听内网 IP
    # listen 192.168.1.100:80;

    # 安全响应头
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy no-referrer-when-downgrade;

    # API 路由
    location /api/ {
        try_files $uri $uri/ =404;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    }

    # PHP 页面
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    }

    # SSE 支持（关闭 buffering）
    location /api/workbench/sse.php {
        proxy_buffering off;
        proxy_read_timeout 300s;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    }

    # 禁止访问上传目录的 PHP 文件（防止文件执行漏洞）
    location ~* ^/uploads/.*\.php {
        deny all;
    }

    # 禁止直接访问 includes、config、sql 目录
    location ~* ^/(includes|config|sql)/ {
        deny all;
        return 403;
    }

    # 静态文件缓存
    location ~* \.(css|js|png|jpg|jpeg|gif|svg|ico|woff2?)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
```

## 5. PHP 配置（php.ini）

```ini
; 文件上传
file_uploads = On
upload_max_filesize = 50M
post_max_size = 55M
max_file_uploads = 20

; 会话
session.gc_maxlifetime = 7200
session.cookie_httponly = 1
session.cookie_samesite = Strict

; 安全
expose_php = Off
display_errors = Off
log_errors = On
error_log = /var/log/php/error.log

; 性能
memory_limit = 256M
max_execution_time = 60
```

## 6. 目录权限

```bash
# Web 根目录
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# 上传目录（写权限）
mkdir -p /var/www/html/uploads
chown www-data:www-data /var/www/html/uploads
chmod 750 /var/www/html/uploads

# 日志目录
mkdir -p /var/log/app
chown www-data:www-data /var/log/app
chmod 750 /var/log/app

# config 目录（只读）
chmod 640 /var/www/html/config/database.php
```

## 7. `config/database.php`

```php
<?php
return [
    'host'     => '127.0.0.1',
    'port'     => 3306,
    'dbname'   => 'lz',
    'username' => 'root',       // 生产环境建议使用专用账号，仅具备 SELECT/INSERT/UPDATE/DELETE 权限
    'password' => 'rootroot',   // 生产环境从环境变量读取：getenv('DB_PASSWORD')
    'charset'  => 'utf8mb4',
    'options'  => [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_EMULATE_PREPARES   => false,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ],
];
```

## 8. 涉密内网部署注意事项

1. **禁止公网访问**：仅在内网防火墙内访问，Nginx 只监听内网 IP。
2. **bootcdn 替换**：需将 bootcdn 上的 CSS/JS 下载到内网镜像服务器，修改页面引用路径。
3. **短信验证码**：如不接入公网短信网关，建议改为内网邮件验证或由管理员线下重置密码。
4. **文件上传路径**：上传目录不得在 web 可直接访问的路径，所有下载走 `/api/files/download.php`。
5. **HTTPS**：内网部署也应配置自签名证书或内网 CA 颁发的证书，防止内网嗅探。
6. **数据库备份**：备份文件加密存储，传输到备份服务器时使用 scp/rsync+SSH。
7. **日志保留**：涉密审计日志保留期不低于相关管理规定要求（通常 3-5 年）。

## 9. 数据备份方案

```bash
#!/bin/bash
# /usr/local/bin/backup_db.sh

DB_NAME=lz
DB_USER=root
DB_PASS=rootroot
BACKUP_DIR=/backup/db
DATE=$(date +%Y%m%d_%H%M%S)
FILE="$BACKUP_DIR/${DB_NAME}_${DATE}.sql.gz"

mkdir -p $BACKUP_DIR

mysqldump -u$DB_USER -p$DB_PASS \
    --single-transaction \
    --routines \
    --triggers \
    $DB_NAME | gzip > $FILE

# 保留最近 30 天的备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete

echo "备份完成: $FILE"
```

```bash
# crontab -e
# 每天凌晨 2:00 执行数据库备份
0 2 * * * /usr/local/bin/backup_db.sh >> /var/log/backup.log 2>&1
```

## 10. 健康检查接口

```php
// /api/health.php
<?php
header('Content-Type: application/json');
try {
    $db = DB::conn();
    $db->query('SELECT 1');
    echo json_encode(['status' => 'ok', 'time' => date('Y-m-d H:i:s')]);
} catch (\Exception $e) {
    http_response_code(503);
    echo json_encode(['status' => 'error', 'message' => 'Database connection failed']);
}
```
