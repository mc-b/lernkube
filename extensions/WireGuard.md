WireGuard
=========

Installation
------------

    add-apt-repository -y ppa:wireguard/wireguard
    apt-get update
    apt-get install -y wireguard

**Keys erstellen**

Server:

    wg genkey > server_private.key
    wg pubkey > server_public.key < server_private.key
    
und für jeden Client:
    
    wg genkey > client1_private.key
    wg pubkey > client1_public.key < client1_private.key

Client
------
     
Datei `/etc/wireguard/wg0.conf` mit folgendem Inhalt erstellen   
   
    [Interface]
    Address = 192.168.10.10/24
    PrivateKey = <client1-private-key>
    
    [Peer]
    # Battery
    PublicKey = <server-public-key>
    Endpoint = xxx:51820
    
    AllowedIPs = 192.168.10.0/24
    
    # This is for if you're behind a NAT and
    # want the connection to be kept alive.
    PersistentKeepalive = 25

WireGuard als Service starten. Dabei wir die Datei `/etc/wireguard/wg0.conf` ausgewertet 

    systemctl enable wg-quick@wg0.service
    systemctl start wg-quick@wg0.service
   
Server 
------

Datei `/etc/wireguard/wg0.conf` mit folgendem Inhalt erstellen 

    [Interface]
    # Address = 192.168.2.1
    ListenPort = 51820
    PrivateKey = <server-private-key>
    
    [Peer]
    # Client 1
    PublicKey = <client1-public-key>
    AllowedIPs = 192.168.2.10
    
    [Peer]
    # Client 2
    PublicKey = <client1-public-key>
    AllowedIPs = 192.168.2.11

Dann muss, wie beim Client, der Service aktiviert und gestartet werden.

**Netze verknüpfen**

Folgenden Eintrag in `/etc/sysctl.conf` auskommentieren, bzw. aktivieren

    sysctl net.ipv4.ip_forward=1
    
Server frisch starten es sollte neu ein Interface `wg0` vorhanden sein.

    sudo ifconfig
    sudo wg    

### Links

* [What is and how do I enable IP forwarding on Linux?](https://openvpn.net/faq/what-is-and-how-do-i-enable-ip-forwarding-on-linux/)
* [Netze knüpfen mit wireguard](https://www.commander1024.de/wordpress/2019/04/netze-knuepfen-mit-wireguard/)
* [How to View the Network Routing Table in Ubuntu](https://vitux.com/how-to-view-the-network-routing-table-in-ubuntu/)
* [Forward a TCP port to another IP or port using NAT with Iptables](http://jensd.be/343/linux/forward-a-tcp-port-to-another-ip-or-port-using-nat-with-iptables)
* [IPTables Home](https://netfilter.org/)
   