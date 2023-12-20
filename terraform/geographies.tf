locals {
# Public inbound connections from Azure DevOps originate from these ranges
# https://learn.microsoft.com/azure/devops/organizations/security/allow-list-ip-url?view=azure-devops&tabs=IP-V4#inbound-connections
  geographies                  = {
    australia                  = [
      "20.37.194.0/24",        # Australia East
      "20.42.226.0/24",        # Australia South East
    ]
    asiapacific                = [
      "20.195.68.0/24",        # Southeast Asia
    ]
    brazil                     = [
      "191.235.226.0/24",      # Brazil South
    ]
    canada                     = [
      "52.228.82.0/24",        # Central Canada
    ]
    europe                     = [
      "40.74.28.0/23",         # West Europe
      "20.166.41.0/24",        # North Europe
    ]
    india                      = [
      "20.41.194.0/24",        # South India
      "20.204.197.192/26",     # Central India
    ]
    uk                         = [
      "51.104.26.0/24",        # UK South
    ]    
    us                         = [
      "20.37.158.0/23",        # Central US
      "52.150.138.0/24",       # West Central US
      "40.80.187.0/24",        # North Central US
      "40.119.10.0/24",        # South Central US
      "20.42.5.0/24",          # East US
      "20.41.6.0/23",          # East 2 US
      "40.80.187.0/24",        # North US
      "40.119.10.0/24",        # South US
      "40.82.252.0/24",        # West US
      "20.42.134.0/23",        # West US 2
      "20.125.155.0/24",       # West US 3
    ]
    expressroute               = [
      # ExpressRoute connections
      # https://learn.microsoft.com/azure/devops/organizations/security/allow-list-ip-url?view=azure-devops&tabs=IP-V4#azure-devops-expressroute-connections
      "13.107.6.175/32",
      "13.107.6.176/32",
      "13.107.6.183/32",
      "13.107.9.175/32",
      "13.107.9.176/32",
      "13.107.9.183/32",
      "13.107.42.18/32",
      "13.107.42.19/32",
      "13.107.42.20/32",
      "13.107.43.18/32",
      "13.107.43.19/32",
      "13.107.43.20/32",
    ]  
  }
}