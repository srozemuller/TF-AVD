$script:token = GetAuthToken -resource 'https://graph.microsoft.com' 
$script:mainUrl = "https://graph.microsoft.com/beta"

function GetAuthToken($resource) {
    $context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
    $Token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, $resource).AccessToken
    $authHeader = @{
        'Content-Type' = 'application/json'
        Authorization  = 'Bearer ' + $Token
    }
    return $authHeader
}

function Get-Application {
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$appId
    )
    $url = $script:mainUrl+ "/applications?`$filter=appId eq '$($appId)'"
    $appInfo = (Invoke-RestMethod -Uri $url -Method GET -Headers $script:token).value
    return $appInfo
}

function Get-ServicePrincipal {
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$appId
    )
    $url = $script:mainUrl + "/servicePrincipals?`$filter=appId eq '$($appId)'"
    $servicePrincipalInfo = (Invoke-RestMethod -Uri $url -Method GET -Headers $script:token).value
    return $servicePrincipalInfo
}
function New-Application {
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AppDisplayName
    )
    $url = $script:mainUrl + "/applications"
    $body = @{
        displayName = $AppDisplayName
    }
    $postBody = $body | ConvertTo-Json
    $newApp = Invoke-RestMethod -Uri $url -Method POST -Body $postBody -Headers $script:token
    return $newApp
}

function New-ApplicationPassword {
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AppId
    )
    $url = $script:mainUrl + "/applications/"+ $AppId + "/addPassword"
    $body = @{
        passwordCredential = @{
            displayName = 'AppPassword'
        }
    }
    $postBody = $body | ConvertTo-Json
    $appPass = Invoke-RestMethod -Uri $url -Method POST -Body $postBody -Headers $script:token
    return $appPass
}

function Add-ApplicationPermissions {
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$appId,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object]$permissions

    )
    $url = $($script:mainUrl) + "/applications/" + $appId
    $body = @{
        requiredResourceAccess = @(
            $permissions
        )
    }
    $postBody = $body | ConvertTo-Json -Depth 5 
    $appPermissions = Invoke-RestMethod -Uri $url -Method PATCH -Body $postBody -Headers $script:token -ContentType "application/json"
    return $appPermissions
}

function New-SPFromApp {
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AppId
    )
    $url = "$($script:mainUrl)/servicePrincipals"
    $body = @{
        appId = $AppId
    }
    $postBody = $body | ConvertTo-Json
    $servicePrincipal = Invoke-RestMethod -Uri $url -Method POST -Body $postBody -Headers $script:token
    return $servicePrincipal
}

function Add-SPDelegatedPermissions {
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ServicePrincipalId
    )
    $url = $($script:mainUrl) + "/servicePrincipals/"+ $ServicePrincipalId +"/delegatedPermissionClassifications"
    $body = @{
        permissionId   = "3f73b7e5-80b4-4ca8-9a77-8811bb27eb70"
        permissionName = "User.Read"
    }
    $postBody = $body | ConvertTo-Json
    $spPermissions = Invoke-RestMethod -Uri $url -Method POST -Body $postBody -Headers $script:token
    return $spPermissions
}
function Consent-ApplicationPermissions {
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ServicePrincipalId,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceId,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Scope
    )
    $date = Get-Date
    $url = $($script:mainUrl) + "/oauth2PermissionGrants"
    $body = @{
        clientId    = $ServicePrincipalId
        consentType = "AllPrincipals"
        principalId = $null
        resourceId  = $ResourceId
        scope       = $Scope
        startTime   = $date
        expiryTime  = $date
    }
    $postBody = $body | ConvertTo-Json
    $appPermissions = Invoke-RestMethod -Uri $url -Method POST -Body $postBody -Headers $script:token
    return $appPermissions
}

function Assign-AppRole {
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ServicePrincipalId,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object]$appRoleId

    )
    $url = $($script:mainUrl) + "/servicePrincipals/" + $ServicePrincipalId + "/appRoleAssignments"
    $body = @{
        principalId = $ServicePrincipalId
        resourceId  = "3f73b7e5-80b4-4ca8-9a77-8811bb27eb70"
        appRoleId   = $appRoleId
    }
    $roles = Invoke-RestMethod -Uri $url -Method POST -Headers $script:token -Body $($body | ConvertTo-Json)
    return $roles
}

$permissions = @{
    resourceAppId  = "00000003-0000-0000-c000-000000000000"
    resourceAccess = @(
        @{
            id   = "4e46008b-f24c-477d-8fff-7bb4ec7aafe0"
            type = "Scope"
        }
    )
}

Connect-AzAccount
$script:AzureUrl = "https://management.azure.com/"
$script:mainUrl = "https://graph.microsoft.com/beta"
$script:token = GetAuthToken -resource 'https://graph.microsoft.com'
$AppDisplayName = "TerraForm Deployment"
$newApp = New-Application -AppDisplayName $AppDisplayName
Add-ApplicationPermissions -AppId $newApp.Id -permissions $permissions 
$newSp = New-SPFromApp -AppId $newApp.AppId 
Consent-ApplicationPermissions -ServicePrincipalId $newSp.id -ResourceId "3f73b7e5-80b4-4ca8-9a77-8811bb27eb70" -Scope "Group.ReadWrite.All"

# Add contributor role at subscription level
$script:token = GetAuthToken -resource $script:AzureUrl
$guid = (new-guid).guid
$contributorRoleId = "b24988ac-6180-42a0-ab88-20f7382dd24c"
$roleDefinitionId = "/subscriptions/" + $script:context.Subscription.Id + "/providers/Microsoft.Authorization/roleDefinitions/"+ $contributorRoleId
$url = $script:AzureUrl + "subscriptions/" + $script:context.Subscription.Id + "/providers/Microsoft.Authorization/roleAssignments/$($guid)?api-version=2018-07-01"
$body = @{
    properties = @{
        roleDefinitionId = $roleDefinitionId
        principalId      = $servicePrincipal.id
    }
}
$jsonBody = $body | ConvertTo-Json -Depth 6
Invoke-RestMethod -Uri $url -Method PUT -Body $jsonBody -headers $script:token

# Terraform environment variables are:
Write-Host "ARM_TENANT_ID: "$script:context.Tenant.Id
Write-Host "ARM_SUBSCRIPTION_ID: "$script:context.Subscription.Id
Write-Host "ARM_CLIENT_ID: "$newApp.id
Write-Host "ARM_CLIENT_SECRET: "$appPass.secretText