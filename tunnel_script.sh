#!/bin/bash

print_text() {
    text="$1"
    delay="$2"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo
}

get_current_ip() {
    curl -s ipv4.icanhazip.com
}

clear
echo ""
print_text "Automatic Tunnel Setup - By Ramin" 0.05
echo ""
echo ""

# Get Server IPs
echo -e "\nPlease enter Iran server IP:"
read iran_ip

echo -e "\nPlease enter Foreign server IP:"
read foreign_ip

# Main Menu
while true; do
    clear
    echo ""
    print_text "=== Tunnel Setup Menu ===" 0.05
    echo ""
    echo "1) Setup Iran Server"
    echo "2) Setup Foreign Server"
    echo "3) Ping Iran Server (10.10.187.1)"
    echo "4) Ping Foreign Server (10.10.187.2)"
    echo "5) Reboot Server"
    echo "6) Exit"
    echo ""
    read -p "Please select an option: " choice

    case $choice in
        1)
            # Setup Iran Server
            cat > /etc/rc.local << EOF
#! /bin/bash
ip tunnel add 6to4_iran mode sit remote $foreign_ip local $iran_ip
ip -6 addr add 2002:a00:100::1/64 dev 6to4_iran
ip link set 6to4_iran mtu 1480
ip link set 6to4_iran up
ip -6 tunnel add GRE6Tun_iran mode ip6gre remote 2002:a00:100::2 local 2002:a00:100::1
ip addr add 10.10.187.1/30 dev GRE6Tun_iran
ip link set GRE6Tun_iran mtu 1436
ip link set GRE6Tun_iran up
sysctl net.ipv4.ip_forward=1
iptables -t nat -A PREROUTING -p tcp --dport 22 -j DNAT --to-destination 10.10.187.1
iptables -t nat -A PREROUTING -j DNAT --to-destination 10.10.187.2
iptables -t nat -A POSTROUTING -j MASQUERADE
exit 0
EOF
            chmod +x /etc/rc.local
            echo "Iran server settings applied successfully."
            read -p "Press Enter to continue..."
            ;;
        2)
            # Setup Foreign Server
            cat > /etc/rc.local << EOF
#! /bin/bash
ip tunnel add 6to4_Forign mode sit remote $iran_ip local $foreign_ip
ip -6 addr add 2002:a00:100::2/64 dev 6to4_Forign
ip link set 6to4_Forign mtu 1480
ip link set 6to4_Forign up
ip -6 tunnel add GRE6Tun_Forign mode ip6gre remote 2002:a00:100::1 local 2002:a00:100::2
ip addr add 10.10.187.2/30 dev GRE6Tun_Forign
ip link set GRE6Tun_Forign mtu 1436
ip link set GRE6Tun_Forign up
exit 0
EOF
            chmod +x /etc/rc.local
            echo "Foreign server settings applied successfully."
            read -p "Press Enter to continue..."
            ;;
        3)
            # Ping Iran Server
            ping -c 4 10.10.187.1
            read -p "Press Enter to continue..."
            ;;
        4)
            # Ping Foreign Server
            ping -c 4 10.10.187.2
            read -p "Press Enter to continue..."
            ;;
        5)
            # Reboot Server
            echo "Rebooting server..."
            reboot
            ;;
        6)
            echo "Exiting program..."
            exit 0
            ;;
        *)
            echo "Invalid option!"
            read -p "Press Enter to continue..."
            ;;
    esac
done
