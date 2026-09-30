echo "===== IDENTITY ====="
hostnamectl
whoami
id

echo
echo "===== OPERATING SYSTEM ====="
cat /etc/os-release
uname -a

echo
echo "===== CPU ====="
lscpu | grep -E 'Model name|Socket|Core|Thread|CPU\(s\)'

echo
echo "===== MEMORY ====="
free -h

echo
echo "===== STORAGE ====="
lsblk -o NAME,SIZE,FSTYPE,FSVER,MOUNTPOINTS,MODEL
df -hT

echo
echo "===== NETWORK ====="
ip -br address
ip route
resolvectl status

echo
echo "===== LISTENING PORTS ====="
sudo ss -lntup

echo
echo "===== SSH ====="
systemctl status ssh --no-pager
sudo sshd -T | grep -E \
'^(port|permitrootlogin|passwordauthentication|pubkeyauthentication|allowusers|maxauthtries|x11forwarding) '

echo
echo "===== FIREWALL ====="
sudo ufw status verbose 2>/dev/null || true
sudo nft list ruleset 2>/dev/null || true

echo
echo "===== UPDATES ====="
apt list --upgradable 2>/dev/null

echo
echo "===== FAILED SERVICES ====="
systemctl --failed --no-pager

echo
echo "===== TIME ====="
timedatectl