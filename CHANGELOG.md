# Changelog

All notable changes to the Azure Essentials training course will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [1.3.0] - 2026-01-18

### Added

- **Deployment validation script** - New `scripts/bash/test-deployment.sh` for verifying lesson deployments during live training
- **Comprehensive code comments** throughout the repository for training delivery:
  - All Bicep modules now include educational comments explaining Azure concepts
  - Bash deploy.sh enhanced with trainer tips and flow documentation
  - Storage, Networking, Compute, Functions, CosmosDB, Container Registry modules fully documented

### Changed

- **Enhanced bash deploy.sh** - Added comprehensive header documentation, trainer tips, and section-by-section explanations
- **Improved Bicep modules** - Each module now includes:
  - Cost breakdown information
  - Architecture diagrams (ASCII)
  - Trainer tips for live demos
  - Detailed property explanations

### Documentation Improvements

- `storage.bicep` - SKU guide, access tier explanation, encryption settings
- `networking.bicep` - 3-tier architecture diagram, NSG rule priorities
- `compute-windows.bicep` - VM sizing, App Service SKU comparison, auto-shutdown
- `cosmosdb.bicep` - Consistency levels, partition key guidance, serverless vs provisioned
- `container-registry.bicep` - SKU comparison, authentication options
- `linux-microk8s.bicep` - MicroK8s commands, SSH access instructions
- `functions.bicep` - Consumption plan pricing, trigger types

---

## [1.2.0] - 2026-01-18

### Added

- **Copy-paste command reference** - New `scripts/azure-cli/commands/` folder with individual markdown files for each lesson, optimized for Azure Cloud Shell users
- **Sample applications** with Code to Cloud branding:
  - Lesson 05: Cloud Quote API (Windows App Service)
  - Lesson 07: Cloud Dashboard (Container sample)
- **Lessons index** - New `lessons/README.md` with quick navigation
- **CHANGELOG.md** - This file for version tracking

### Changed

- **Default region** changed from `uksouth` to `centralus` for better availability across all scripts and lessons
- **README.md** - Updated repository structure to accurately reflect folder organization
- Improved documentation consistency across all lessons

### Fixed

- Corrected script path references in main README.md

---

## [1.1.0] - 2026-01-15

### Added

- Azure CLI deployment scripts (`scripts/azure-cli/`)
- PowerShell deployment scripts (`scripts/powershell/`)
- Interactive deployment menu with region selection
- Per-lesson resource group structure

### Changed

- Reorganized scripts into `azure-cli/`, `bash/`, and `powershell/` folders
- Updated quota guidance for free tier accounts

---

## [1.0.0] - 2026-01-10

### Added

- Initial course release
- 12 lessons covering Azure fundamentals to AI services
- Bicep infrastructure modules
- Azure Developer CLI (azd) integration
- Dev Container configuration
- Prerequisites and setup guides for Windows, macOS, Linux
- Sample applications for serverless, database, and AI lessons

---

## Legend

- **Added** - New features
- **Changed** - Changes in existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Security improvements
