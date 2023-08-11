sudo ip -all netns delete

sudo ip netns add client1 
sudo ip netns add client2 
sudo ip netns add server
sudo ip netns add firewall


sudo ip netns exec client1 ip link set dev lo up
sudo ip netns exec client2 ip link set dev lo up
sudo ip netns exec server ip link set dev lo up
sudo ip netns exec firewall ip link set dev lo up


sudo ip link add dev c1_f type veth peer name f_c1
sudo ip link add dev c2_f type veth peer name f_c2
sudo ip link add dev f_s type veth peer name s_f
#host firewall
sudo ip link add dev h_f type veth peer name f_h


sudo ip link set c1_f netns client1
sudo ip link set f_c1 netns firewall
sudo ip link set c2_f netns client2
sudo ip link set f_c2 netns firewall
sudo ip link set f_s netns firewall
sudo ip link set s_f netns server
#host firewall
sudo ip link set f_h netns firewall
#sudo ip link set h_f netns firewall

sudo ip netns exec client2 ip addr add 192.0.2.66/26 dev c2_f
sudo ip netns exec client2 ip link set c2_f up
sudo ip netns exec firewall ip addr add 192.0.2.67/26 dev f_c2
sudo ip netns exec firewall ip link set f_c2 up
sudo ip netns exec client1 ip addr add 192.0.2.3/26 dev c1_f
sudo ip netns exec client1 ip link set c1_f up
sudo ip netns exec firewall ip addr add 192.0.2.4/26 dev f_c1
sudo ip netns exec firewall ip link set f_c1 up
sudo ip netns exec firewall ip addr add 192.0.2.131/26 dev f_s
sudo ip netns exec firewall ip link set f_s up
sudo ip netns exec server ip addr add 192.0.2.130/26 dev s_f
sudo ip netns exec server ip link set s_f up
#host firewall
sudo ip netns exec firewall ip addr add 10.0.2.194/26 dev f_h
sudo ip netns exec firewall ip link set f_h up
sudo ip addr add 10.0.2.195/26 dev h_f
sudo ip link set h_f up

#route
sudo ip netns exec client1 ip route add default via 192.0.2.4 dev c1_f
sudo ip netns exec client2 ip route add default via 192.0.2.67 dev c2_f
sudo ip netns exec server ip route add default via 192.0.2.131 dev s_f
#new

sudo ip netns exec firewall ip route add 192.0.2.64/26 via 192.0.2.4 dev f_c1
sudo ip netns exec firewall ip route add 192.0.2.0/26 via 192.0.2.67 dev f_c2
sudo ip netns exec firewall ip route add 192.0.2.128/26 via 192.0.2.131 dev f_s
#host server c1 c2 route
sudo ip route add 192.0.2.0/26 via 10.0.2.194 dev h_f 
sudo ip route add 192.0.2.128/26 via 10.0.2.194 dev h_f 
sudo ip route add 192.0.2.64/26 via 10.0.2.194 dev h_f 

#host firewall route
sudo ip netns exec firewall ip route add default via 10.0.2.195 dev f_h

sudo ip netns exec firewall sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv4.ip_forward=1  
sudo iptables -F


sudo ip netns exec firewall iptables -F

sudo ip netns exec firewall iptables --policy INPUT DROP
sudo ip netns exec firewall iptables --policy FORWARD DROP
sudo ip netns exec firewall iptables --policy OUTPUT DROP


sudo ip netns exec firewall iptables -A INPUT -s 192.0.2.3 -j DROP
sudo ip netns exec firewall iptables -A INPUT -s 192.0.2.66 -j ACCEPT


sudo ip netns exec firewall iptables -A FORWARD -s 192.0.2.3 -o f_h -j ACCEPT
sudo ip netns exec firewall iptables -A FORWARD -s 192.0.2.130 -o f_h -j ACCEPT
sudo ip netns exec firewall iptables -A FORWARD -s 192.0.2.194 -o f_h -j ACCEPT
 
sudo ip netns exec firewall iptables -A FORWARD -d 192.0.2.3 -i f_h -j ACCEPT
sudo ip netns exec firewall iptables -A FORWARD -d 192.0.2.130 -i f_h -j ACCEPT
sudo ip netns exec firewall iptables -A FORWARD -d 192.0.2.194 -i f_h -j ACCEPT

#server to client1 ping
sudo ip netns exec firewall iptables -A FORWARD -s 192.0.2.3 -d 192.0.2.130 -p icmp -j ACCEPT
sudo ip netns exec firewall iptables -A FORWARD -s 192.0.2.130 -d 192.0.2.3 -p icmp -j ACCEPT

#sudo ip netns exec firewall iptables -A FORWARD -s 192.0.2.3 -d 192.0.2.130 -p icmp --icmp-type echo-reply -j ACCEPT
#sudo ip netns exec firewall iptables -A FORWARD -s 192.0.2.130 -d 192.0.2.3 -p icmp --icmp-type echo-reply -j ACCEPT


sudo ip netns exec firewall iptables -A FORWARD -s 192.0.2.3 -o f_h -p icmp --icmp-type echo-request -j ACCEPT 
sudo ip netns exec firewall iptables -A FORWARD -s 192.0.2.130 -o f_h -p icmp --icmp-type echo-request -j ACCEPT 
sudo ip netns exec firewall iptables -A FORWARD -s 192.0.2.66 -o f_h -p icmp --icmp-type echo-request -j ACCEPT 
 
sudo iptables -A FORWARD -o eno1 -i h_f -j ACCEPT
sudo iptables -A FORWARD -i eno1 -o h_f -j ACCEPT

sudo iptables -t nat -F
sudo iptables -t nat -A POSTROUTING -s 10.0.2.194/26 -o eno1 -j MASQUERADE
sudo ip netns exec firewall iptables -t nat -A POSTROUTING -o f_h -j MASQUERADE

sudo ip netns exec server python3 -m http.server 80  




