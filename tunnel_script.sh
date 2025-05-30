#!/bin/bash 
 
 echo "=========== Tunnel Configuration ===========" 
 echo "1. Iran Side" 
 echo "2. Foreign Side" 
 read -p "Choose which side you are configuring (1/2): " SIDE 
 
 read -p "Enter Foreign Server Public IP: " FOR_IP 
 read -p "Enter Iran Server Public IP: " IRN_IP 
 read -p "Enter desired SSH port to forward (only on Iran side): " SSH_PORT 
 
 # Extract IPv4 first byte for 6to4 (2002:xxxx::) conversion 
 FIRST_OCTET=$(echo "$FOR_IP" | cut -d '.' -f 1) 
 SECOND_OCTET=$(echo "$FOR_IP" | cut -d '.' -f 2) 
 TUN_HEX=$(printf "%02x%02x" $FIRST_OCTET $SECOND_OCTET) 
 
 TUN_PREFIX="2002:a00:100"  # Custom 6to4 subnet 
 LOCAL6_IRAN="2002:a00:100::1" 
 LOCAL6_FORIGN="2002:a00:100::2" 
 
 if [ "$SIDE" = "1" ]; then 
     echo "Configuring Iran Side..." 
 
     cat <<EOF | sudo tee /etc/rc.local > /dev/null 
 #! /bin/bash 
 ip tunnel add 6to4_iran mode sit remote $FOR_IP local $IRN_IP 
 ip -6 addr add $LOCAL6_IRAN/64 dev 6to4_iran 
 ip link set 6to4_iran mtu 1480 
 ip link set 6to4_iran up 
 
 ip -6 tunnel add GRE6Tun_iran mode ip6gre remote $LOCAL6_FORIGN local $LOCAL6_IRAN 
 ip addr add 10.10.187.1/30 dev GRE6Tun_iran 
 ip link set GRE6Tun_iran mtu 1436 
 ip link set GRE6Tun_iran up 
 
 sysctl net.ipv4.ip_forward=1 
 
 iptables -t nat -A PREROUTING -p tcp --dport $SSH_PORT -j DNAT --to-destination 10.10.187.2 
 iptables -t nat -A POSTROUTING -j MASQUERADE 
 
 exit 0 
 EOF 
 
 elif [ "$SIDE" = "2" ]; then 
     echo "Configuring Foreign Side..." 
 
     cat <<EOF | sudo tee /etc/rc.local > /dev/null 
 #! /bin/bash 
 ip tunnel add 6to4_Forign mode sit remote $IRN_IP local $FOR_IP 
 ip -6 addr add $LOCAL6_FORIGN/64 dev 6to4_Forign 
 ip link set 6to4_Forign mtu 1480 
 ip link set 6to4_Forign up 
 
 ip -6 tunnel add GRE6Tun_Forign mode ip6gre remote $LOCAL6_IRAN local $LOCAL6_FORIGN 
 ip addr add 10.10.187.2/30 dev GRE6Tun_Forign 
 ip link set GRE6Tun_Forign mtu 1436 
 ip link set GRE6Tun_Forign up 
 
 exit 0 
 EOF 
 
 else 
     echo "Invalid choice. Please select 1 or 2." 
     exit 1 
 fi 
 
 sudo chmod +x /etc/rc.local 
 echo "✅ Configuration complete. Please reboot or run /etc/rc.local manually."