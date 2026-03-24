# Azure Essentials — Speaker Notes & Script

> Code to Cloud | 2-Day Hands-On Training
> Use these notes alongside each slide deck / module.

---

## DAY 1 — FOUNDATIONS

---

### Setting the Scene (49 minutes)

**POLL: Cloud Experience Level**

- Open with a live poll before any slides: "How much cloud experience do you have?"
  - Options: None / Some awareness / Used it a few times / Use it daily / I architect in the cloud
- Use this to gauge the room. If mostly beginners, slow down on jargon. If experienced, lean into demos.
- "Great — this tells me where to focus. We'll make sure everyone leaves with hands-on experience regardless of starting point."

**Opening & Housekeeping (2 min)**

- "Welcome to Azure Essentials. Over the next two days we go from zero to deploying real workloads on Azure."
- Introduce yourself, housekeeping (breaks every ~50 min, questions welcome anytime, chat for async).
- "By end of day 2 you'll have deployed VMs, containers, serverless functions, databases, and even an AI chatbot."

**Presentation: Introduction to Azure Cloud (~15 min)**

- Start with _why cloud_ — on-demand resources, pay-as-you-go, global scale.
- Azure global infrastructure: 60+ regions, availability zones, edge locations.
- Show the Azure global infrastructure map (https://datacenters.microsoft.com).
- Key point: "Azure has more regions than any other cloud provider."
- Brief history: Azure launched 2010, now 200+ services, used by 95% of Fortune 500.

**Demo/Hands-On: Azure Portal and CLI Basics (~10 min)**

- Open the Azure Portal — walk through the dashboard, search bar, resource groups, Cloud Shell.
- Switch to terminal: `az login`, `az account show`, `az group list`.
- "Everything you can do in the portal, you can do in the CLI — and script it."
- Let attendees follow along: log in, run `az account show`.

**Presentation: Azure Service Model Pillars — IaaS / PaaS / SaaS / Serverless (~12 min)**

- Walk through the four service models — emphasize the "pizza analogy":
  - **IaaS** — You manage OS and up. Example: Azure VMs.
  - **PaaS** — You manage code and data. Example: App Service, Azure SQL.
  - **SaaS** — You manage nothing. Example: Microsoft 365, Dynamics.
  - **Serverless** — Event-driven, no server management. Example: Azure Functions, Logic Apps.
- Key visual: the shared responsibility model — "the higher you go, the less you manage."

**Demo/Hands-On: Identify Services by Model (~5 min)**

- Interactive exercise: show a list of Azure services, ask the audience to classify each as IaaS/PaaS/SaaS/Serverless.
- Examples: Azure VM (IaaS), App Service (PaaS), Microsoft 365 (SaaS), Azure Functions (Serverless).
- "If you're ever unsure, ask: who manages the OS? If it's you, it's IaaS."

**Q&A (~5 min)**

- Common questions: free tier limits, Azure vs AWS naming, how billing works.

---

### Break (5 minutes)

**POLL: Which Cloud Provider do you currently use the most?**

- Run during the break so results are ready when you resume.
- Options: Azure / AWS / GCP / Other / None — I'm new to cloud
- When resuming: "Interesting — looks like we have [X]. Good news: the concepts we cover today apply everywhere, but the demos are all Azure."

---

### Getting Started with Azure (22 minutes)

**Presentation: Accounts, Subscriptions, Tenants, Resource Groups (~12 min)**

- Explain the hierarchy: Tenant → Management Groups → Subscriptions → Resource Groups → Resources.
- "Think of a tenant as your company, subscriptions as departments, and resource groups as project folders."
- Touch on tagging — "Tags are how you track costs and ownership at scale."
- Mention governance: Azure Policy, RBAC basics.
- Real-world tip: "One subscription per environment (dev/staging/prod) is a common pattern."

**Demo/Hands-On: Create Resource Groups + Set Up CLI (~10 min)**

- `az group create --name rg-demo --location eastus`
- Show tagging: `az group create --name rg-demo --location eastus --tags environment=dev owner=training`
- Walk attendees through verifying their CLI setup: `az account list`, `az configure --defaults location=eastus`.
- "Always tag everything — your future self will thank you."

---

### Storage Services (49 minutes)

**Presentation: Blobs, Files, Queues, Tables, Disk Storage (~20 min)**

- Azure Storage is foundational — almost every service depends on it.
- Five storage services:
  - **Blob Storage** — Unstructured data (images, videos, backups). The most used.
  - **File Storage** — SMB/NFS file shares. Lift-and-shift from on-prem.
  - **Queue Storage** — Message queuing for decoupled architectures.
  - **Table Storage** — NoSQL key-value store (consider Cosmos DB for new projects).
  - **Disk Storage** — Managed disks for VMs. Standard HDD, Standard SSD, Premium SSD, Ultra Disk.

**Presentation: Redundancy (LRS/ZRS/GRS) and Access Tiers (~9 min)**

- Redundancy options — draw it out:
  - LRS (3 copies, 1 datacenter) → ZRS (3 copies, 3 zones) → GRS (6 copies, 2 regions).
  - "Start with LRS for dev, use ZRS or GRS for production."
- Access tiers: Hot (frequent access), Cool (30-day min), Cold (90-day min), Archive (180-day min).
  - "Archive is 10x cheaper than hot, but rehydration takes hours."
  - Lifecycle management policies automate tier transitions.

**Demo/Hands-On: Create Storage Account + Upload Blobs + Queue Messages (~15 min)**

- Create storage account via CLI.
- Upload a file to blob storage.
- Create a queue and send a message — "queues decouple your services, so one slow component doesn't break everything."
- Show access tiers in the portal.
- Optional: Show Azure Storage Explorer.

**Q&A (~5 min)**

---

### Break (5 minutes)

---

### Networking Services (31 minutes)

**Presentation: VNets, Subnets, NSGs, Load Balancers, Private Endpoints (~13 min)**

- "Networking in Azure is like the plumbing of your house — invisible when it works, a disaster when it breaks."
- Core concepts:
  - **VNet** — Your private network in Azure. Isolated by default.
  - **Subnets** — Segments within a VNet (e.g., web tier, app tier, data tier).
  - **NSGs** — Firewall rules at the subnet or NIC level. Default: deny inbound, allow outbound.
  - **Load Balancers** — Distribute traffic. L4 (basic) vs L7 (Application Gateway).
  - **Private Endpoints** — Access PaaS services over private IP. "No data over the public internet."
- Draw a simple architecture: VNet → 2 subnets → NSGs → VMs.

**Demo/Hands-On: Create a Virtual Network + NSG Rules (~13 min)**

- `az network vnet create` and `az network nsg create`.
- Add an NSG rule to allow SSH/RDP.
- Show the effective security rules in the portal.
- "Always use NSGs. Never leave VMs exposed without them."

**Q&A (~5 min)**

---

### Break (5 minutes)

---

### Azure Compute Services — Windows (27 minutes)

**Presentation: VM Types, Availability, Access (~8 min)**

- VM sizes: B-series (burstable, cheap), D-series (general), F-series (compute-optimized).
- "Start with B2s for dev — it's cheap and good enough for testing."
- Availability: Availability Sets (fault/update domains) vs Availability Zones (physically separate datacenters).
- Access: RDP for Windows, Bastion for secure access without public IP.

**Demo/Hands-On: Deploy a Windows VM + Connect (~7 min)**

- Deploy a Windows VM via CLI or portal.
- RDP in (or show Bastion), show IIS or basic config.
- "Notice the steps: create VM, open port, connect. Now compare this with App Service..."

**Demo/Hands-On: Deploy an App to App Service (~7 min)**

- Deploy the Cloud Quote API to App Service.
- App Service: "If you just want to deploy a web app, skip VMs and use App Service."
  - Built-in SSL, auto-scale, deployment slots, CI/CD integration.
- "Notice how much simpler App Service is — no OS patching, no IIS config, no RDP."

**Q&A (~5 min)**

---

### Break (5 minutes)

---

### Azure Compute Services — Linux & Kubernetes Intro (27 minutes)

**Presentation: Linux Workloads & Kubernetes Fundamentals (~10 min)**

- Linux VMs on Azure — Ubuntu, RHEL, SUSE. Most Azure VMs are actually Linux.
- Kubernetes fundamentals: Pods, Services, Deployments, kubectl.
- MicroK8s: lightweight, single-node K8s — perfect for learning.
- "You don't need AKS to learn Kubernetes. MicroK8s on a VM is a great starting point. And for running containers without K8s, we'll use Container Apps next."

**Demo/Hands-On: Deploy Linux VM + Install MicroK8s (~17 min)**

- Deploy Ubuntu VM, SSH in.
- Install MicroK8s: `sudo snap install microk8s --classic`
- Deploy & scale a container workload:
  - `microk8s kubectl create deployment nginx --image=nginx`
  - `microk8s kubectl scale deployment nginx --replicas=3`
  - `microk8s kubectl get pods` — "your first Kubernetes moment."
- "You just scaled from 1 to 3 replicas with a single command. That's the power of orchestration."

---

### Azure Container Services (22.5 minutes)

**Presentation: ACR + Container Apps Overview (~8 min)**

- Container workflow: Build image → Push to registry → Deploy to runtime.
- **Azure Container Registry (ACR)** — Private Docker registry in Azure.
- **Azure Container Apps** — Serverless container platform. No clusters, no nodes, scale-to-zero.
  - Consumption plan: ~$0 at low traffic. Built-in HTTPS.
- Mention AKS exists for production K8s workloads at scale, but Container Apps is the simpler path.
- "Container Apps gives you container flexibility without Kubernetes complexity."

**Demo/Hands-On: Build Container → Push to ACR → Deploy to Container Apps (~8 min)**

- Build the Cloud Dashboard container.
- Push to ACR.
- Deploy to Container Apps with `az containerapp create`.
- Open the public URL — "your container is live on the internet with two commands."

**Q&A (~4 min)**

**POLL: Which Azure service is best for running containerized applications without managing servers or Kubernetes Clusters?**

- Options: AKS / Azure Container Apps / Azure Container Instances / App Service
- Correct answer: **Azure Container Apps** — serverless containers with scale-to-zero, no cluster management.
- "This is exactly what we just deployed. Container Apps is the sweet spot."

**End of Day 1 — Recap**

- "Today we covered the foundations: portal, CLI, storage, networking, compute (Windows + Linux), and containers."
- "Tomorrow we go deeper: serverless, databases, cost optimization, AI, and architecture design."
- Remind them to bring questions tomorrow.

---

## DAY 2 — ADVANCED SERVICES

---

### Azure Serverless Services (49 minutes)

**Presentation: Azure Functions + Triggers/Bindings (~12 min)**

- Serverless = no servers to manage, auto-scale to zero, pay per execution.
- **Azure Functions**:
  - Triggers: HTTP, Timer, Blob, Queue, Cosmos DB, Event Grid.
  - Bindings: input/output connectors — "write less plumbing code."
  - Plans: Consumption (pay-per-use, cold starts) vs Premium (pre-warmed, VNet) vs Dedicated.
  - Languages: C#, Python, JavaScript, Java, PowerShell.

**Demo/Hands-On: Build a Function (~10 min)**

- Create an HTTP-triggered Python function locally.
- Test locally, then deploy to Azure.
- Invoke it via browser or curl — "your code is now running in the cloud with zero infrastructure."

**Presentation: Logic Apps (~7 min)**

- **Logic Apps**: Visual workflow designer for integration scenarios.
  - 400+ connectors: Office 365, Salesforce, SAP, Teams, etc.
  - "Logic Apps is low-code glue for connecting systems."
- When to use what: Functions for code, Logic Apps for workflows, Durable Functions for orchestration.

**Demo/Hands-On: Create Workflow Automation (~10 min)**

- Create a Logic App that triggers on a schedule or event.
- Connect it to the Function or another service.
- "You just built a serverless pipeline with zero infrastructure."

**Q&A (~10 min)**

---

### Break (5 minutes)

---

### Database & Data Services (49 minutes)

**Presentation: Azure SQL, PostgreSQL/MySQL (~10 min)**

- Azure's relational database menu:
  - **Azure SQL** — Fully managed SQL Server. DTU vs vCore purchasing models.
  - **Azure Database for PostgreSQL/MySQL** — Managed open-source databases.
- Decision point: "SQL Server shop? Use Azure SQL. Open-source preference? PostgreSQL."

**Presentation: Cosmos DB Fundamentals (~12 min)**

- **Cosmos DB** — Globally distributed, multi-model NoSQL.
  - APIs: NoSQL (native), MongoDB, Cassandra, Gremlin, Table.
  - Partition keys: "Choose wisely — this is your most important design decision."
  - RU/s: Request Units per second — "the currency of Cosmos DB."
  - Single-digit millisecond latency, 99.999% SLA with multi-region writes.

**Presentation: Microsoft Fabric Overview (~7 min)**

- **Microsoft Fabric** — Unified analytics platform.
  - Lakehouse architecture — combine data lake and data warehouse.
  - Power BI integration — analytics built in, not bolted on.
  - Data pipelines — ETL/ELT orchestration.
  - "Fabric is where Azure is heading for analytics. It unifies everything under one roof."

**Demo/Hands-On: Create Cosmos DB Instance + Test App Connection (~15 min)**

- Create a Cosmos DB account (NoSQL API).
- Run the Python test app — CRUD operations.
- Show Data Explorer in the portal.
- "Cosmos DB gives you single-digit millisecond reads anywhere in the world."

**Q&A (~5 min)**

---

### Break (5 minutes)

---

### Azure Billing & Cost Optimization (18 minutes)

**Presentation: Cost Management, Budgets, Resource Tagging (~10 min)**

- "The cloud is not automatically cheaper — you have to manage it."
- Key tools:
  - **Cost Management + Billing** — See where your money is going.
  - **Budgets** — Set spending limits with alerts.
  - **Azure Advisor** — Free recommendations for cost, security, performance.
  - **Azure Pricing Calculator** — Estimate before you deploy.
- Cost-saving strategies:
  - Reserved Instances (1yr = ~30% off, 3yr = ~60% off).
  - Spot VMs for fault-tolerant workloads (up to 90% off).
  - Right-sizing — "most VMs are over-provisioned."
  - Auto-shutdown for dev/test VMs.
  - Tags for cost allocation — "if you can't see where the money goes, you can't save it."

**Demo/Hands-On: Billing Alerts (~8 min)**

- Create a budget in the portal.
- Set alert thresholds at 50%, 80%, 100%.
- "Do this on day one of every project. No exceptions."

---

### Break (5 minutes)

**POLL: What is the new name for the Azure AI Platform (as of Ignite 2025)?**

- Run during the break to build anticipation for the next module.
- Options: Azure AI Studio / Azure AI Foundry / Azure Machine Learning Studio / Azure Cognitive Services
- Correct answer: **Azure AI Foundry** — rebranded at Ignite 2025.
- When resuming: "For those who got it right — nice, you're staying current. For everyone else, let's dive in."

---

### Azure AI Foundry (45 minutes)

**Presentation (~20 min)**

- Azure AI Foundry: one platform for building AI applications.
  - **Azure AI Foundry workspaces** — organize models, data, deployments per project.
  - **Model Catalog** — OpenAI GPT, Phi, Llama, Mistral, embedding models, and more.
    - "You don't need to train models. Pick one from the catalog, deploy it, prompt it."
  - **Prompt Flow + model orchestration** — visual pipeline builder for LLM workflows.
    - Chain prompts, add grounding data, evaluate quality.
- Key concepts:
  - Deployments: assign a model to an endpoint with a specific SKU.
  - System prompts: control the personality and constraints of your AI.
  - Responsible AI: content filters, groundedness, safety evaluations.
- "You don't need to be an ML engineer to use Azure AI. The models are pre-trained — you just deploy and prompt."

**Demo/Hands-On: Build + Test a Simple Chatbot in Azure AI Foundry (~20 min)**

- Create an AI Foundry project.
- Deploy a GPT model from the catalog.
- Run the Python chatbot script.
- Show how changing the system prompt changes behavior.
- "In 20 minutes you built a chatbot. That's the power of managed AI."

**Q&A (~5 min)**

---

### Whiteboard Activity: Designing a Small Architecture (45 minutes)

**Facilitation Notes**

- This is a collaborative whiteboard session, not a lecture. Energy should be high.
- Split attendees into small groups (3-5 people).
- **Goal**: "Design a small architecture to support a web front end and database back end."

**Setup (~5 min)**

- Hand out whiteboards/markers or open a shared draw.io / Excalidraw.
- Each group picks a scenario variation (e-commerce site, internal dashboard, API platform, etc.).
- Constraints: must be cost-effective, scalable, and secure.

**Group Work (~25 min)**

- Each group should:
  1. Choose Azure services for each tier (frontend, backend/API, database, networking).
  2. Draw an architecture diagram.
  3. Consider:
     - **Reliability** — How does it handle failures?
     - **Security** — How is data protected? Authentication?
     - **Cost Optimization** — What's the estimated monthly cost?
     - **Operational Excellence** — How is it deployed and monitored?
     - **Performance** — How does it scale under load?
- Walk around, ask guiding questions: "What happens if this VM goes down?" / "How do users authenticate?"

**Team Presentations (~15 min)**

- Each group presents their architecture (3-5 min each).
- Provide feedback — "there's no single right answer, but there are bad ones."
- Highlight creative solutions and common pitfalls.

---

### Wrap-Up (10 minutes)

**Key Takeaways**

- "Over two days we've gone from portal basics to deploying AI chatbots. Let's recap."
- Day 1: Portal, CLI, storage, networking, compute (Windows + Linux), containers.
- Day 2: Serverless, databases, cost management, AI, architecture design.
- "Azure has 200+ services. We covered the essential ones. You now have the foundation to explore the rest."

**Recommended Learning Paths & Certs**

- **AZ-900** (Azure Fundamentals) — start here, validates what you learned today.
- **AZ-104** (Azure Administrator) — next step for ops/infra roles.
- **AZ-204** (Azure Developer) — next step for dev roles.
- Microsoft Learn free learning paths.
- Explore the course repo and wiki for deeper dives.
- Join the Discord community for help: https://discord.gg/vwfwq2EpXJ

**Final Q&A**

- "Any last questions before we wrap?"
- "Thank you for your time. Keep building, keep learning. Code to Cloud."

---

## GENERAL TIPS FOR PRESENTERS

- **Polls**: Use polls at every marked point — they re-engage the room and give you data to adjust pacing.
- **Pacing**: If a demo breaks, don't panic. Show the portal fallback or pre-recorded backup.
- **Engagement**: Ask the audience questions every 15 min. "Who has used blob storage before?"
- **Time management**: Modules run tight. If Q&A goes long, offer to follow up in Discord.
- **Demos**: Always have a pre-deployed environment as backup. `azd up` the night before.
- **Breaks**: Enforce breaks. Use break time for polls so results are ready when you resume.
- **Energy**: Day 2 afternoon is the hardest. The AI Foundry module tends to re-energize the room.
- **Transitions**: Use the polls and break prompts as natural transitions between modules.
