// ============================================================================
// Azure Storage Account Module
// ============================================================================
// Code to Cloud | www.codetocloud.io
// Lesson 03: Storage Services
//
// WHAT THIS CREATES:
//   - Storage Account (general-purpose v2)
//   - Blob container for object storage exercises
//   - Queue for messaging exercises
//   - Table for NoSQL data exercises
//   - File share for SMB file storage exercises
//
// COST: Free tier eligible (5GB Blob, 5GB File, 50K Queue operations/month)
//
// SECURITY SETTINGS (Azure best practices):
//   - HTTPS-only traffic (TLS 1.2 minimum)
//   - No public blob access (private by default)
//   - Encryption at rest enabled
//   - Soft delete enabled (7-day recovery)
//
// TRAINER TIP: Demonstrate the different access tiers (Hot/Cool/Archive)
// and explain cost implications for storage-heavy workloads.
// ============================================================================

// ============================================================================
// PARAMETERS - Customizable inputs for the module
// ============================================================================

@description('Azure region for the storage account')
param location string

@description('Tags to apply to resources')
param tags object

@description('Name of the storage account')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Storage account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Standard_RAGRS'
])
param skuName string = 'Standard_LRS'

@description('Storage account kind')
@allowed([
  'StorageV2'
  'BlobStorage'
  'Storage'
])
param kind string = 'StorageV2'

// ============================================================================
// STORAGE ACCOUNT - The core resource
// ============================================================================
// Storage accounts are containers for all Azure Storage data objects:
// blobs, files, queues, and tables.
//
// SKU GUIDE:
//   LRS  = 3 copies in single datacenter (cheapest, 99.9% SLA)
//   ZRS  = 3 copies across zones (high availability, 99.9% SLA)
//   GRS  = 6 copies across regions (disaster recovery, 99.9% SLA)
//   RAGRS = GRS + read access to secondary (99.99% read SLA)

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: kind
  properties: {
    // Hot = Optimized for frequent access (higher storage cost, lower access cost)
    // Cool = Optimized for infrequent access (lower storage, higher access)
    // Archive = Long-term backup (lowest storage, highest access, hours to retrieve)
    accessTier: 'Hot'

    // SECURITY: Block anonymous public access to blobs
    // Production workloads should ALWAYS set this to false
    allowBlobPublicAccess: false

    // Allow storage account key authentication
    // For production, consider Azure AD authentication only
    allowSharedKeyAccess: true

    // SECURITY: Enforce TLS 1.2 or higher for all connections
    minimumTlsVersion: 'TLS1_2'

    // SECURITY: Only allow HTTPS connections (no HTTP)
    supportsHttpsTrafficOnly: true

    // ENCRYPTION: All data encrypted at rest using Microsoft-managed keys
    // For higher security, use customer-managed keys (CMK)
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: { enabled: true }
        file: { enabled: true }
        queue: { enabled: true }
        table: { enabled: true }
      }
    }
  }
}

// ============================================================================
// BLOB SERVICE - Object storage for unstructured data
// ============================================================================
// Blob storage is used for:
//   - Images, videos, documents
//   - Backup and archive data
//   - Static website hosting
//   - Data lake storage (when using hierarchical namespace)
//
// SOFT DELETE: Allows recovery of accidentally deleted blobs for 7 days

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7  // Recover deleted blobs for up to 7 days
    }
  }
}

// Sample container for hands-on exercises
// Containers are like folders that organize blobs
resource sampleContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'samples'
  properties: {
    publicAccess: 'None'  // Private access only (requires authentication)
  }
}

// ============================================================================
// QUEUE SERVICE - Asynchronous messaging
// ============================================================================
// Queue storage is used for:
//   - Decoupling application components
//   - Processing tasks asynchronously
//   - Building event-driven architectures
//
// Each message can be up to 64KB. For larger messages, use Blob + Queue.

resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

// Sample queue for messaging exercises
resource sampleQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-05-01' = {
  parent: queueService
  name: 'sample-messages'
}

// ============================================================================
// TABLE SERVICE - NoSQL key-value storage
// ============================================================================
// Table storage is used for:
//   - Structured NoSQL data
//   - Web scale apps without complex joins
//   - Address books, device info, metadata
//
// Each entity can be up to 1MB with 255 properties

resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

// Sample table for NoSQL exercises
resource sampleTable 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-05-01' = {
  parent: tableService
  name: 'sampledata'
}

// ============================================================================
// FILE SERVICE - SMB/NFS file shares
// ============================================================================
// File storage is used for:
//   - Lift-and-shift legacy apps that need file shares
//   - Shared configuration files
//   - Cross-platform file storage (Windows/Linux/macOS)

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

// Sample file share for exercises
resource sampleFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  parent: fileService
  name: 'samplefiles'
  properties: {
    shareQuota: 5  // 5 GB quota
    accessTier: 'Hot'
  }
}

// ============================================================================
// OUTPUTS - Values returned to the calling template
// ============================================================================
// These outputs can be used by other modules or displayed after deployment.
// Use these endpoints to connect applications to storage services.

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id

// Service endpoints for application connection strings
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
output queueEndpoint string = storageAccount.properties.primaryEndpoints.queue
output tableEndpoint string = storageAccount.properties.primaryEndpoints.table
output fileEndpoint string = storageAccount.properties.primaryEndpoints.file
