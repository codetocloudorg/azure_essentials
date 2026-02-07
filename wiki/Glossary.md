# 📖 Azure Glossary

> A beginner-friendly dictionary of Azure and cloud terms

---

## A

### ACR (Azure Container Registry)
A private library for storing container images. Like Docker Hub, but just for you.
```
Your container images → ACR → Deploy to AKS, Container Apps, etc.
```

### ARM (Azure Resource Manager)
The "brain" of Azure that handles all resource creation and management. Every action goes through ARM.

### Availability Zone
A physically separate datacenter within a region. If one zone fails, others keep running.
```
Region (East US) contains:
├── Zone 1 (Datacenter A)
├── Zone 2 (Datacenter B)  
└── Zone 3 (Datacenter C)
```

### Azure CLI (az)
The command-line tool for managing Azure. You type commands instead of clicking buttons.
```bash
az vm create --name myVM ...
```

---

## B

### Bicep
Azure's language for Infrastructure as Code. Like writing a recipe for cloud resources.
```bicep
resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'mystorageaccount'
  location: 'eastus'
}
```

### Blob
**B**inary **L**arge **Ob**ject. Any file stored in Azure Storage (images, videos, documents, etc.).

---

## C

### CLI (Command Line Interface)
A way to control computers by typing text commands instead of clicking.

### Cloud-Init
A script that runs automatically when a Linux VM first starts. Used to install software.

### Container
A lightweight package containing an app and everything it needs to run. Starts in seconds.

### Container Apps
Azure's serverless container hosting. Runs containers without managing servers.

---

## D

### Deallocate
Fully stop a VM and release its compute resources. This stops billing (except disk storage).

### Deployment
The process of creating or updating resources in Azure.

---

## F

### FQDN (Fully Qualified Domain Name)
The complete address to reach a resource, like `myapp.azurewebsites.net`.

### Free Tier
Services that are free forever (within limits), like 5 GB of Blob storage.

---

## I

### IaaS (Infrastructure as a Service)
You rent virtual machines and manage everything on them yourself.
```
Azure provides: Hardware, Virtualization
You manage: OS, Runtime, Apps, Data
```

### IAM (Identity and Access Management)
Controlling who can do what in Azure. Also called "RBAC" in Azure.

### Ingress
Network traffic coming INTO your application from the internet.

---

## K

### kubectl
The command-line tool for managing Kubernetes clusters. Pronounced "cube-control" or "cube-C-T-L".
```bash
kubectl get pods
```

---

## L

### LRS (Locally Redundant Storage)
Data is copied 3 times within a single datacenter. Cheapest option.

---

## M

### Managed Identity
An automatic, secure way for Azure services to authenticate with each other. No passwords to manage!

---

## N

### NIC (Network Interface Card)
The virtual "network port" that connects a VM to a virtual network.

### NSG (Network Security Group)
A firewall for Azure resources. Controls what traffic is allowed in/out.
```
Allow: RDP (3389) from my IP
Deny: Everything else
```

---

## P

### PaaS (Platform as a Service)
Azure manages the infrastructure; you just deploy your code.
```
Azure provides: Hardware, OS, Runtime
You manage: Apps, Data
```
Examples: App Service, Azure Functions, Container Apps

### Portal
The web interface at portal.azure.com where you can click to manage Azure.

### Private IP
An IP address only accessible within a virtual network (like 10.0.0.4).

### Public IP
An IP address accessible from the internet (like 52.186.123.45).

---

## R

### RBAC (Role-Based Access Control)
Permission system: assign roles like "Reader" or "Contributor" to users/groups.

### RDP (Remote Desktop Protocol)
How you connect to Windows VMs remotely. Uses port 3389.

### Region
A geographic location with one or more Azure datacenters. Examples: eastus, westeurope.

### Resource
Anything you create in Azure: a VM, storage account, database, etc.

### Resource Group
A container (folder) that holds related resources. Makes management and deletion easy.
```
Resource Group: "my-web-app"
├── Web App
├── Database
└── Storage Account
```

### Resource Provider
A service that provides resource types. Example: `Microsoft.Compute` provides VMs.

---

## S

### SaaS (Software as a Service)
Fully managed software you just use. Example: Microsoft 365, Salesforce.

### SKU (Stock Keeping Unit)
The size/tier of a service. Example: `Standard_B2s` for a VM, `Basic` for a registry.

### SSH (Secure Shell)
How you connect to Linux VMs remotely. Uses port 22.
```bash
ssh username@ip-address
```

### Subscription
Your Azure billing account. All costs are charged to a subscription.

---

## T

### Tag
A label (key-value pair) you add to resources for organization.
```
environment: production
owner: team-a
project: web-app
```

### Tenant
Your organization in Azure Active Directory. Like your company's "Azure account".

---

## V

### Virtual Machine (VM)
A computer running in Azure's datacenter that you access remotely.

### Virtual Network (VNet)
A private network in Azure where your resources communicate securely.
```
VNet: 10.0.0.0/16
├── Subnet A: 10.0.1.0/24 (for VMs)
└── Subnet B: 10.0.2.0/24 (for databases)
```

---

## Z

### Zone Redundancy
Spreading resources across multiple availability zones for higher availability.

---

## Common Prefixes

When naming Azure resources, you'll see these prefixes:

| Prefix | Resource Type |
|--------|--------------|
| `rg-` | Resource Group |
| `vm-` | Virtual Machine |
| `st` | Storage Account |
| `vnet-` | Virtual Network |
| `nsg-` | Network Security Group |
| `pip-` | Public IP |

---

*Don't see a term? Ask in our [Discord](https://discord.gg/vwfwq2EpXJ)!*
