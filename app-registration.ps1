function GetAuthToken($resource) {
    $script:context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
    $Token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, $resource).AccessToken
    $authHeader = @{
        'Content-Type' = 'application/json'
        Authorization  = 'Bearer ' + $Token
    }
    return $authHeader
}

Connect-AzAccount
$script:AzureUrl = "https://management.azure.com/"
$script:mainUrl = "https://graph.microsoft.com/beta"
$script:token = GetAuthToken -resource 'https://graph.microsoft.com'
$AppDisplayName = "TerraForm Deployment"

$newAppUrl = $script:mainUrl + "/applications"
$body = @{
    displayName = $AppDisplayName
}
$postBody = $body | ConvertTo-Json
$newApp = Invoke-RestMethod -Uri $newAppUrl -Method POST -Body $postBody -Headers $script:token
$secretAppUrl = $script:mainUrl + "/applications/" + $newApp.id + "/addPassword"
$body = @{
    passwordCredential = @{
        displayName = 'AppPassword'
    }
}
$postBody = $body | ConvertTo-Json
$appPass = Invoke-RestMethod -Uri $secretAppUrl -Method POST -Body $postBody -Headers $script:token

$spUrl = "$($script:mainUrl)/servicePrincipals"
$body = @{
    appId = $newApp.appId
}
$postBody = $body | ConvertTo-Json
$servicePrincipal = Invoke-RestMethod -Uri $spUrl -Method POST -Body $postBody -Headers $script:token

$script:token = GetAuthToken -resource $script:AzureUrl
$guid = (new-guid).guid
$roleDefinitionId = "/subscriptions/" + $script:context.Subscription.Id + "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
$url = $script:AzureUrl + "subscriptions/" + $script:context.Subscription.Id + "/providers/Microsoft.Authorization/roleAssignments/$($guid)?api-version=2018-07-01"
$body = @{
    properties = @{
        roleDefinitionId = $roleDefinitionId
        principalId      = $servicePrincipal.id
    }
}
$jsonBody = $body | ConvertTo-Json -Depth 6
Invoke-RestMethod -Uri $url -Method PUT -Body $jsonBody -headers $script:token
