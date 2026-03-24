# Blog System Backend

基于 Spring Boot + MyBatis 的博客系统后端，支持文章发布、AI 内容审核、申诉复核等完整功能。

## 技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| Spring Boot | 2.7.6 | 核心框架 |
| Spring Security | 2.7.6 | 安全认证 |
| MyBatis | 2.2.2 | ORM 框架 |
| MySQL | 8.0+ | 数据库 |
| JWT | 0.11.5 | Token 认证 |
| DeepSeek API | - | AI 内容审核 |

## 项目结构

```
src/main/java/com/example/demo/
├── config/          # 配置类（Security、JWT、CORS 等）
├── controller/      # 控制器层
│   ├── ArticleController.java   # 文章接口
│   ├── AppealController.java    # 申诉接口
│   ├── AuthController.java      # 认证接口
│   └── UserController.java      # 用户接口
├── entity/          # 实体类
│   ├── Article.java
│   ├── Appeal.java
│   └── User.java
├── mapper/          # MyBatis Mapper 接口
├── service/         # 业务逻辑层
│   ├── impl/        # 实现类
│   ├── ArticleService.java
│   ├── AppealService.java
│   ├── ContentModerationService.java  # AI 审核
│   └── UserService.java
├── dto/             # 数据传输对象
│   ├── request/     # 请求 DTO
│   └── response/    # 响应 DTO
├── exception/       # 自定义异常
├── common/          # 通用类（Result、常量等）
└── DemoApplication.java  # 启动类

src/main/resources/
├── mapper/          # MyBatis XML 映射文件
├── application.properties  # 主配置
└── application-local.properties # 本地开发配置
```

## 核心功能

### 1. 用户认证系统
- 用户注册/登录
- JWT Token 认证
- 角色权限控制（普通用户/管理员）

### 2. 文章管理系统
- 文章 CRUD 操作
- 草稿保存与发布
- 文章搜索与筛选
- 阅读计数统计

### 3. AI 内容审核
- 集成 DeepSeek AI 自动审核
- 违规内容自动标记
- 审核状态实时更新

### 4. 申诉复核流程
- 用户申诉提交
- 管理员申诉处理
- 复核状态追踪

## 状态定义

### 文章状态
| 状态码 | 说明 |
|--------|------|
| 0 | 草稿 |
| 1 | 已发布 |
| 2 | 内容违规 |
| 3 | 复核中 |
| 4 | 复核通过 |
| 5 | 复核拒绝 |

### 申诉状态
| 状态码 | 说明 |
|--------|------|
| 0 | 待处理 |
| 1 | 已批准 |
| 2 | 已驳回 |

## API 接口

### 认证接口
| 方法 | 路径 | 说明 | 权限 |
|------|------|------|------|
| POST | `/api/login` | 用户登录 | 公开 |
| POST | `/api/register` | 用户注册 | 公开 |
| POST | `/api/logout` | 退出登录 | 已认证 |

### 文章接口
| 方法 | 路径 | 说明 | 权限 |
|------|------|------|------|
| GET | `/api/articles` | 获取文章列表 | 公开 |
| GET | `/api/articles/{id}` | 获取文章详情 | 公开 |
| POST | `/api/articles` | 创建文章 | 已认证 |
| PUT | `/api/articles/{id}` | 更新文章 | 作者/管理员 |
| DELETE | `/api/articles/{id}` | 删除文章 | 作者/管理员 |
| POST | `/api/articles/draft` | 保存草稿 | 已认证 |
| PUT | `/api/articles/draft/{id}` | 更新草稿 | 作者 |
| POST | `/api/articles/{id}/publish` | 发布草稿 | 作者 |

### 申诉接口
| 方法 | 路径 | 说明 | 权限 |
|------|------|------|------|
| POST | `/api/appeals` | 提交申诉 | 作者 |
| GET | `/api/appeals` | 获取申诉列表 | 管理员 |
| GET | `/api/appeals/{id}` | 获取申诉详情 | 管理员 |
| PUT | `/api/appeals/{id}/approve` | 批准申诉 | 管理员 |
| PUT | `/api/appeals/{id}/reject` | 驳回申诉 | 管理员 |

### 用户接口
| 方法 | 路径 | 说明 | 权限 |
|------|------|------|------|
| GET | `/api/users` | 获取用户列表 | 管理员 |
| GET | `/api/users/{id}` | 获取用户信息 | 已认证 |
| PUT | `/api/users/{id}` | 更新用户信息 | 本人/管理员 |

## 快速开始

### 环境要求
- JDK 1.8+
- MySQL 8.0+
- Maven 3.6+

### 数据库配置

1. 创建数据库
```sql
CREATE DATABASE blog_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. 执行 SQL 脚本（参考数据库设计文档）

### 配置文件

复制 `application-local.properties` 并修改配置：
```properties
# 数据库配置
spring.datasource.url=jdbc:mysql://localhost:3306/blog_db?serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true
spring.datasource.username=root
spring.datasource.password=your_password

# JWT 配置（自行修改）
jwt.secret=your_jwt_secret_key
jwt.expiration=86400000

# DeepSeek AI 配置（可选，用于内容审核）
deepseek.api.key=your_deepseek_api_key
```

### 启动应用

```bash
# 编译打包
mvn clean package -DskipTests

# 启动应用（使用本地配置）
java -jar target/demo-0.0.1-SNAPSHOT.jar --spring.profiles.active=local
```

或直接在 IDE 中运行 `DemoApplication.java`

### 访问测试

应用启动后访问：
```
http://localhost:8082
```

测试登录：
```bash
curl -X POST http://localhost:8082/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}'
```

## 开发说明

### 管理员账号
默认管理员账号（需提前在数据库中创建）：
- 用户名：`admin`
- 密码：`123456`
- 角色：`ADMIN`

### 内容审核说明
- 文章发布时自动触发 AI 审核
- 审核不通过的文章标记为"内容违规"状态
- 用户可对违规文章提交申诉
- 管理员可对申诉进行复核

### 草稿功能说明
- 状态为 0 的文章为草稿
- 草稿仅作者可见
- 草稿可随时编辑发布

## 部署说明

---

### 🐳 Docker Compose 一键部署（推荐）

#### 环境要求
- Docker 20.10+
- Docker Compose 2.0+

#### 部署步骤

1. **克隆项目并进入目录**
```bash
cd demo
```

2. **配置环境变量**
```bash
# 复制环境变量模板
cp .env.example .env

# 编辑配置（务必修改 JWT_SECRET 和密码）
vim .env
```

3. **一键启动所有服务**
```bash
# 后台启动（首次启动会自动构建镜像）
docker-compose up -d

# 或强制重新构建镜像并启动
docker-compose up -d --build
```

4. **查看服务状态**
```bash
# 查看所有服务状态
docker-compose ps

# 查看日志（实时追踪）
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f backend
```

5. **验证部署**
```bash
# 健康检查
curl http://localhost:8082

# 测试登录接口
curl -X POST http://localhost:8082/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}'
```

6. **停止服务**
```bash
# 停止服务但保留数据
docker-compose stop

# 停止并删除容器（数据卷仍保留）
docker-compose down

# 停止并删除所有（包括数据卷，⚠️ 会清空数据库）
docker-compose down -v
```

#### 服务说明
| 服务 | 容器名 | 端口 | 说明 |
|------|--------|------|------|
| MySQL | blog-mysql | 3306 | 数据库服务，数据持久化 |
| Redis | blog-redis | 6379 | 缓存服务（可选） |
| Backend | blog-backend | 8082 | 后端 API 服务 |

---

### ☁️ 线上部署方案（三选一）

#### 方案一：云服务器部署（推荐，阿里云/腾讯云/华为云）

**准备工作：**
- 购买云服务器（推荐配置：2核4G以上，系统：CentOS 7+/Ubuntu 20.04+）
- 配置安全组，开放端口：`22(SSH)`、`80(HTTP)`、`443(HTTPS)`、`8082(后端)`
- 域名解析（可选，但推荐）

**部署步骤：**

1. **登录云服务器**
```bash
ssh root@your-server-ip
```

2. **安装 Docker 和 Docker Compose**
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com | bash
systemctl start docker
systemctl enable docker

# 安装 Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

3. **部署项目**
```bash
# 克隆或上传项目到服务器
git clone your-repo-url.git
cd demo

# 配置环境变量（生产环境务必修改所有密码）
cp .env.example .env
sed -i 's/DB_PASSWORD=123456/DB_PASSWORD=YourStrongPassword123!/' .env
sed -i 's/JWT_SECRET=your-secret-key/JWT_SECRET=$(openssl rand -hex 32)/' .env

# 启动服务
docker-compose up -d --build
```

4. **配置 Nginx 反向代理（可选但推荐）**
```bash
# 安装 Nginx
apt install nginx -y

# 创建配置文件
cat > /etc/nginx/sites-available/blog-api << 'EOF'
server {
    listen 80;
    server_name api.your-domain.com;

    location / {
        proxy_pass http://localhost:8082;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# 启用配置并重启
ln -s /etc/nginx/sites-available/blog-api /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx
```

#### 方案二：Render 托管（无需服务器，适合小型项目）

1. 访问 [Render.com](https://render.com) 并注册账号
2. 新建 PostgreSQL 数据库（记录连接信息）
3. 新建 Web Service，连接你的 GitHub 仓库
4. 配置构建和启动命令：
   - Build Command: `mvn clean package -DskipTests`
   - Start Command: `java -jar target/demo-0.0.1-SNAPSHOT.jar`
5. 配置环境变量（在 Render 控制台设置）：
```env
SPRING_DATASOURCE_URL=jdbc:mysql://your-db-url:3306/blog_db
SPRING_DATASOURCE_USERNAME=your-db-user
SPRING_DATASOURCE_PASSWORD=your-db-password
JWT_SECRET=your-strong-secret-key
DEEPSEEK_API_KEY=your-api-key
```

#### 方案三：自建服务器部署（传统方式）

1. **安装 JDK 8**
```bash
# Ubuntu
apt install openjdk-8-jdk -y

# CentOS
yum install java-1.8.0-openjdk -y
```

2. **安装 MySQL 8**
```bash
# Ubuntu
apt install mysql-server -y

# 配置 MySQL（创建数据库和用户）
mysql -u root -p << EOF
CREATE DATABASE blog_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'blog_user'@'%' IDENTIFIED BY 'YourStrongPassword123!';
GRANT ALL ON blog_db.* TO 'blog_user'@'%';
FLUSH PRIVILEGES;
EOF
```

3. **部署应用**
```bash
# 构建项目
mvn clean package -DskipTests

# 创建应用目录
mkdir -p /opt/blog
cp target/demo-0.0.1-SNAPSHOT.jar /opt/blog/

# 创建启动脚本
cat > /opt/blog/start.sh << 'EOF'
#!/bin/bash
cd /opt/blog
nohup java -jar demo-0.0.1-SNAPSHOT.jar \
  --spring.profiles.active=prod \
  --spring.datasource.url=jdbc:mysql://localhost:3306/blog_db \
  --spring.datasource.username=blog_user \
  --spring.datasource.password=YourStrongPassword123! \
  --jwt.secret=your-strong-secret-key \
  > app.log 2>&1 &
echo $! > app.pid
EOF

chmod +x /opt/blog/start.sh
/opt/blog/start.sh
```

---

### 📋 部署验证与维护

#### 健康检查
```bash
# 检查容器状态
docker-compose ps

# 检查端口监听
netstat -tlnp | grep 8082

# 测试 API 可用性
curl -I http://localhost:8082/api/articles
```

#### 日志查看
```bash
# Docker 方式
docker-compose logs -f backend --tail 100

# 传统方式
tail -f /opt/blog/app.log
```

#### 数据备份
```bash
# MySQL 备份（Docker 方式）
docker exec blog-mysql mysqldump -u root -pYourPassword blog_db > backup_$(date +%Y%m%d).sql

# 恢复备份
docker exec -i blog-mysql mysql -u root -pYourPassword blog_db < backup.sql
```

#### 版本更新
```bash
# 拉取最新代码
git pull

# 重新构建并启动
docker-compose up -d --build --no-deps backend
```

---

### 🔒 安全建议

1. **务必修改默认密码**：所有默认密码（数据库、JWT密钥）在生产环境必须修改
2. **使用 HTTPS**：生产环境务必配置 SSL 证书（可使用 Let's Encrypt 免费证书）
3. **限制端口访问**：不要直接暴露 MySQL、Redis 端口到公网
4. **定期备份**：配置定时任务自动备份数据库
5. **监控告警**：建议配置服务监控（如 Prometheus + Grafana）

---

### 端口说明
- 默认后端端口：`8082`
- 默认 MySQL 端口：`3306`
- 默认 Redis 端口：`6379`

## 许可证

MIT
