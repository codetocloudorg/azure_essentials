---
marp: true
theme: default
paginate: true
header: "Azure Essentials | Code to Cloud"
footer: "Day 1 — Foundations"
style: |
  section {
    font-size: 28px;
  }
  h1 {
    color: #0078D4;
  }
  h2 {
    color: #106EBE;
  }
  table {
    font-size: 22px;
  }
---

# Azure Essentials
## 2-Day Hands-On Training

**Code to Cloud**

![bg right:40% 80%](https://upload.wikimedia.org/wikipedia/commons/f/fa/Microsoft_Azure.svg)

---

# Day 1 Agenda

| Module | Topic | Duration |
|--------|-------|----------|
| 1 | Introduction to Azure | 55 min |
| 2 | Getting Started | 20 min |
| 3 | Storage Services | 55 min |
| 4 | Networking Services | 35 min |
| 5 | Compute — Windows | 30 min |
| 6 | Compute — Linux & Kubernetes | 25 min |
| 7 | Container Services | 25 min |

---

<!-- _class: lead -->

# Module 1
## Introduction to Azure Cloud

---

# What is Cloud Computing?

Computing services delivered over the internet:

- **Compute** — VMs, containers, serverless functions
- **Storage** — Files, databases, data lakes
- **Networking** — Virtual networks, load balancers, CDNs
- **Intelligence** — AI, machine learning, analytics

> 📚 [Azure Fundamentals Learning Path](https://learn.microsoft.com/training/paths/azure-fundamentals/)

---

# Azure Service Models

| Model | You Manage | Azure Manages | Example |
|-------|------------|---------------|---------|
| **IaaS** | OS, runtime, apps, data | Hardware, networking | Virtual Machines |
| **PaaS** | Apps and data | Everything else | App Service |
| **SaaS** | Data only | Everything else | Microsoft 365 |
| **Serverless** | Code only | Everything else | Azure Functions |

> 📚 [Cloud Concepts](https://learn.microsoft.com/training/modules/describe-cloud-compute/)

---

# Shared Responsibility Model

| Responsibility | On-Premises | IaaS | PaaS | SaaS |
|----------------|-------------|------|------|------|
| Data & Access | You | You | You | You |
| Applications | You | You | You | Microsoft |
| OS | You | You | Microsoft | Microsoft |
| Network Controls | You | You | Shared | Microsoft |
| Physical | You | Microsoft | Microsoft | Microsoft |

> 📚 [Shared Responsibility](https://learn.microsoft.com/azure/security/fundamentals/shared-responsibility)

---

# 🖐️ Hands-on: Azure Portal & CLI

**Exercise 1.1** — Explore the Azure Portal
- Navigate portal.azure.com
- Explore Home, All Services, Resource Groups
- Open Cloud Shell

**Exercise 1.2** — Azure CLI Basics
- Login, list subscriptions, set defaults

📂 **See:** `lessons/01-introduction/README.md`

---

# ✅ Module 1 Summary

- Cloud computing delivers services over the internet
- Four service models: IaaS, PaaS, SaaS, Serverless
- Shared responsibility model defines who manages what
- Azure Portal and CLI are your primary management tools

---

<!-- _class: lead -->

# Module 2
## Getting Started with Azure

---

# Azure Account Hierarchy

```
Microsoft Entra ID Tenant
└── Management Groups (optional)
    └── Subscriptions
        └── Resource Groups
            └── Resources
```

> 📚 [Azure Resource Manager](https://learn.microsoft.com/azure/azure-resource-manager/management/overview)

---

# Understanding Each Level

| Component | Purpose |
|-----------|---------|
| **Tenant** | Identity and access management |
| **Management Group** | Apply governance at scale |
| **Subscription** | Billing boundary and access control |
| **Resource Group** | Logical container for resources |
| **Resource** | The actual cloud service |

> 📚 [Organize Resources](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-setup-guide/organize-resources)

---

# Naming Conventions

| Resource Type | Prefix | Example |
|--------------|--------|---------|
| Resource Group | `rg-` | `rg-azure-essentials-dev` |
| Storage Account | `st` | `stazureessentials001` |
| Virtual Network | `vnet-` | `vnet-azure-essentials` |
| Virtual Machine | `vm-` | `vm-web-001` |
| App Service | `app-` | `app-api-prod` |
| Function App | `func-` | `func-processor` |

> 📚 [Naming Conventions](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)

---

# 🖐️ Hands-on: Resource Groups & CLI

**Exercise 2.1** — Create Resource Groups
- Create `rg-azure-essentials-dev`
- Apply tags for Environment and Course

**Exercise 2.2** — Configure CLI Defaults
- Set default resource group and location

📂 **See:** `lessons/02-getting-started/README.md`

---

# ✅ Module 2 Summary

- Azure uses a hierarchical structure (Tenant → Subscription → Resource Group)
- Resource groups are logical containers for related resources
- Consistent naming conventions make resources easy to manage
- CLI defaults reduce repetitive typing

---

<!-- _class: lead -->

# Module 3
## Storage Services

---

# Azure Storage Services

| Service | Description | Use Cases |
|---------|-------------|-----------|
| **Blob Storage** | Object storage | Images, documents, backups |
| **File Storage** | Managed file shares | Lift-and-shift, shared config |
| **Queue Storage** | Message queuing | Async processing |
| **Table Storage** | NoSQL key-value | Metadata storage |

> 📚 [Azure Storage Overview](https://learn.microsoft.com/azure/storage/common/storage-introduction)

---

# Storage Redundancy Options

| Option | Copies | Scope | Best For |
|--------|--------|-------|----------|
| **LRS** | 3 | Single datacenter | Dev/test |
| **ZRS** | 3 | Availability zones | Production, HA |
| **GRS** | 6 | Primary + secondary region | Disaster recovery |
| **GZRS** | 6 | Zones + secondary region | Mission-critical |

> 📚 [Storage Redundancy](https://learn.microsoft.com/azure/storage/common/storage-redundancy)

---

# Access Tiers

| Tier | Storage Cost | Access Cost | Minimum Days |
|------|--------------|-------------|--------------|
| **Hot** | Highest | Lowest | None |
| **Cool** | Medium | Medium | 30 days |
| **Cold** | Lower | Higher | 90 days |
| **Archive** | Lowest | Highest | 180 days |

> 📚 [Access Tiers](https://learn.microsoft.com/azure/storage/blobs/access-tiers-overview)

---

# 🖐️ Hands-on: Storage

**Exercise 3.1** — Create Storage Account
- Create account with Standard_LRS

**Exercise 3.2** — Work with Blobs
- Create container, upload files

**Exercise 3.3** — Queue Messages
- Create queue, send and peek messages

📂 **See:** `lessons/03-storage-services/README.md`

---

# ✅ Module 3 Summary

- Four core storage services: Blobs, Files, Queues, Tables
- Choose redundancy based on availability needs
- Access tiers optimize cost based on access frequency
- Storage accounts are the container for all storage services

---

<!-- _class: lead -->

# Module 4
## Networking Services

---

# Virtual Network Architecture

```
Virtual Network (10.0.0.0/16)
├── Subnet: Web Tier (10.0.1.0/24)
│   └── NSG: Allow HTTP/HTTPS
├── Subnet: App Tier (10.0.2.0/24)
│   └── NSG: Allow from Web Tier
└── Subnet: Data Tier (10.0.3.0/24)
    └── NSG: Allow from App Tier
```

> 📚 [Virtual Networks](https://learn.microsoft.com/azure/virtual-network/virtual-networks-overview)

---

# IP Address Planning

| CIDR Block | Available IPs | Use Case |
|------------|--------------|----------|
| /16 | 65,536 | Large VNet |
| /24 | 256 | Typical subnet |
| /27 | 32 | Small subnet |
| /28 | 16 | Very small subnet |

⚠️ Azure reserves **5 IP addresses** in each subnet

> 📚 [Plan VNets](https://learn.microsoft.com/azure/virtual-network/virtual-network-vnet-plan-design-arm)

---

# Network Security Groups (NSGs)

| Property | Description |
|----------|-------------|
| **Priority** | Lower = processed first (100-4096) |
| **Direction** | Inbound or Outbound |
| **Action** | Allow or Deny |
| **Protocol** | TCP, UDP, ICMP, or Any |
| **Source/Dest** | IP, CIDR, service tag, or ASG |

> 📚 [NSG Overview](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview)

---

# 🖐️ Hands-on: Networking

**Exercise 4.1** — Create Virtual Network
- Create VNet with 10.0.0.0/16 address space
- Add subnets for web, app, data tiers

**Exercise 4.2** — Create NSG Rules
- Create NSG, add HTTP/HTTPS rules

📂 **See:** `lessons/04-networking/README.md`

---

# ✅ Module 4 Summary

- VNets are isolated networks for your resources
- Plan IP address space carefully — avoid overlaps
- NSGs filter traffic with priority-based rules
- Use subnets to separate workload tiers

---

<!-- _class: lead -->

# Module 5
## Compute — Windows

---

# Virtual Machine Sizes

| Series | Purpose | Example |
|--------|---------|---------|
| **B** | Burstable, cost-effective | B1s, B2s |
| **D** | General purpose | D2s_v5, D4s_v5 |
| **E** | Memory optimized | E2s_v5, E4s_v5 |
| **F** | Compute optimized | F2s_v2, F4s_v2 |
| **N** | GPU enabled | NC6, NV6 |

> 📚 [VM Sizes](https://learn.microsoft.com/azure/virtual-machines/sizes-overview)

---

# Availability Options

| Option | Protection | SLA |
|--------|-----------|-----|
| **Single VM (Premium SSD)** | Hardware failure | 99.9% |
| **Availability Set** | Rack-level failure | 99.95% |
| **Availability Zone** | Datacenter failure | 99.99% |

> 📚 [Availability Options](https://learn.microsoft.com/azure/virtual-machines/availability)

---

# IaaS vs PaaS

| Aspect | VMs (IaaS) | App Service (PaaS) |
|--------|-----------|---------------------|
| **Control** | Full OS control | Application only |
| **Maintenance** | You patch | Microsoft manages |
| **Scaling** | Manual or VMSS | Built-in auto-scale |
| **Best for** | Lift-and-shift | Modern web apps |

> 📚 [App Service Overview](https://learn.microsoft.com/azure/app-service/overview)

---

# 🖐️ Hands-on: Windows Compute

**Exercise 5.1** — Deploy Windows VM
- Create VM, open RDP port, connect

**Exercise 5.2** — Deploy to App Service
- Deploy Cloud Quote API using `az webapp up`

📂 **See:** `lessons/05-compute-windows/README.md`

---

# ✅ Module 5 Summary

- Choose VM size based on workload requirements
- Availability zones provide highest SLA (99.99%)
- App Service is easier for web apps (no OS management)
- Use F1/B1 tiers for development and testing

---

<!-- _class: lead -->

# Module 6
## Compute — Linux & Kubernetes

---

# Supported Linux Distributions

| Distribution | Use Case |
|--------------|----------|
| **Ubuntu** | General purpose, development |
| **Red Hat Enterprise Linux** | Enterprise workloads |
| **Debian** | Servers, stability |
| **CentOS** | RHEL compatibility |
| **SUSE** | SAP workloads |

> 📚 [Linux on Azure](https://learn.microsoft.com/azure/virtual-machines/linux/overview)

---

# Kubernetes Fundamentals

| Concept | Description |
|---------|-------------|
| **Pod** | Smallest unit (1+ containers) |
| **Deployment** | Manages pod replicas & updates |
| **Service** | Exposes pods to network |
| **Namespace** | Logical isolation |
| **ConfigMap** | Configuration data |

> 📚 [Kubernetes Basics](https://learn.microsoft.com/azure/aks/concepts-clusters-workloads)

---

# Why MicroK8s for Learning?

✅ Single-node installation
✅ Low resource requirements
✅ Quick setup (minutes)
✅ Great for learning and development
✅ Snap-based installation

> 📚 [MicroK8s Documentation](https://microk8s.io/docs)

---

# 🖐️ Hands-on: Linux & Kubernetes

**Exercise 6.1** — Deploy Linux VM
- Create Ubuntu VM with SSH keys
- Connect via SSH

**Exercise 6.2** — Install MicroK8s
- Install MicroK8s, deploy nginx, scale pods

📂 **See:** `lessons/06-compute-linux-kubernetes/README.md`

---

# ✅ Module 6 Summary

- Azure supports all major Linux distributions
- SSH is the standard connection method
- Kubernetes orchestrates containerized workloads
- MicroK8s is perfect for learning Kubernetes basics

---

<!-- _class: lead -->

# Module 7
## Container Services

---

# Azure Container Registry (ACR)

| SKU | Features | Use Case |
|-----|----------|----------|
| **Basic** | Entry-level storage | Dev/test |
| **Standard** | More storage, webhooks | Small production |
| **Premium** | Geo-replication, private link | Enterprise |

> 📚 [ACR Overview](https://learn.microsoft.com/azure/container-registry/container-registry-intro)

---

# Azure Kubernetes Service (AKS)

| Component | Managed By |
|-----------|-----------|
| Control plane | Microsoft (free) |
| Worker nodes | You (pay for VMs) |
| Upgrades | Assisted by Azure |
| Scaling | Cluster autoscaler |

> 📚 [AKS Overview](https://learn.microsoft.com/azure/aks/intro-kubernetes)

---

# Container Workflow

```
┌───────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Dockerfile  │ →  │ docker build│ →  │ Push to ACR │ →  │ Deploy AKS  │
└───────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

Or use **ACR Tasks** — build in the cloud, no Docker needed locally!

---

# 🖐️ Hands-on: Containers

**Exercise 7.1** — Create ACR
- Create container registry (Basic SKU)

**Exercise 7.2** — Build with ACR Tasks
- Build Cloud Dashboard image in the cloud

📂 **See:** `lessons/07-container-services/README.md`

---

# ✅ Module 7 Summary

- ACR stores private container images
- ACR Tasks builds images without local Docker
- AKS is the managed Kubernetes service
- Control plane is free — you pay for worker node VMs

---

# 🎉 Day 1 Complete!

## Tomorrow: Day 2

- Module 8: Serverless Services
- Module 9: Database Services
- Module 10: Billing & Cost
- Module 11: Azure AI Foundry
- Module 12: Architecture Design

**Questions?**

---

# Resources

| Resource | Link |
|----------|------|
| Azure Fundamentals | [learn.microsoft.com/training/paths/azure-fundamentals](https://learn.microsoft.com/training/paths/azure-fundamentals/) |
| Azure CLI Docs | [learn.microsoft.com/cli/azure](https://learn.microsoft.com/cli/azure/) |
| Azure Architecture Center | [learn.microsoft.com/azure/architecture](https://learn.microsoft.com/azure/architecture/) |
| Course Repository | github.com/codetocloudorg/azure_essentials |
