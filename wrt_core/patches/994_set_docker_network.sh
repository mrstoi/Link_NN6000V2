#!/bin/bash
# Docker network configuration
# Add Docker bridge to LAN firewall zone

if [ -f /etc/config/firewall ]; then
    # Check if docker zone already exists
    if ! grep -q "config zone 'docker'" /etc/config/firewall; then
        # Add Docker firewall zone
        cat >> /etc/config/firewall << 'EOF'

config zone 'docker'
    option name 'docker'
    option input 'ACCEPT'
    option output 'ACCEPT'
    option forward 'ACCEPT'
    option masq '1'
    option mtu_fix '1'
    option network 'docker'
EOF
        echo "Docker firewall zone added"
    fi

    # Add docker0 bridge to LAN zone if not exists
    if ! grep -q "docker0" /etc/config/firewall; then
        # Add docker0 to LAN zone
        uci add firewall forwarding
        uci set firewall.@forwarding[-1].src='lan'
        uci set firewall.@forwarding[-1].dest='docker'
        uci commit firewall
        echo "Docker bridge forwarding added to LAN"
    fi
fi

# Configure Docker daemon to use bridge network
if [ -f /etc/docker/daemon.json ]; then
    if ! grep -q "bridge" /etc/docker/daemon.json; then
        # Backup and modify daemon.json
        cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
        cat /etc/docker/daemon.json.bak | sed 's/}$/,"bridge": "docker0"}/g' > /etc/docker/daemon.json
        echo "Docker daemon configured"
    fi
else
    # Create daemon.json if not exists
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json << 'EOF'
{
    "bridge": "docker0",
    "iptables": true,
    "ip6tables": false
}
EOF
    echo "Docker daemon.json created"
fi

# Restart firewall and docker
/etc/init.d/firewall restart 2>/dev/null
/etc/init.d/docker restart 2>/dev/null

echo "Docker network configuration completed"
