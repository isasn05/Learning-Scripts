#!/bin/bash
#Isabella Sanglade Fall 2025 - Horse Plinko

#backups!
tar -czvf /root/Isaback.tar.gz /etc /var /home /usr/bin/dnf /etc/ssh /etc/httpd /usr/lib/systemd/system/httpd.service
scp /root/Isaback.tar.gz plinktern@172.16.t.05:/home/plinktern/

#Root Being blocked to log in and users
passwd -l root
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "Protocol 2" >> /etc/ssh/sshd_config
#SSH whitelist
echo "AllowUsers jmoney plinktern" >> /etc/ssh/sshd_config
#Remove nopasswdlogin group (used for passwordless logins)
echo "Removing nopasswdlogin group"
sudo sed -i -e '/nopasswdlogin/d' /etc/group
#Secure /etc/passwd permissions
sudo chmod 644 /etc/passwd
systemctl restart sshd

#Firewall! 
#AlmaLinux is more compatible with firewalld
dnf install firewalld -y
systemctl enable --now firewalld
#SSH and HTTP
firewall-cmd --zone=public --add-service=ssh --permanent
firewall-cmd --zone=public --add-service=http --permanent
#Block Metasploit
firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" port port="4444" protocol="tcp" reject' --permanent
# Reload to apply changes
firewall-cmd --reload

#Users
echo -e "jmoney:noUbuntu\nplinktern:noUbuntu" | chpasswd
echo "Passwords updated for jmoney and plinktern"

echo "🧹 Removing all users except plinktern, jmoney, and nobody..."

for user in $(cut -d: -f1 /etc/passwd); do
  uid=$(id -u "$user" 2>/dev/null)
  if [[ "$uid" -ge 1000 && "$user" != "nobody" && "$user" != "jmoney" && "$user" != "plinktern" ]]; then
    echo "❌ Deleting user: $user"
    sudo userdel -r "$user" &>/dev/null
  fi
done

echo "✅ User cleanup complete."


#jmoney unpriviledged 
# Make jmoney unprivileged
echo "🔧 Stripping privileges from jmoney..."

# Remove jmoney from wheel and other groups
sudo gpasswd -d jmoney wheel &>/dev/null
sudo usermod -G "" jmoney

# Ensure jmoney has no sudo access
sudo sed -i '/^jmoney/d' /etc/sudoers
sudo rm -f /etc/sudoers.d/jmoney

echo "✅ jmoney is now unprivileged."

#Downloads 
sudo dnf update -y

#Install useful tools
sudo dnf install htop -y
sudo dnf install ranger -y
sudo dnf install tmux -y
sudo dnf install curl -y
sudo dnf install whowatch -y
sudo dnf install fail2ban -y
# Download and make executable
curl -L -o pspy64 https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64
chmod +x pspy64
sudo mv pspy64 /usr/local/bin/

#Lock In
chattr +i /etc/ssh/sshd_config
chattr +i /etc/passwd
chattr +i /etc/shadow



