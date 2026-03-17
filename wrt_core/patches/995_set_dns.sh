#!/bin/bash
# SmartDNS + AdGuard Home 默认配置脚本

configure_dns() {
    echo "正在配置 SmartDNS + AdGuard Home..."
    
    # ============================================
    # 1. 配置 SmartDNS
    # ============================================
    
    # 设置 SmartDNS 监听端口（主 DNS 端口）
    uci set smartdns.@smartdns[0].port='6053'
    
    # 设置上游 DNS 服务器（云南联通优化）
    # 本地 DNS（速度快）
    uci add_list smartdns.@server[0].server='221.3.131.11'
    uci add_list smartdns.@server[0].server='221.3.131.12'
    
    # 阿里 DNS（全国通用）
    uci add_list smartdns.@server[1].server='223.5.5.5'
    uci add_list smartdns.@server[1].server='223.6.6.6'
    
    # 腾讯 DNS（备用）
    uci add_list smartdns.@server[2].server='119.29.29.29'
    uci add_list smartdns.@server[2].server='182.254.116.116'
    
    # Google DNS（访问国外网站）
    uci add_list smartdns.@server[3].server='8.8.8.8'
    uci add_list smartdns.@server[3].server='8.8.4.4'
    
    # Cloudflare DNS（GitHub 加速）
    uci add_list smartdns.@server[4].server='1.1.1.1'
    uci add_list smartdns.@server[4].server='1.0.0.1'
    
    # 启用 DNS over TLS（加密 DNS）
    uci add_list smartdns.@server[5].server='tls://223.5.5.5'
    uci add_list smartdns.@server[5].server='tls://1.1.1.1'
    
    # SmartDNS 优化设置
    uci set smartdns.@smartdns[0].cache_size='51200'
    uci set smartdns.@smartdns[0].prefetch_domain='1'
    uci set smartdns.@smartdns[0].serve_expired='1'
    uci set smartdns.@smartdns[0].serve_expired_ttl='7200'
    uci set smartdns.@smartdns[0].reply_ttl='5'
    uci set smartdns.@smartdns[0].max_reply_ip_num='3'
    uci set smartdns.@smartdns[0].dualstack_ip_selection='1'
    uci set smartdns.@smartdns[0].dualstack_ip_selection_threshold='15'
    uci set smartdns.@smartdns[0].speed_check_mode='tcp:443,tcp:80,ping,icmp'
    uci set smartdns.@smartdns[0].ip_set_timeouts='150,300,450,600'
    uci set smartdns.@smartdns[0].force_aaaa_soa='0'
    uci set smartdns.@smartdns[0].rr_ttl='600'
    uci set smartdns.@smartdns[0].rr_ttl_min='60'
    uci set smartdns.@smartdns[0].rr_ttl_max='86400'
    uci set smartdns.@smartdns[0].rr_ttl_reply_max='300'
    
    # 启用域名缓存和预加载
    uci set smartdns.@smartdns[0].cache_persist='1'
    uci set smartdns.@smartdns[0].load_cron='/etc/crontabs/root'
    
    # 提交 SmartDNS 配置
    uci commit smartdns
    
    # ============================================
    # 2. 配置 AdGuard Home
    # ============================================
    
    # AdGuard Home 监听端口（客户端使用）
    uci set adguardhome.adguardhome.redirect='53'
    uci set adguardhome.adguardhome.port='3000'
    uci set adguardhome.adguardhome.upstream='127.0.0.1:6053'
    uci set adguardhome.adguardhome.bootstrap='127.0.0.1:6053'
    
    # 提交 AdGuard Home 配置
    uci commit adguardhome
    
    # ============================================
    # 3. 配置防火墙（确保 DNS 转发正常）
    # ============================================
    
    # 允许 DNS 流量
    uci add firewall rule
    uci set firewall.@rule[-1].name='Allow-DNS'
    uci set firewall.@rule[-1].src='*'
    uci set firewall.@rule[-1].proto='tcpudp'
    uci set firewall.@rule[-1].dest_port='53 6053'
    uci set firewall.@rule[-1].target='ACCEPT'
    
    # 提交防火墙配置
    uci commit firewall
    
    # ============================================
    # 4. 重启服务
    # ============================================
    
    echo "重启 SmartDNS 服务..."
    /etc/init.d/smartdns restart
    
    echo "重启 AdGuard Home 服务..."
    /etc/init.d/adguardhome restart
    
    echo "DNS 配置完成！"
    echo ""
    echo "=========================================="
    echo "SmartDNS + AdGuard Home 配置信息"
    echo "=========================================="
    echo "AdGuard Home 管理界面：http://10.0.0.1:3000"
    echo "SmartDNS 监听端口：6053"
    echo "客户端 DNS 设置：自动获取（53 端口）"
    echo ""
    echo "上游 DNS 服务器："
    echo "  - 云南联通：221.3.131.11, 221.3.131.12"
    echo "  - 阿里 DNS: 223.5.5.5, 223.6.6.6"
    echo "  - 腾讯 DNS: 119.29.29.29"
    echo "  - Google DNS: 8.8.8.8, 8.8.4.4"
    echo "  - Cloudflare: 1.1.1.1 (GitHub 加速)"
    echo "=========================================="
}

# 执行配置
configure_dns
