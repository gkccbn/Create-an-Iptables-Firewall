Firewall should be a stateful.

    Create 4 network namespaces.
    Namespaces are client1, client2, server, firewall
    Create veth for all namespaces and your host-to-firewall for network communication.
    Serve sample http service inside the server namespace
    Create iptables rules inside the firewall namespace and control traffic between the namespaces.
    Rules:
        Client1 can ping to server,
        Client2 can access to server for http,
        Client2 can ping to firewall,
        Client1 doesn't have ping permission to firewall,
        Client and server networks are can be access to the internet from firewall namespace via your host machine.

Notes

    Client1 subnetwork is 192.0.2.0/26
    Client2 subnetwork is 192.0.2.64/26
    Server subnetwork is 192.0.2.128/26
    Host-To-Firewall Subnetwork is 192.0.2.192/26
    Firewall should be a stateful.
    
