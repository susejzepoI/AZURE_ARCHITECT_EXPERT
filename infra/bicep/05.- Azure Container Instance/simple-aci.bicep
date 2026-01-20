param image string
param acrLoginServer string
param acrUser string
param acrPassword string
param envAppEnvironment string

// JLopez-20260109: Documentation: https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/container-instance/container-group

resource myACI 'Microsoft.ContainerInstance/containerGroups@2025-09-01' = {
  name: 'myaci-${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  properties: {
    containers: [
      {
        name: 'mycontainer'
        properties: {
          image: image
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 2
            }
          }
          environmentVariables: [
            {name: 'APP_ENVIRONMENT', value: envAppEnvironment}
          ]
          ports: [
            {
              port: 8080
              protocol: 'TCP'
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    imageRegistryCredentials: [
      {
        server: acrLoginServer
        username: acrUser
        password: acrPassword
      }
    ]
    restartPolicy: 'Always'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: 8080
          protocol: 'TCP'
        }
      ]
    }
  }
}

output containerIP string = myACI.properties.ipAddress.ip
