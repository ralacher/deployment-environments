param appName string
param location string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appName
  location: location
  sku: {
    name: 'S2'
    tier: 'Standard'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: appName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource privateEndpointStorage 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: '${appName}-privateEndpoint'
  location: location
  properties: {
    subnet: {
      id: '/subscriptions/your-subscription-id/resourceGroups/your-resource-group/providers/Microsoft.Network/virtualNetworks/your-virtual-network-name/subnets/your-subnet-name'
    }
    privateLinkServiceConnections: [
      {
        name: appName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource staticWebApp 'Microsoft.Web/staticSites@2021-02-01' = {
  name: appName
  location: location
  properties: {
    privateEndpointConnections: [
      {
        name: appName
        properties: {
          privateEndpoint: {
            id: privateEndpointStorage.id
          }
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Private endpoint connection approved'
          }
        }
      }
    ]
  }
}

resource privateEndpointStaticWebApp 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: '${appName}-privateEndpoint'
  location: location
  properties: {
    subnet: {
      id: '/subscriptions/your-subscription-id/resourceGroups/your-resource-group/providers/Microsoft.Network/virtualNetworks/your-virtual-network-name/subnets/your-subnet-name'
    }
    privateLinkServiceConnections: [
      {
        name: appName
        properties: {
          privateLinkServiceId: staticWebApp.id
          groupIds: [
            'staticSite'
          ]
        }
      }
    ]
  }
}
