
Param
(
  [Parameter (Mandatory= $true)]
  [String] $SynapseServerName = "FILL ME IN",
  [Parameter (Mandatory= $true)]
  [String] $SynapseDatabaseName = "FILL ME IN",
  [Parameter (Mandatory= $true)]
  [String]  $SynapseResourceGroup = "FILL ME IN",
  # Values Suspend or Resume
  [Parameter (Mandatory= $true)]
  [ValidateSet('Suspend','Resume',IgnoreCase)]
  [String]  $SynapseAction = "FILL ME IN"
)
# Start watch to measure E2E time duration
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()


# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave –Scope Process

$connection = Get-AutomationConnection -Name AzureRunAsConnection

# Wrap authentication in retry logic for transient network failures
$logonAttempt = 0
while(!($connectionResult) -and ($logonAttempt -le 2))
{
    $LogonAttempt++
    # Logging in to Azure...
    $connectionResult = Connect-AzAccount `
                            -ServicePrincipal `
                            -Tenant $connection.TenantID `
                            -ApplicationId $connection.ApplicationID `
                            -CertificateThumbprint $connection.CertificateThumbprint

    Start-Sleep -Seconds 30
}

$AzureContext = Get-AzSubscription -SubscriptionId $connection.SubscriptionID

$database = Get-AzSqlDatabase –ResourceGroupName $SynapseResourceGroup –ServerName $SynapseServerName –DatabaseName $SynapseDatabaseName

IF ($SynapseAction -like 'Resume') 
{
    $resultDatabase = $database | Resume-AzSqlDatabase
} 
ELSEIF 
{
    $resultDatabase = $database | Suspend-AzSqlDatabase
}


Write-Output " "
Write-Output "========================================================================================================================"
Write-Output "                                           Completed Successfully"
Write-Output "                                              Total Duration"
Write-Output "                                            "$stopwatch.Elapsed
Write-Output ($resultDatabase)
Write-Output "========================================================================================================================"