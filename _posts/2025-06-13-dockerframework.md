---
layout: post
title:  "Docker 架构详解与核心概念实战图解"
summary: "docker framework"
author: Miles
date: '2025-06-13 11:30:23 +0530'
category: docker
thumbnail: /assets/img/posts/docker.png
keywords: docker
usemathjax: true
permalink: /blog/docker-framework/
---
在学习 Docker 之前，很多同学可能会陷入一个误区：“反正我用 docker run 就能跑起服务，架构这种东西懂不懂无所谓。”其实这是极其危险的。理解 Docker 的架构，就像理解 Java 的 JVM、Spring 的 IoC、K8s 的控制器一样，是掌握容器核心原理的基础。
本文我们将从实战与底层角度，全面剖析 Docker 的架构与核心组件，配合架构图，做到真正“看得懂、说得清、用得顺”。

# 一、Docker 到底是什么？
Docker 是一个开源的容器化平台，用于打包、发布和运行应用程序。通过将应用及其所有依赖打包进一个轻量级的镜像中，Docker 实现了一次构建，处处运行的目标。
但 Docker 并不是凭空产生，它基于 Linux 的以下三大核心技术：
- Namespaces：实现进程隔离（例如网络、PID、文件系统）
- cgroups：实现资源限制（CPU、内存等）
- UnionFS / OverlayFS：实现镜像的分层存储
你可以把 Docker 理解为：一个将 Linux 内核功能抽象封装为容器工具集的平台

# 二、Docker 架构全景图（Mermaid 图）
我们先上图，直观理解 Docker 架构中各组件如何协作。
[![Image text](/assets/img/posts/docker1.png)](/assets/img/posts/docker1.png)

**说明：**

- Docker CLI 发送命令到 Docker Daemon。
- Daemon 提供 REST 接口，并负责处理镜像、容器、网络等逻辑。
- Image Manager、Container Manager、Network Manager 各司其职。
- 镜像通过远程 Registry（如 Docker Hub、Harbor）进行 pull 和 push 操作。

# 三、Docker 核心组件详解

## 1. Docker CLI（客户端）

你平时敲的 docker run、docker ps 命令，其实只是和 Docker Daemon 通信的一个**前端界面**。

常见命令例如：

```bash
docker run -d -p 80:80 nginx
docker ps
docker logs <容器ID>
```

CLI 默认通过 UNIX socket /var/run/docker.sock 与 Daemon 通信。


## 2. Docker Daemon（守护进程）

这是 Docker 的核心服务，后台常驻。所有 Docker 命令，最终都由 Daemon 处理：

- 它监听 REST API 请求
- 负责构建、运行容器
- 管理网络、挂载卷、日志记录

```bash
# 查看 docker 服务状态
systemctl status docker
```


## 3. Docker REST API

Docker 提供一套 HTTP API（可选开放），用来被远程调用或集成 CI/CD 工具。

```bash

 
curl --unix-socket /var/run/docker.sock http://localhost/containers/json
```

你也可以开启 TCP 监听端口：

```bash

 
dockerd -H tcp://0.0.0.0:2375
```

**注意：未加 TLS 的 API 暴露端口极不安全，请谨慎使用！**


## 4. 镜像（Images）

镜像是容器的“模板”，它是由多个只读的分层构成：

- 每一层是前一层的增量更新
- 顶层镜像为只读，容器运行时加上一个可写层

```bash
docker image ls
docker pull nginx:1.24
```

**镜像存储结构图：**
[![Image text](/assets/img/posts/docker2.png)](/assets/img/posts/docker2.png)

✅ 图示说明：

| **层级**  | **描述**                             | **特性**                       |
| --------- | ------------------------------------ | ------------------------------ |
| Layer 0   | 基础镜像层（如 Ubuntu、Alpine）      | 通常由官方提供，最底层         |
| Layer 1~3 | 增量构建层（如安装依赖、拷贝代码等） | 每层都是上一层的只读快照       |
| Writable  | 容器运行时的可写层                   | 暂存运行时更改，容器销毁即消失 |


## 5. 容器（Containers）

容器本质上是运行时的镜像副本，是**镜像的实例化进程**。

- 容器是镜像 + 可写层 + 隔离技术（namespace + cgroup）的集合体
- 容器是短暂的，可删可重建；而镜像是持久的

```bash
docker run -it ubuntu bash
docker exec -it 容器ID /bin/bash
```


## 6. 仓库（Registry）

- **公共仓库**：Docker Hub（官方，免费镜像有限速）
- **私有仓库**：Harbor（企业常用，支持漏洞扫描、镜像签名）

```bash
docker pull nginx
docker tag nginx myharbor.local/nginx
docker push myharbor.local/nginx
```

私有仓库往往结合企业 CI/CD 流水线使用，支持用户认证、镜像清理、镜像扫描等高级功能。

## 7. Docker Storage（Volume / Bind Mount）

容器是临时性的，默认停止就会丢数据，因此要用数据卷（Volume）来挂载持久化数据。

```bash
docker volume create mydata
docker run -v mydata:/app/data nginx
```


# 四、Docker 的核心使用场景

## 1. 开发环境快速构建

你可以几分钟拉起一个 MySQL + Redis + Nginx 的本地环境：

```bash
docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=123456 mysql:8
docker run -d --name redis redis
docker run -d -p 80:80 nginx
```

## 2. 测试隔离环境

不同团队、不同项目可以用不同容器隔离运行版本，互不干扰。

## 3. CI/CD 自动化部署

配合 GitLab CI、GitHub Actions、Jenkins，可以做到每次提交自动构建镜像、部署到测试或生产环境。


# 五、实战：一步步理解 Nginx 容器的生命周期

```bash
# 1. 拉取镜像
docker pull nginx:latest

# 2. 运行容器
docker run -d -p 8080:80 --name mynginx nginx

# 3. 查看容器状态
docker ps

# 4. 进入容器
docker exec -it mynginx /bin/bash

# 5. 停止并删除容器
docker stop mynginx && docker rm mynginx
```

## 容器生命周期简图：
[![Image text](/assets/img/posts/docker3.png)](/assets/img/posts/docker3.png)

# 六、你必须知道的几个误区

❌ **“容器 = 镜像”？**
 ✅ 镜像是模板，容器是运行的进程。

❌ **“容器运行完就数据丢失了”？**
 ✅ 是的，如果不挂载 Volume 或 Bind Mount。

❌ **“Docker 默认不安全”？**
 ✅ Docker 需要合理配置 daemon 参数、权限控制、API 安全、镜像扫描等。


# 七、总结：理解架构，才能玩转 Docker

通过本文，你应该已经掌握：

- Docker 的完整架构及组件关系图
- 每个组件的功能与常用命令
- 容器、镜像、仓库的生命周期与交互流程
- 使用 Docker 管理服务、构建环境、集成 DevOps 的核心能力
