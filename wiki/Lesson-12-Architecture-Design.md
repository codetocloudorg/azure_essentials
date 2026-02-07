# Lesson 12: Architecture & Design

> **Time:** 30 minutes | **Difficulty:** Medium | **Cost:** $0 (concepts only)

## 🎯 What You'll Learn

By the end of this lesson, you'll understand:
- Azure Well-Architected Framework pillars
- Common architecture patterns
- How to design resilient, scalable systems
- Real-world architecture examples

---

## 🏛️ Azure Well-Architected Framework

Microsoft's guide for building quality cloud workloads.

### The Five Pillars

| Pillar | Question It Answers |
|--------|---------------------|
| **Reliability** | Will it keep working? |
| **Security** | Is it protected? |
| **Cost Optimization** | Is it worth the money? |
| **Operational Excellence** | Can we run it well? |
| **Performance Efficiency** | Is it fast enough? |

---

## 🛡️ Pillar 1: Reliability

**Goal:** Keep your application running even when things fail.

### Key Concepts

| Concept | Meaning |
|---------|---------|
| **Availability** | % of time system is up (99.9% = 8.7 hours downtime/year) |
| **Redundancy** | Multiple copies so one failure doesn't stop everything |
| **Failover** | Automatically switch to backup when primary fails |
| **Recovery** | How fast can you restore after disaster? |

### Azure Services for Reliability

| Pattern | Azure Service |
|---------|---------------|
| Multi-region deployment | Traffic Manager, Azure Front Door |
| Data replication | Cosmos DB global distribution, SQL geo-replication |
| Redundant storage | GRS, ZRS storage options |
| Health monitoring | Azure Monitor, Application Insights |

### Design Tips

```
✅ DO:
- Deploy to at least 2 availability zones
- Use load balancers to distribute traffic
- Set up automated health probes
- Test failover regularly

❌ DON'T:
- Run single instances of critical services
- Assume your code won't fail
- Forget backup/restore testing
```

---

## 🔒 Pillar 2: Security

**Goal:** Protect data and systems from threats.

### Defense in Depth

Layer your security like an onion:

```
┌─────────────────────────────────┐
│         Physical Security       │  ← Azure datacenters
├─────────────────────────────────┤
│      Identity & Access (IAM)    │  ← Azure AD, RBAC
├─────────────────────────────────┤
│          Network Security       │  ← NSGs, Firewalls
├─────────────────────────────────┤
│        Compute Protection       │  ← VM hardening
├─────────────────────────────────┤
│        Application Security     │  ← Code practices
├─────────────────────────────────┤
│         Data Protection         │  ← Encryption
└─────────────────────────────────┘
```

### Key Azure Security Services

| Service | Purpose |
|---------|---------|
| **Azure AD (Entra ID)** | Identity management |
| **Key Vault** | Secrets & certificates |
| **Defender for Cloud** | Security posture |
| **DDoS Protection** | Attack mitigation |

### Security Best Practices

```
✅ DO:
- Use Managed Identities (no passwords!)
- Enable MFA for all users
- Store secrets in Key Vault
- Encrypt data at rest AND in transit

❌ DON'T:
- Hard-code credentials in code
- Use shared accounts
- Leave ports open to 0.0.0.0/0
- Ignore security alerts
```

---

## 💰 Pillar 3: Cost Optimization

**Goal:** Get the most value for your money.

### Cost Drivers

| Factor | How to Optimize |
|--------|-----------------|
| **Compute** | Right-size VMs, use reserved instances |
| **Storage** | Choose right tier, lifecycle policies |
| **Network** | Reduce data transfer, use CDN |
| **Licensing** | Azure Hybrid Benefit for Windows |

### Cost Optimization Strategies

```
┌──────────────────────────────────────┐
│            Shut Down                 │  Idle dev/test resources
├──────────────────────────────────────┤
│            Right-Size                │  Match resources to actual need
├──────────────────────────────────────┤
│           Reserve                    │  1-3 year commitments for savings
├──────────────────────────────────────┤
│           Spot VMs                   │  Interruptible workloads at 90% off
├──────────────────────────────────────┤
│          Serverless                  │  Pay only when code runs
└──────────────────────────────────────┘
```

---

## ⚙️ Pillar 4: Operational Excellence

**Goal:** Run and monitor systems effectively.

### DevOps Practices

| Practice | Azure Tool |
|----------|------------|
| **Source Control** | Azure Repos, GitHub |
| **CI/CD** | Azure Pipelines, GitHub Actions |
| **Infrastructure as Code** | Bicep, Terraform, ARM |
| **Monitoring** | Azure Monitor, Log Analytics |

### Monitoring Pyramid

```
        ┌──────────────┐
        │    Alerts    │  ← Wake me up at 3 AM
        ├──────────────┤
        │  Dashboards  │  ← Daily check
        ├──────────────┤
        │    Metrics   │  ← CPU, memory, requests
        ├──────────────┤
        │     Logs     │  ← Detailed investigation
        └──────────────┘
```

---

## 🚀 Pillar 5: Performance Efficiency

**Goal:** Meet performance requirements as demand changes.

### Scaling Patterns

| Pattern | When to Use |
|---------|-------------|
| **Scale Up (Vertical)** | Bigger machine (more CPU/RAM) |
| **Scale Out (Horizontal)** | More machines |
| **Auto-scaling** | Dynamic based on metrics |

### Performance Tips

| Issue | Solution |
|-------|----------|
| Slow database | Add read replicas, caching (Redis) |
| High latency | Use CDN, deploy closer to users |
| Traffic spikes | Auto-scale, use queue-based load leveling |
| Slow API | Async processing, caching |

---

## 📐 Common Architecture Patterns

### Pattern 1: Three-Tier Web App

```
┌─────────────────────────────────────────────┐
│               Load Balancer                  │
└─────────────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐
   │  Web 1  │ │  Web 2  │ │  Web 3  │   ← Presentation
   └─────────┘ └─────────┘ └─────────┘
        │            │            │
        └────────────┼────────────┘
                     ▼
   ┌─────────────────────────────────────┐
   │          Application Layer           │   ← Business Logic
   │     (API Management, Functions)      │
   └─────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐
   │   SQL   │ │  Cosmos │ │  Redis  │   ← Data
   └─────────┘ └─────────┘ └─────────┘
```

**Azure Services:**
- App Service or AKS (Web tier)
- API Management + Functions (API tier)
- SQL Database + Cosmos DB + Redis Cache (Data tier)

### Pattern 2: Microservices

```
                    ┌──────────────┐
                    │   API Gateway │
                    │ (API Mgmt)    │
                    └──────┬───────┘
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌────────────┐  ┌────────────┐  ┌────────────┐
    │ User Svc   │  │ Order Svc  │  │Product Svc │
    │ (Container)│  │ (Container)│  │ (Container)│
    └─────┬──────┘  └─────┬──────┘  └─────┬──────┘
          │               │               │
          ▼               ▼               ▼
    ┌─────────┐     ┌─────────┐     ┌─────────┐
    │Users DB │     │Orders DB│     │ Products │
    │ (SQL)   │     │(Cosmos) │     │   DB     │
    └─────────┘     └─────────┘     └─────────┘
```

**Azure Services:**
- Azure Kubernetes Service (AKS) or Container Apps
- Service Bus for messaging between services
- Each service has its own database

### Pattern 3: Event-Driven

```
┌──────────┐     ┌─────────────┐     ┌──────────────┐
│  Events  │ ──▶ │ Event Hub   │ ──▶ │  Function    │
│(IoT, web)│     │ or Grid     │     │  Processing  │
└──────────┘     └─────────────┘     └──────────────┘
                                            │
                       ┌────────────────────┼──────────────────┐
                       ▼                    ▼                  ▼
                ┌────────────┐       ┌────────────┐     ┌────────────┐
                │  Storage   │       │  Database  │     │   Alert    │
                └────────────┘       └────────────┘     └────────────┘
```

**Azure Services:**
- Event Hub (millions of events/second)
- Event Grid (reactive events)
- Azure Functions (event processing)

---

## 🎨 Real-World Example: E-Commerce Site

```
               ┌─────────────────────────────────┐
               │        Azure Front Door          │  ← CDN + WAF + Load Balancer
               └─────────────────────────────────┘
                              │
          ┌───────────────────┴───────────────────┐
          ▼                                       ▼
    ┌──────────────┐                      ┌──────────────┐
    │  Region: US  │                      │ Region: EU   │  ← Multi-region
    └──────────────┘                      └──────────────┘
          │                                       │
          ▼                                       ▼
    ┌──────────────┐                      ┌──────────────┐
    │  App Service │                      │  App Service │
    │  (Web App)   │                      │  (Web App)   │
    └──────────────┘                      └──────────────┘
          │                                       │
          ▼                                       ▼
    ┌──────────────┐                      ┌──────────────┐
    │   Cosmos DB  │◀━━━━━━━━━━━━━━━━━━━━━▶│   Cosmos DB  │  ← Global replication
    │  (Products)  │                      │  (Products)  │
    └──────────────┘                      └──────────────┘
          │                                       │
          ▼                                       ▼
    ┌──────────────┐                      ┌──────────────┐
    │  Redis Cache │                      │  Redis Cache │  ← Session + catalog cache
    └──────────────┘                      └──────────────┘
```

**Why this architecture?**
- Front Door: Global load balancing, DDoS protection, caching
- Multi-region: Low latency for users worldwide
- Cosmos DB: Global replication keeps data in sync
- Redis: Fast caching for frequently accessed data

---

## 📋 Architecture Decision Checklist

Before designing, ask:

| Category | Question |
|----------|----------|
| **Users** | Where are they located? How many concurrent? |
| **Availability** | What uptime SLA do you need? |
| **Data** | How much? How sensitive? |
| **Compliance** | GDPR, HIPAA, SOC2 requirements? |
| **Budget** | What's the monthly spend limit? |
| **Team** | What skills do you have? |

---

## 🛠️ Architecture Tools

| Tool | Purpose |
|------|---------|
| **Azure Architecture Center** | Reference architectures |
| **Well-Architected Review** | Assess your design |
| **Azure Advisor** | Personalized recommendations |
| **Pricing Calculator** | Estimate costs |

### Resources

- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)
- [Well-Architected Framework](https://docs.microsoft.com/azure/architecture/framework/)
- [Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/)

---

## ✅ What You Learned

- 🏛️ The five Well-Architected Framework pillars
- 📐 Common architecture patterns (3-tier, microservices, event-driven)
- 🛡️ Security defense in depth
- 💰 Cost optimization strategies
- 🎨 How real-world architectures look

---

## 🎓 Course Complete!

Congratulations! You've completed Azure Essentials!

### What's Next?

1. **Get Certified:**
   - AZ-900: Azure Fundamentals
   - AZ-104: Azure Administrator
   - AZ-204: Azure Developer

2. **Build Something:**
   - Pick a personal project
   - Apply what you learned
   - Share it with the community!

3. **Stay Connected:**
   - 💬 [Discord Community](https://discord.gg/vwfwq2EpXJ)
   - 🎧 [Podcast](https://open.spotify.com/show/1iOZfFVamUk7CJPOvtU00v)
   - 🌐 [Website](https://www.codetocloud.io)

---

*Thank you for learning with Code to Cloud Inc.! 🚀*
