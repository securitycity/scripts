#!/bin/bash

echo "Creating your vpn server"
##check if vpn is installed

openvpnserver = dpkg -s openvpn | grep 'package' | awk '{$1= ""; print $0}'
##check for easy-rsa

easyrsa = /etc/openvpn/easy-rsa

installpackages(){
    apt update && apt upgrade
    if [openvpnserver == 1];then
        echo "Openvpn is Installed:"
    else
        echo "Installing Openvpn"
        apt install openvpn -y
    fi
    sleep 5
    if [-f "$easyrsa"];then
        echo "Easy Rsa is installed"

    else
        wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz
        tar -xvzf EasyRSA-3.0.8.tgz
        mv EasyRSA-3.0.8.tgz easy-rsa && cp -r easy-rsa -t /etc/openvpn && cd /etc/openvpn/easy-rsa
        
    fi
    sleep 5

}

##install needed packages
installpackages()

configservers(){
    echo "Configuring easy-rsa"
    cd /etc/openvpn/easy-rsa && mv vars.example vars
    tee -a  vars << EOF
         set_var EASYRSA                "$PWD" 
         set_var EASYRSA_PKI            "$EASYRSA/pki"
         set_var EASYRSA_DN              "cn_only"
         set_var EASYRSA_REQ_COUNTRY     "USA"
         set_var EASYRSA_REQ_PROVINCE    "Network"
         set_var EASYRSA_REQ_CITY        "Network"
         set_var EASYRSA_REQ_ORG         "CIPHERX CERTIFICATE AUTHORITY"
         set_var EASYRSA_REQ_EMAIL       "deetu4200@gmail.com"
         set_var EASYRSA_REQ_OU          "CIPHERX EASY CA"
         set_var EASYRSA_KEY_SIZE        2048
         set_var EASYRSA_ALGO            rsa
         set_var EASYRSA_CA_EXPIRE       7500
         set_var EASYRSA_CERT_EXPIRE     365
         set_var EASYRSA_NS_SUPPORT      "no"
         set_var EASYRSA_NS_COMMENT     "CIPHERX CERTIFICATE AUTHORITY"
         set_var EASYRSA_EXT_DIR         "$EASYRSA/x509-types"
         set_var EASYRSA_SSL_CONF        "$EASYRSA/openssl-easyrsa.cnf"
         set_var EASYRSA_DIGEST          "sha256"
EOF
    ##create server keys and sign
    ./easyrsa init-pki
    ./easyrsa build-ca nopass
    ./easyrsa gen-req vpnserver nopass
    ./easyrsa sign-req server vpnserver
    ./easyrsa gen-dh
    cp pki/ca.crt /etc/openvpn/server/
    cp pki/dh.pem /etc/openvpn/server/
    cp pki/private/vpnserver.key /etc/openvpn/server/
    cp pki/issued/vpnserver.crt /etc/openvpn/server/
    ##create client keys and sign
    ./easyrsa gen-req vpnclient nopass
    ./easyrsa sign-req client vpnclient
    cp pki/ca.crt /etc/openvpn/client/
    cp pki/issued/vpnclient.crt /etc/openvpn/client/
    cp pki/private/vpnclient.key /etc/openvpn/client/
}
##configure vpn servers
configservers() 

serversetup(){
    tee -a /etc/openvpn/server.conf << EOF
    port 1194
    proto udp
    dev tun
    ca /etc/openvpn/server/ca.crt
    cert /etc/openvpn/server/vpnserver.crt
    key /etc/openvpn/server/vpnserver.key
    dh /etc/openvpn/server/dh.pem
    server 10.8.0.0 255.255.255.0
    push "redirect-gateway def1"

    push "dhcp-option DNS 208.67.222.222"
    push "dhcp-option DNS 208.67.220.220"
    duplicate-cn
    cipher AES-256-CBC
    tls-version-min 1.2
    tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256
    auth SHA512
    auth-nocache
    keepalive 20 60
    persist-key
    persist-tun
    compress lz4
    daemon
    user nobody
    group nogroup
    log-append /var/log/openvpn.log
    verb 3
EOF
    systemctl start openvpn@server
    systemctl enable openvpn@server
    ip a show tun0
    echo "Installation complete"

}

##serversetup
serversetup()