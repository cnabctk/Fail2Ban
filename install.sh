#!/bin/bash

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
  echo "请以 root 权限运行此脚本"
  exit
fi

echo "正在安装 Fail2Ban..."
# 更新包列表并安装
apt-get update && apt-get install -y fail2ban

echo "正在备份原始配置..."
[ -f /etc/fail2ban/jail.local ] && cp /etc/fail2ban/jail.local /etc/fail2ban/jail.local.bak

echo "正在生成优化后的 jail.local 配置文件..."

cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
# 忽略自己的本地 IP，防止误封 (可以自行添加你的固定IP)
ignoreip = 127.0.0.1/8 ::1

# --- 核心优化参数 ---

# 基础封禁时间改为 1 天 (针对你看到的庞大攻击量，必须大幅增加) [我下面写了10]
bantime  = 10d

# 统计窗口时间改为 1 小时 (在更长的时间内捕捉多次失败的 IP)
findtime  = 10m

# 允许重试的次数 (3 次失败即封禁)
maxretry = 3

# --- 启用阶梯式封禁 (Bantime Increment) ---
# 这会让那些解封后又回来的“老客”被封得更久
bantime.increment = true

# 递增倍数 (1d -> 2d -> 4d -> 8d...)
bantime.factor = 1

# 最大封禁上限 (封禁时间最高增加到 5 周)
bantime.maxtime = 20w

# 引入随机时间偏移，防止攻击脚本通过定时任务绕过
bantime.rndtime = 10m

[sshd]
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
# 针对 SSH 采用严苛模式
filter  = sshd[mode=aggressive]
EOF

echo "正在重启 Fail2Ban 服务..."
systemctl restart fail2ban
systemctl enable fail2ban

echo "------------------------------------------------"
echo "安装与配置完成！"
echo "当前策略：1小时内错3次封禁1天，再次违规封禁时长翻倍。"
echo "你可以使用 'fail2ban-client status sshd' 查看最新动态。"
echo "------------------------------------------------"
