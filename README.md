配置特点:开启“阶梯惩罚”：
bantime.increment = true 是对付分布式肉机最有效的手段。 
如果某个 IP 第二次被抓，它将被封禁 2 天，以此类推，最高封禁 5 周。

一键安装：    

    bash <(curl -fsSL https://raw.githubusercontent.com/cnabctk/Fail2Ban/refs/heads/main/install.sh)
