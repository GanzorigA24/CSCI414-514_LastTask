# Network Function Virtualization (NFV)
## CSCI 414/514 – Final Group Project

**Component:** Virtual Firewall  
**Technology:** Docker and nftables

### 1. Introduction

The purpose of this NFV component is to implement a virtual firewall to control communication between the Game Client, API Server, and Redis database.

The firewall uses nftables to allow authorized network traffic and block unauthorized direct access to the database.

### 2. Implementation

A separate Docker container named `nfv-firewall` was created to run the virtual firewall.

The firewall was built using Ubuntu 24.04 and includes:
- nftables
- iproute2
- iputils-ping
- tcpdump
- curl
- procps

The firewall connects to all three project networks:

| Network | Firewall IP |
|---|---|
| Client Network | 192.168.144.253 |
| Service Network | 192.168.145.253 |
| Data Network | 192.168.146.253 |

### 3. Firewall Rules

The nftables configuration implements these traffic policies:

| Source | Destination | Port | Action |
|---|---|---|---|
| Game Client | API Server | TCP 8000 | Allow |
| API Server | Redis | TCP 6379 | Allow |
| Game Client | Redis Network | All | Drop |
| Established connections | Authorized connections | — | Allow |

The firewall uses a default DROP policy for forwarded traffic.

### 4. Testing and Results

The following tests were performed:

**Test 1: Game Client to API Server**

The Game Client accessed the API health endpoint:

`http://192.168.145.10:8000/health`

Result: PASS. The API returned HTTP 200 OK.

**Test 2: API Server to Redis**

The API health endpoint successfully checked the Redis database connection.

Result: PASS. The response confirmed that the database was connected.

**Test 3: Direct Game Client to Redis**

A Python socket connection test attempted to connect directly to Redis at `192.168.146.10:6379`.

Result: PASS. The connection was blocked by the firewall.

**Test 4: Firewall Packet Counters**

The nftables counters confirmed that traffic was accepted or dropped according to the configured rules.

Observed results:
- Established connections: 21 packets accepted.
- Game Client to API Server: 2 packets accepted.
- API Server to Redis: 1 packet accepted.
- Game Client to Redis: 3 packets dropped.

### 5. Conclusion

The NFV component successfully implemented a Docker-based virtual firewall using nftables.

Testing confirmed that authorized communication between the Game Client, API Server, and Redis database worked correctly, while direct access from the Game Client to Redis was blocked.

The component is ready for integration testing with the group's SDN implementation. The routing configuration used during individual testing will need to be coordinated with the final integrated network.

### 6. Evidence

The following screenshots document the NFV implementation and testing:

1. `01_NFV_Docker_Image_Built.png` – Successful Docker image build.
2. `02_NFV_Firewall_Rules_Loaded.png` – Firewall rules loaded successfully.
3. `03_NFV_Network_Interfaces_and_Forwarding.png` – Firewall network interfaces and IP forwarding.
4. `04_NFV_Allowed_API_Traffic.png` – Successful Game Client to API Server communication.
5. `05_NFV_Final_Firewall_Counters.png` – Final firewall counters showing accepted and dropped traffic.