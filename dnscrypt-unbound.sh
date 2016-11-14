#!/usr/bin/env bash
# Debian
# Ugly script, but hey! it works.

if [ "$(id -u)" != "0" ]; then
   echo "Harus dijalankan sebagai root" 1>&2
   exit 1
fi

if [[ ! -e /etc/debian_version ]]; then
echo "Hanya bisa dijalankan di Debian"
exit
fi

# Get IP Address
IPAdd=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

# depedency
apt-get install build-essential pkg-config libtool automake dnsutils -y

# libsodium
wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz
tar zxvf LATEST.tar.gz
cd libsodium*
./autogen.sh; ./configure; make; su -c "make install"
echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf; ldconfig

# dnscrypt
wget https://download.dnscrypt.org/dnscrypt-proxy/LATEST.tar.gz
tar zxvf LATEST.tar.gz
cd dnscrypt-proxy*
./autogen.sh; ./configure; make; su -c "make install"
echo "DNSCrypt selesai di install"

# unbound 
apt-get install unbound -y
echo 'server:
interface: 127.0.0.1
directory: "/etc/unbound"
hide-identity: yes
hide-version: yes
num-threads: 5
so-rcvbuf: 4m
so-sndbuf: 4m
cache-min-ttl: 3600
private-address: 10.0.0.0/8
private-address: 172.16.0.0/12
private-address: 192.168.0.0/16
private-address: 127.0.0.1/8
include: "/etc/unbound/unbound.conf.d/*.conf"
root-hints: "/etc/unbound/root.hints"
include: "/etc/unbound/iklan.conf"
log-queries: yes
logfile: "/var/log/unbound/unbound.log"
do-not-query-localhost: no
forward-zone:
  name: "."
  forward-addr: 127.0.0.1@40
remote-control:
    control-enable: no' > /etc/unbound/unbound.conf
    
# Autostart Unbound + DNSCrypt

# run dnscrypt on background
echo '#!/usr/bin/env bash
dnscrypt-proxy --local-address='$IPAdd':40 -R cisco' > /opt/dns.sh

# Executeable
chmod +x /opt/dns.sh

# systemd service
echo '[Unit]
After=unbound.service

[Service]
ExecStart=/opt/dns.sh

[Install]
WantedBy=default.target' > /etc/systemd/system/dnscrypt-start.service

systemctl daemon-reload
systemctl enable dnscrypt-start.service
systemctl enable unbound.service

echo "=== Test Query ==="
dig @"$IPAdd" -p 40 +noall +answer yahoo.com x.org paypal.com github.com kernel.org debian.org getfedora.org ubuntu.com
