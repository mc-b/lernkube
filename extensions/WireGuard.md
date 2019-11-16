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
    # Address = 192.168.10.10/24
    PrivateKey = <client1-private-key>
    
    [Peer]
    # Battery
    PublicKey = <server-public-key>
    Endpoint = xxx:51820
    
    AllowedIPs = 192.168.10.0/24
    
    # This is for if you're behind a NAT and
    # want the connection to be kept alive.
    PersistentKeepalive = 25

Und mittels folgenden Befehlen aktivieren:    

    sudo ip link add dev wg0 type wireguard
    sudo ip address add dev wg0 192.168.10.1/24
    sudo wg setconf wg0 /etc/wireguard/wg0.conf
    sudo ip link set up dev wg0
    
WireGuard als Service starten, vorher ist der Datei `/etc/wireguard/wg0.conf` die Adresse zu aktivieren

    systemctl enable wg-quick@wg0.service
    
Kontrollieren ob nach diesem Befehl das Interface verschwunden ist, ansonsten `sudo ip link delete dev wg0 type wireguard`  
    
    systemctl stop wg-quick@wg0.service
    
Wieder starten und mit `ifconfig` Kontrolieren ob ein IP-Adresse vergeben wurde.    
   
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

Dann folgen die gleichen Befehle wie beim Client mit geänderter IP.

Netze verknüpfen
----------------

    sysctl net.ipv4.ip_forward=1

Für Details siehe:

* [Netze knüpfen mit wireguard](https://www.commander1024.de/wordpress/2019/04/netze-knuepfen-mit-wireguard/)



   