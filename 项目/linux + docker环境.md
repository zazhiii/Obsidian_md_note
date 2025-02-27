

# Docker安装
##  1.卸载旧版

首先如果系统中已经存在旧的Docker，则先卸载：

```Shell
yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
    docker-selinux 
```

## 2.配置Docker的yum库

首先要安装一个yum工具

```Bash
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```

安装成功后，执行命令，配置Docker的yum源（已更新为阿里云源）：

```Bash
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

sudo sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
```

更新yum，建立缓存

```Bash
sudo yum makecache fast
```

# 3.安装Docker

最后，执行命令，安装Docker

```Bash
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```


# 4.启动和校验

```Bash
# 启动Docker
systemctl start docker

# 停止Docker
systemctl stop docker

# 重启
systemctl restart docker

# 设置开机自启
systemctl enable docker

# 执行docker ps命令，如果不报错，说明安装启动成功
docker ps
```
# 5.配置镜像加速

镜像地址可能会变更，如果失效可以百度找最新的docker镜像。

配置镜像步骤如下：

```Bash
# 创建目录
mkdir -p /etc/docker

# 复制内容
tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
        "http://hub-mirror.c.163.com",
        "https://mirrors.tuna.tsinghua.edu.cn",
        "http://mirrors.sohu.com",
        "https://ustc-edu-cn.mirror.aliyuncs.com",
        "https://ccr.ccs.tencentyun.com",
        "https://docker.m.daocloud.io",
        "https://docker.awsl9527.cn"
    ]
}
EOF

# 重新加载配置
systemctl daemon-reload

# 重启Docker
systemctl restart docker
```

  



# 若第二步出现问题
你在执行 `yum install` 时遇到的 **`Failed connect to mirrorlist.centos.org:80; 拒绝连接`** 错误，通常是由于网络配置问题或 CentOS 仓库镜像不可用导致的。以下是具体解决方案：

---

### 原因分析
1. **网络连接问题**：虚拟机无法访问互联网（如 DNS 配置错误、防火墙阻拦、VMware 网络模式配置错误）。
2. **CentOS 7 仓库迁移**：CentOS 7 已于 2024 年 6 月 30 日停止维护（EOL），官方镜像站 `mirrorlist.centos.org` 可能已移除 CentOS 7 的仓库，需切换至归档仓库（如 `vault.centos.org`）。

---

### 解决方案

#### 方法 1：手动替换仓库为归档站点（推荐）
由于 CentOS 7 已停止支持，需将仓库地址指向 `vault.centos.org`（归档仓库）或国内镜像站（如阿里云）。

1. **备份原有仓库文件**：
   ```bash
   sudo mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
   ```

2. **创建新的仓库文件**：
   ```bash
   sudo vi /etc/yum.repos.d/CentOS-Base.repo
   ```

3. **粘贴以下内容（使用 `vault.centos.org`）**：
```ini
   [base]
   name=CentOS-7 - Base
   baseurl=http://vault.centos.org/centos/7/os/$basearch/
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

   [updates]
   name=CentOS-7 - Updates
   baseurl=http://vault.centos.org/centos/7/updates/$basearch/
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

   [extras]
   name=CentOS-7 - Extras
   baseurl=http://vault.centos.org/centos/7/extras/$basearch/
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
   
```

4. **清除缓存并测试**：
   ```bash
   sudo yum clean all
   sudo yum makecache
   sudo yum install -y yum-utils  # 重新安装依赖
   ```

---

#### 方法 2：使用国内镜像加速（如阿里云）
如果网络正常，但官方仓库不可用，可切换至国内镜像源。

1. **替换仓库为阿里云镜像**：
   ```bash
   sudo curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
   ```

2. **更新缓存**：
   ```bash
   sudo yum clean all
   sudo yum makecache
   ```

---

#### 方法 3：检查网络和 DNS 配置
如果上述方法无效，可能是网络本身的问题。

1. **检查网络连通性**：
   ```bash
   ping 8.8.8.8          # 测试是否能访问外网
   ping mirrorlist.centos.org  # 测试域名解析
   ```

2. **修复 DNS 配置**：
   编辑 `/etc/resolv.conf`，添加可靠的 DNS 服务器：
```ini
   nameserver 8.8.8.8
   nameserver 114.114.114.114
   ```

3. **检查防火墙或代理**：
   - 临时关闭防火墙：
     ```bash
     sudo systemctl stop firewalld
     ```
   - 如果有代理，配置 `yum` 使用代理：
     ```bash
     echo "proxy=http://your-proxy-ip:port" >> /etc/yum.conf
     ```

---

#### 方法 4：使用离线包安装（极端情况）
如果完全无法联网，需从其他机器下载 RPM 包后手动安装。

1. **下载依赖包**（需联网环境）：
   ```bash
   yum install --downloadonly --downloaddir=./yum-utils-packages yum-utils device-mapper-persistent-data lvm2
   ```

2. **将包复制到目标机器**，手动安装：
   ```bash
   sudo rpm -ivh *.rpm --nodeps --force
   ```

---

### 验证修复
重新执行 Docker 安装命令：
```bash
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```

---

### 附加说明
- **CentOS 7 EOL 影响**：2024 年 6 月后，官方不再维护 CentOS 7，建议尽快升级到 CentOS Stream 8/9 或迁移到其他发行版（如 AlmaLinux/Rocky Linux）。
- **长期方案**：如果频繁遇到仓库问题，建议使用 `vault.centos.org` 或国内镜像作为临时解决方案。