# 构建阶段
FROM maven:3.8.6-jdk-8 AS builder

# 设置工作目录
WORKDIR /app

# 添加阿里云 Maven 镜像源配置（解决国内网络访问问题）
RUN mkdir -p /root/.m2 && echo '<?xml version="1.0" encoding="UTF-8"?>\
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"\
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0\
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">\
  <mirrors>\
    <mirror>\
      <id>aliyun</id>\
      <mirrorOf>central</mirrorOf>\
      <name>Aliyun Maven Mirror</name>\
      <url>https://maven.aliyun.com/repository/central</url>\
    </mirror>\
    <mirror>\
      <id>aliyun-spring</id>\
      <mirrorOf>spring-milestones</mirrorOf>\
      <name>Aliyun Spring Mirror</name>\
      <url>https://maven.aliyun.com/repository/spring</url>\
    </mirror>\
  </mirrors>\
</settings>' > /root/.m2/settings.xml

# 复制 pom.xml 并下载依赖（缓存优化）
COPY pom.xml .
RUN mvn dependency:go-offline -B

# 复制源代码并构建
COPY src ./src
RUN mvn clean package -DskipTests

# 运行阶段
FROM openjdk:8-jre-slim

# 设置工作目录
WORKDIR /app

# 从构建阶段复制 jar 文件
COPY --from=builder /app/target/*.jar app.jar

# 暴露端口
EXPOSE 8082

# 设置启动命令
ENTRYPOINT ["java", "-jar", "app.jar"]
