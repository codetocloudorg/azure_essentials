# 🏠 Azure Essentials Wiki

> **Welcome, future cloud engineer!** This wiki is your beginner-friendly guide to the Azure Essentials course. If you're new to cloud computing, start here.

---

## 🆕 New to Azure? Start Here!

### What is Azure?

Imagine you need a computer to run your website. Instead of buying an expensive server and keeping it in your closet, you can **rent** a computer from Microsoft. That's Azure!

**Azure = Microsoft's Cloud Computing Platform**

It's like renting:
- 💻 **Computers** (Virtual Machines) - without buying hardware
- 💾 **Storage** (Blob Storage) - without buying hard drives  
- 🌐 **Networks** (Virtual Networks) - without buying routers
- 🗄️ **Databases** (Cosmos DB) - without managing database servers

### Why Use Azure?

| Old Way (On-Premises) | New Way (Azure) |
|-----------------------|-----------------|
| Buy servers upfront ($10,000+) | Pay only for what you use ($5/month to start) |
| Wait weeks for hardware | Create in minutes |
| Manage everything yourself | Microsoft handles maintenance |
| Limited to one location | Available in 60+ regions worldwide |

---

## 📚 Course Structure

This is a **2-day hands-on course**. Each lesson builds on the previous one.

### Day 1: Foundations

| Lesson | Topic | What You'll Build |
|--------|-------|-------------------|
| [00](Lesson-00-Prerequisites) | Prerequisites | Set up your environment |
| [01](Lesson-01-Introduction) | Introduction to Azure | Understand cloud concepts |
| [02](Lesson-02-Getting-Started) | Getting Started | Create your first resource group |
| [03](Lesson-03-Storage) | Storage Services | Create a storage account, upload files |
| [04](Lesson-04-Networking) | Networking | Build a virtual network |
| [05](Lesson-05-Compute-Windows) | Windows Compute | Deploy a Windows VM, connect via RDP |
| [06](Lesson-06-Compute-Linux) | Linux & Kubernetes | Deploy Linux VM with MicroK8s |

### Day 2: Advanced Services

| Lesson | Topic | What You'll Build |
|--------|-------|-------------------|
| [07](Lesson-07-Containers) | Container Services | Deploy to Azure Container Apps |
| [08](Lesson-08-Serverless) | Serverless | Create an Azure Function |
| [09](Lesson-09-Database-Services) | Database Services | Set up Cosmos DB |
| [10](Lesson-10-Billing-Cost) | Billing & Cost | Monitor and optimize costs |
| [11](Lesson-11-AI-Foundry) | AI Services | Build an AI chatbot |
| [12](Lesson-12-Architecture-Design) | Architecture Design | Design a complete solution |

---

## 🚦 Before You Start

### 1. What You Need

✅ **Required:**
- [ ] An [Azure Account](https://azure.microsoft.com/free/) (free tier available!)
- [ ] A computer with internet access
- [ ] About 2-4 hours per day

📌 **Recommended:**
- [ ] [VS Code](https://code.visualstudio.com/) installed
- [ ] Basic understanding of what a "command line" is

### 2. Quick Setup (5 minutes)

**Option A: Use GitHub Codespaces (Easiest!)**

Click this button and everything is set up for you:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/codetocloudorg/azure_essentials)

**Option B: Set Up Locally**

```bash
# Clone the repository
git clone https://github.com/codetocloudorg/azure_essentials.git
cd azure_essentials

# Run the setup script
./scripts/bash/setup-local-tools.sh

# Validate your environment
./scripts/bash/validate-env.sh
```

---

## 💡 Tips for Success

### For Complete Beginners

1. **Don't panic!** Everyone starts somewhere
2. **Type the commands** - don't just copy/paste (you'll learn faster)
3. **Read error messages** - they usually tell you what's wrong
4. **Ask questions** - join our [Discord](https://discord.gg/vwfwq2EpXJ)

### Common Questions

<details>
<summary><strong>❓ Will this cost me money?</strong></summary>

Most lessons use Azure's free tier. If you follow the cleanup instructions after each lesson, your costs should be **$0-$5 total**. We'll show you how to monitor costs in Lesson 10.

</details>

<details>
<summary><strong>❓ What if I break something?</strong></summary>

You can't break Azure! At worst, you might create resources that cost money. That's why we teach you to use **Resource Groups** - you can delete everything with one command.

</details>

<details>
<summary><strong>❓ Do I need to know programming?</strong></summary>

No! Some lessons have optional code examples, but the core concepts don't require coding. You'll mostly be running commands and clicking in the Azure Portal.

</details>

---

## 🆘 Getting Help

| Resource | Use When... |
|----------|-------------|
| [Troubleshooting Guide](Troubleshooting) | Something isn't working |
| [Glossary](Glossary) | You don't understand a term |
| [Discord Community](https://discord.gg/vwfwq2EpXJ) | You need human help |
| [Azure Docs](https://learn.microsoft.com/azure/) | You want to go deeper |

---

## 🎯 Ready to Start?

👉 **[Begin with Lesson 00: Prerequisites](Lesson-00-Prerequisites)**

---

*Azure Essentials by [Code to Cloud Inc.](https://www.codetocloud.io) | "There is no cloud. It's just someone else's computer."*
