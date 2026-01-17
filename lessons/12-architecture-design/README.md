# Lesson 12: Architecture Design

> **Duration**: 45 minutes | **Day**: 2

## Overview

This lesson brings together everything you've learned through a collaborative architecture design session. You'll work through designing a real-world Azure solution that incorporates compute, storage, networking, data services, and more.

## Learning Objectives

By the end of this lesson, you will be able to:

- Apply Azure services to solve real-world requirements
- Design architectures following Azure best practices
- Consider security, scalability, and cost in your designs
- Use the Azure Well-Architected Framework pillars
- Communicate architecture decisions effectively

---

## The Well-Architected Framework

Every Azure architecture should consider these five pillars:

| Pillar | Description | Key Questions |
|--------|-------------|---------------|
| **Reliability** | Ability to recover from failures | How will the system handle outages? |
| **Security** | Protecting data and systems | How is data encrypted and access controlled? |
| **Cost Optimisation** | Managing and reducing costs | What's the TCO? Where can we optimise? |
| **Operational Excellence** | Running and monitoring systems | How will we deploy and monitor? |
| **Performance Efficiency** | Meeting performance requirements | Will it scale? What are the bottlenecks? |

---

## Design Exercise: E-Commerce Platform

### Scenario

A retail company needs a modern e-commerce platform with the following requirements:

#### Functional Requirements

- Product catalogue with search functionality
- User authentication and profiles
- Shopping cart and checkout process
- Order processing and notifications
- Admin dashboard for inventory management

#### Non-Functional Requirements

| Requirement | Target |
|-------------|--------|
| Availability | 99.9% uptime |
| Response time | < 200ms for page loads |
| Users | 10,000 concurrent users at peak |
| Data retention | 7 years for orders |
| Regions | Primary UK, DR in Europe |

### Design Workshop

Work through each layer of the architecture:

---

### Step 1: Frontend Layer

**Questions to consider**:
- How will users access the application?
- What type of content needs to be served?
- How will we handle global traffic?

**Potential services**:

| Service | Purpose | Justification |
|---------|---------|---------------|
| Azure Static Web Apps | Host React/Vue frontend | Serverless, global CDN included |
| Azure CDN | Cache static assets | Reduce latency worldwide |
| Azure Front Door | Global load balancing | WAF, SSL termination, routing |

**Architecture notes**:

```
Users → Azure Front Door → CDN → Static Web Apps
                    ↓
            (API routing to backend)
```

---

### Step 2: API Layer

**Questions to consider**:
- How will the frontend communicate with backend services?
- What authentication mechanism will we use?
- How do we handle varying load?

**Potential services**:

| Service | Purpose | Justification |
|---------|---------|---------------|
| Azure API Management | API gateway | Rate limiting, authentication, analytics |
| Azure Functions | API endpoints | Serverless scaling, cost-effective |
| App Service | API hosting | More control, WebSockets support |
| Azure AD B2C | Customer identity | Managed auth, social logins |

---

### Step 3: Application Logic

**Questions to consider**:
- What processing happens in the background?
- How do we handle order processing?
- What events need to trigger actions?

**Potential services**:

| Service | Purpose | Justification |
|---------|---------|---------------|
| Azure Functions | Event processing | Serverless, event-driven |
| Logic Apps | Workflow automation | Visual designer, connectors |
| Service Bus | Message queuing | Reliable message delivery |
| Event Grid | Event routing | React to Azure events |

**Order processing flow**:

```
Order Placed → Service Bus Queue → Function (Process) → 
    ├── Update Inventory (Cosmos DB)
    ├── Send Confirmation (Logic App → Email)
    └── Notify Warehouse (Event Grid → External)
```

---

### Step 4: Data Layer

**Questions to consider**:
- What types of data do we need to store?
- What are the access patterns?
- How long must we retain data?

**Potential services**:

| Data Type | Service | Justification |
|-----------|---------|---------------|
| Product catalogue | Cosmos DB | Fast reads, flexible schema |
| User profiles | Azure SQL | Relational, ACID transactions |
| Session data | Azure Cache for Redis | Low latency, ephemeral |
| Order history | Cosmos DB | Scalable, partition by user |
| Images/Media | Blob Storage | Cost-effective, CDN integration |

---

### Step 5: Networking and Security

**Questions to consider**:
- How do we isolate components?
- What traffic should be public vs private?
- How do we protect against attacks?

**Design decisions**:

| Concern | Solution |
|---------|----------|
| Network isolation | VNet with subnets for each tier |
| Private connectivity | Private Endpoints for PaaS services |
| DDoS protection | Azure DDoS Protection Standard |
| Web security | Web Application Firewall on Front Door |
| Secrets management | Azure Key Vault |
| Identity | Managed Identities for service-to-service |

---

### Step 6: Monitoring and Operations

**Questions to consider**:
- How will we know if something is wrong?
- How do we deploy changes safely?
- What metrics matter most?

**Potential services**:

| Service | Purpose |
|---------|---------|
| Application Insights | Application performance monitoring |
| Log Analytics | Centralised logging |
| Azure Monitor | Metrics and alerts |
| Azure DevOps / GitHub Actions | CI/CD pipelines |

---

## Architecture Diagram Template

Use this template structure for your design:

```
┌─────────────────────────────────────────────────────────────────┐
│                         USERS / CLIENTS                          │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                      EDGE / CDN LAYER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ Azure Front │  │  Azure CDN  │  │     WAF     │              │
│  │    Door     │  │             │  │             │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                            │
│  ┌─────────────────────────┐  ┌─────────────────────────┐       │
│  │    Static Web Apps      │  │    API Management       │       │
│  │    (React Frontend)     │  │    (Gateway)            │       │
│  └─────────────────────────┘  └─────────────────────────┘       │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   Azure     │  │   Service   │  │   Logic     │              │
│  │  Functions  │  │     Bus     │  │    Apps     │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DATA LAYER                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │  Cosmos DB  │  │  Azure SQL  │  │    Blob     │              │
│  │ (Products)  │  │   (Users)   │  │   Storage   │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐                               │
│  │    Redis    │  │  Key Vault  │                               │
│  │   Cache     │  │  (Secrets)  │                               │
│  └─────────────┘  └─────────────┘                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Cost Estimation Exercise

Estimate monthly costs for the architecture:

| Service | Configuration | Estimated Cost |
|---------|--------------|----------------|
| Azure Front Door | Standard tier | £20/month |
| Static Web Apps | Standard | £7/month |
| API Management | Consumption | £3/10k calls |
| Azure Functions | Consumption | Based on usage |
| Cosmos DB | Serverless | Based on RUs |
| Azure SQL | Basic tier | £4/month |
| Blob Storage | Hot tier, 100GB | £2/month |
| Redis Cache | Basic C0 | £12/month |
| **Estimated Total** | | **~£100-200/month** |

> Use the [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) for accurate estimates.

---

## Your Design Challenge

Now it's your turn. Choose one of these scenarios:

### Option A: IoT Monitoring Platform
- Collect data from 10,000 sensors
- Real-time dashboards
- Alerting on anomalies
- 30-day data retention

### Option B: Media Streaming Service
- Video upload and processing
- Adaptive streaming to viewers
- Content recommendations
- Analytics on viewing habits

### Option C: Healthcare Records System
- Patient record management
- HIPAA/GDPR compliance
- Integration with hospital systems
- Audit logging

---

## Summary

In this lesson, you learned:

- ✅ The Azure Well-Architected Framework pillars
- ✅ How to decompose requirements into architecture layers
- ✅ Service selection based on requirements
- ✅ Designing for security, scalability, and cost
- ✅ Documenting architecture decisions

---

## Course Wrap-Up

Congratulations on completing Azure Essentials! You've covered:

| Day | Topics |
|-----|--------|
| **Day 1** | Cloud concepts, Portal/CLI, Storage, Networking, Compute, Containers |
| **Day 2** | Serverless, Databases, Cost Management, AI, Architecture Design |

### Next Steps

1. **Practice**: Continue experimenting with the services you've learned
2. **Certify**: Consider the [AZ-900](https://learn.microsoft.com/certifications/azure-fundamentals/) certification
3. **Build**: Create a project that uses multiple Azure services
4. **Learn more**: Explore advanced courses on specific services

---

## Additional Resources

- [Azure Architecture Center](https://learn.microsoft.com/azure/architecture/)
- [Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
- [Azure Solution Architectures](https://learn.microsoft.com/azure/architecture/browse/)
- [Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/)

---

## Thank You!

Thank you for participating in Azure Essentials Live Training.

Built with ❤️ by **Code to Cloud**
