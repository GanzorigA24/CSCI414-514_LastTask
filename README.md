# Multiplayer Game State Service
## CSCI 414/514 — Final Practical Project

**Group 05**

**Team Members:**
- Ganzorig Arvinbileg
- Zachariah Houck
- Shariquddin Mohammed

---

## 1. Project Overview

The Multiplayer Game State Service is a distributed application designed to simulate multiplayer game telemetry and manage player-state information across isolated Docker network segments.

The application uses the OpenDota API as a public source of match data. The system processes match information, generates player-state updates, sends them through a FastAPI service, and stores the information in Redis.

The project demonstrates network infrastructure, distributed application development, Software-Defined Networking (SDN), Network Function Virtualization (NFV), network security, observability, performance testing, and automated failure recovery.

### Technologies Used

- Docker and Docker Compose
- Python
- FastAPI
- Uvicorn
- Redis
- Open vSwitch
- OpenFlow 1.3
- nftables
- Linux networking
- OpenSSL
- tcpdump / Wireshark
- Python performance testing
- PowerShell automation

---

## 2. System Architecture

The integrated project uses four Docker network segments and six containers. The SDN controller manages network traffic, while the NFV virtual firewall filters traffic between the client, service, and data networks.

### Network Topology

| Network | Subnet | Purpose |
|---|---|---|
| Client Network | 192.168.144.0/24 | Connects the game client and SDN controller |
| Service Network | 192.168.145.0/24 | Connects the API server and network services |
| Data Network | 192.168.146.0/24 | Connects the Redis database |
| SDN-NFV Network | 192.168.147.0/24 | Connects the SDN controller and NFV firewall |

### Main Components

| Component | IP Address | Purpose |
|---|---|---|
| Central Router | 192.168.144.254, 192.168.145.254, 192.168.146.254 | Provides connectivity between network segments |
| Game Client | 192.168.144.10 | Generates game-state updates |
| SDN Controller | 192.168.144.252, 192.168.147.252 | Controls network traffic using Open vSwitch and OpenFlow |
| NFV Firewall | 192.168.147.253, 192.168.145.253, 192.168.146.253 | Filters forwarded traffic using nftables |
| API Server | 192.168.145.10 | Processes requests using FastAPI |
| Redis Database | 192.168.146.10 | Stores player-state information |

### Application Data Flow

1. The game client retrieves public match data from OpenDota.
2. The client generates player-state updates.
3. Traffic passes through the SDN controller.
4. The NFV firewall controls permitted traffic between the service and data networks.
5. The FastAPI server processes the requests.
6. Redis stores the player-state information.

The SDN controller uses OpenFlow policies to control network traffic. The NFV firewall uses nftables to filter forwarded packets and protect the service and data networks.

---

## 3. Prerequisites

Before deploying the project, install:

- Docker Desktop
- Docker Compose
- Windows PowerShell or a compatible terminal
- Git

Make sure Docker Desktop is running before executing the deployment commands.

---

## 4. Project Files

The main project files include:

| File or Directory | Description |
|---|---|
| `docker-compose.yml` | Defines containers and Docker networks |
| `main.py` | FastAPI application backend |
| `simulate.py` | OpenDota-based match simulation and state update script |
| `start_api.sh` | API server startup |
| `start_router.sh` | Router startup |
| `performance_test.py` | Measures API performance and request latency |
| `recovery.ps1` | PowerShell automation and API recovery script |
| `recovery.sh` | Shell recovery script |
| `NFV/` | NFV firewall implementation |
| `NFV/Dockerfile` | Builds the NFV firewall container |
| `NFV/firewall.sh` | Configures firewall startup and routing |
| `NFV/nftables.conf` | Contains NFV firewall rules |
| `NFV/Evidence/` | SDN and NFV testing screenshots |
| `SDN/` | SDN controller policies and configuration |
| `SDN/apply_policy.sh` | Applies OpenFlow policies |
| `SDN/remove_policy.sh` | Removes SDN policies |
| `SDN/show_policy.sh` | Displays SDN policies |
| `SDN/policy.json` | Defines SDN access policies |
| `Performance_Report.md` | Performance experiment results |
| `Recovery_Report.md` | Automation and recovery test results |
| `Test_evidence/` | Supporting test logs and packet captures |

---

## 5. Deploying the Environment

### Step 1: Open the Project Directory

Clone the repository:

```powershell
git clone https://github.com/GanzorigA24/CSCI414-514_LastTask.git
```

Open the project directory:

```powershell
cd CSCI414-514_LastTask
```

### Step 2: Prepare External Docker Networks

The Docker Compose configuration uses three existing external networks.

If these networks do not already exist, create them:

```powershell
docker network create --subnet 192.168.144.0/24 csci414-514_final_exam_group_05-main_client_net
docker network create --subnet 192.168.145.0/24 csci414-514_final_exam_group_05-main_service_net
docker network create --subnet 192.168.146.0/24 csci414-514_final_exam_group_05-main_data_net
```

The SDN-NFV network is created automatically by Docker Compose.

### Step 3: Start the Docker Environment

Run:

```powershell
docker compose up -d --build
```

### Step 4: Verify Container Status

Run:

```powershell
docker compose ps
```

The project contains six main containers:

- `central_router`
- `sdn_controller`
- `nfv_firewall`
- `game_client`
- `api_server`
- `nosql_db`

Make sure the containers are running before continuing.

### Step 5: Check Startup Logs

To inspect the SDN controller:

```powershell
docker compose logs --tail 30 sdn_controller
```

To inspect the NFV firewall:

```powershell
docker compose logs --tail 30 nfv_firewall
```

The SDN controller should report:

```text
SDN Controller Ready
```

---

## 6. Module A — Network Infrastructure and Topology

The project uses four Docker networks to separate the client, service, data, and SDN-NFV traffic.

IP forwarding and routing configurations allow permitted communication between network segments.

### Verify IP Forwarding

Check the router:

```powershell
docker compose exec router sysctl net.ipv4.ip_forward
```

Check the NFV firewall:

```powershell
docker compose exec nfv_firewall sysctl net.ipv4.ip_forward
```

Expected result:

```text
net.ipv4.ip_forward = 1
```

### Verify Client Routing

```powershell
docker compose exec game_client ip route
```

The default gateway should be:

```text
default via 192.168.144.252
```

### Verify SDN Interfaces

```powershell
docker compose exec sdn_controller ip -br addr
```

The SDN bridge should use:

```text
br0  192.168.144.252/24
```

The NFV-facing interface should use:

```text
eth1  192.168.147.252/24
```

### Verify Open vSwitch

```powershell
docker compose exec sdn_controller ovs-vsctl show
```

The output should display the Open vSwitch bridge `br0`.

---

## 7. Module B — Distributed Service and NoSQL Database

The application uses FastAPI as the API gateway and Redis as the NoSQL datastore.

### Verify API Health

The API server uses HTTPS on port 8000.

Run:

```powershell
docker compose exec game_client curl -k https://192.168.145.10:8000/health
```

Expected response:

```json
{"status":"healthy","database":"connected"}
```

### Run the Simulation

Run:

```powershell
docker compose exec game_client python3 /simulate.py
```

The simulation processes match data and sends player-state update events to the API.

### Verify Redis Storage

Run:

```powershell
docker compose exec nosql_db redis-cli DBSIZE
```

The expected database size after the complete simulation is:

```text
(integer) 1050
```

---

## 8. Module C — Network Security: SDN and NFV

This module focuses on controlling communication between the isolated network segments.

The project combines Software-Defined Networking (SDN) and Network Function Virtualization (NFV).

### SDN — Open vSwitch and OpenFlow

The SDN controller uses Open vSwitch with OpenFlow 1.3 policies.

The main policies are:

- Allow game client access to the API on TCP port 8000.
- Allow API-to-Redis traffic on TCP port 6379.
- Block direct game client access to Redis on TCP port 6379.

### Verify SDN Policies

Display the installed OpenFlow rules:

```powershell
docker compose exec sdn_controller ovs-ofctl -O OpenFlow13 dump-flows br0
```

The output should show the configured allow and drop rules.

### NFV — Virtual Firewall

The NFV firewall uses nftables to filter forwarded network traffic.

The firewall implements:

- Established and related connection handling.
- Game client-to-API access on TCP port 8000.
- API-to-Redis access on TCP port 6379.
- A default drop policy for forwarded traffic.

### Verify NFV Firewall Rules

Run:

```powershell
docker compose exec nfv_firewall nft list ruleset
```

The output should display the firewall table and its forwarding rules.

### Security Verification

The expected communication paths are:

| Source | Destination | Expected Access |
|---|---|---|
| Game Client | API Server | Allowed |
| API Server | Redis Database | Allowed |
| Game Client | Redis Database | Blocked |

Test client-to-API communication:

```powershell
docker compose exec game_client curl -k https://192.168.145.10:8000/health
```

Test direct client-to-Redis access:

```powershell
docker compose exec game_client python3 -c "import socket; s=socket.socket(); s.settimeout(5); result=s.connect_ex(('192.168.146.10',6379)); print('BLOCKED: Direct Redis access denied' if result != 0 else 'FAILED: Direct Redis access allowed'); s.close()"
```

Test API-to-Redis access:

```powershell
docker compose exec api_server python3 -c "import socket; s=socket.socket(); s.settimeout(5); result=s.connect_ex(('192.168.146.10',6379)); print('SUCCESS: API can reach Redis' if result == 0 else 'FAILED: API cannot reach Redis'); s.close()"
```

These tests verify that the game client cannot bypass the API to access Redis directly, while the API can still communicate with the database.

---

## 9. Module D — Observability

This module focuses on monitoring network traffic and application activity.

The project uses packet-capture and logging tools to observe communication between application components.

### Tools

- tcpdump
- Wireshark
- Uvicorn application logs
- Linux network utilities

### Observability Objectives

- Capture network traffic between application components.
- Inspect communication across network segments.
- Review API access logs.
- Observe application requests and responses.
- Support troubleshooting using packet captures and logs.

Relevant screenshots, logs, and packet captures are stored in the `Test_evidence/` and `NFV/Evidence/` directories.

---

## 10. Module E — Performance Experiments

Performance testing was performed using `performance_test.py`.

The script sends 1,050 sequential POST requests to the `/update_state` endpoint and measures request latency, execution time, throughput, and success rate.

### Baseline Test

The baseline test was performed under normal network conditions.

| Metric | Result |
|---|---:|
| Total Requests | 1,050 |
| Successful Requests | 1,050 |
| Failed Requests | 0 |
| Success Rate | 100% |
| Average Latency | 4.90 ms |
| Median Latency | 4.69 ms |
| P95 Latency | 6.04 ms |
| Total Execution Time | 5.15 seconds |
| Throughput | 203.75 requests/second |

### Network Impairment Test

Network impairment was applied to the game client's network interface using Linux `tc/netem`.

Configuration:

```bash
tc qdisc add dev eth0 root netem delay 100ms 10ms loss 1%
```

This configuration introduced:

- 100 ms network delay
- 10 ms jitter
- 1% packet loss

The same 1,050-request workload was executed again.

| Metric | Result |
|---|---:|
| Total Requests | 1,050 |
| Successful Requests | 1,050 |
| Failed Requests | 0 |
| Success Rate | 100% |
| Average Latency | 232.75 ms |
| Median Latency | 210.46 ms |
| P95 Latency | 224.87 ms |
| Total Execution Time | 244.40 seconds |
| Throughput | 4.30 requests/second |

### Results and Interpretation

The network impairment significantly increased request latency and execution time while reducing throughput.

All HTTP requests completed successfully because TCP retransmission handled packet loss.

The results demonstrate how network delay, jitter, and packet loss can affect application performance even when the service remains available.

After testing, the network impairment was removed:

```bash
docker exec game_client tc qdisc del dev eth0 root
```

---

## 11. Module F — Automation and Failure Recovery

This module demonstrates automated health checking, controlled failure simulation, and service recovery.

The project uses the PowerShell script `recovery.ps1`.

### Health Check

The script checks the API health endpoint:

```text
https://192.168.145.10:8000/health
```

If the API is healthy, the script reports that no recovery is needed.

### Controlled Failure

The Uvicorn API process can be intentionally stopped while keeping the Docker container running.

Command:

```bash
docker exec api_server pkill -x uvicorn
```

A health check from the game client should then return a connection error.

### Automated Recovery

Run the PowerShell recovery script from the project directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\recovery.ps1
```

The script performs these operations:

1. Checks API health.
2. Detects whether the API is unavailable.
3. Restarts the Uvicorn process.
4. Waits for the API to become available.
5. Performs another health check.
6. Reports whether recovery succeeded.

### Recovery Verification

The recovery test successfully restarted the API.

The final health response was:

```json
{"status":"healthy","database":"connected"}
```

The Uvicorn process was confirmed running after recovery.

This demonstrated that the API could recover from a process failure without restarting the entire Docker container.

---

## 12. Test Evidence

Screenshots and supporting evidence are stored in the following directories:

- `Test_evidence/`
- `NFV/Evidence/`

Important SDN and NFV evidence includes:

- `06_Integrated_NFV_Firewall_Rule.png`
- `07_SDN_OpenVSwitch_Bridge.png`
- `08_SDN_NFV_Allowed_API_Traffic.png`
- `09_SDN_NFV_Direct_Redis_Blocked.png`
- `10_SDN_NFV_API_Redis_Allowed.png`

The evidence documents:

- NFV firewall configuration.
- Open vSwitch bridge initialization.
- Allowed client-to-API communication.
- Blocked direct client-to-Redis communication.
- Allowed API-to-Redis communication.

Additional test evidence documents network connectivity, API functionality, performance measurements, packet captures, and automated recovery.

---

## 13. Conclusion

The Multiplayer Game State Service demonstrates a distributed application operating across isolated Docker network segments.

The project combines network routing, API development, Redis storage, Software-Defined Networking, Network Function Virtualization, network security, observability, performance testing, and automated recovery.

The SDN controller uses OpenFlow policies to control network traffic, while the NFV virtual firewall uses nftables to filter forwarded packets.

Testing confirmed that the game client could access the API, direct access from the game client to Redis was blocked, and the API could still communicate with Redis.

Performance experiments showed that network impairment significantly increased latency and reduced throughput. The recovery experiment demonstrated that the API could be restored automatically after a controlled process failure.

Overall, the project provided practical experience in building, integrating, testing, monitoring, and recovering a distributed application.

---

## 14. Repository

**GitHub Repository:**

https://github.com/GanzorigA24/CSCI414-514_LastTask
**Project:** CSCI 414/514 — Multiplayer Game State Service  
**Group:** 05  
**Semester:** Fall 2026
