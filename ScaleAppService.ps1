<#
    .DESCRIPTION
       Scaling app service plan using RM service and scheduler in Azure.
       Updated with logic to consider the order of scaling (depending UP or DOWN).
    .NOTES
        AUTHOR: Son Phan
        LASTEDIT: 5/18/2017
#>


[CmdletBinding()]
Param(

	[Parameter(Mandatory = $true)]
	[String] $ResourceGroupName='FortressDEV',

	[Parameter(Mandatory = $true)]
	[String] $AppServicePlanName='fortress-dev',

	[Parameter(Mandatory = $true)]
    [ValidateSet("Premium","Standard","Basic")]
	[String] $Tier='Standard',

	[Parameter(Mandatory = $true)]
	[ValidateSet("Small","Medium","Large")]
    [String] $ScaleLevel,

	[Parameter(Mandatory = $true)]
    [ValidateRange(1,10)]
	[Int] $InstanceCount=1,	

	[Parameter(Mandatory = $true)]
	[Boolean] $RunWeekend = $false,

	[Parameter(Mandatory = $false)]
    [ValidateSet("UP","DOWN")]
	[String] $ScalingDirection

)

# Setting default to Valid (before checking for weekend run)
$validRun = $true

# Skipping weekends
$dayNow = (Get-Date)
$dayPST = $dayNow.ToUniversalTime().AddHours(-7)
"Current time in PST: [$dayPST]"
$day = $dayPST.DayOfWeek
"Running for [$day]"


#if(($day -eq 'Saturday' -or $day -eq 'Monday') -and $RunWeekend -eq $false){
if(($day -eq 'Saturday' -or $day -eq 'Sunday') -and $RunWeekend -eq $false){
	"PRE: Job will not run on Weekends, EXIT!"
	$validRun = $false
}else{
	"PRE: Weekend check passed, continue to run."	
}

# VALID VALUES & CONDITION, continue to execute.
if($validRun){
	$connectionName = "AzureRunAsConnection"
	try
	{
	    # Get the connection "AzureRunAsConnection "
	    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

	    "1. Logging in to Azure..."
	    $result = Add-AzureRmAccount `
	        -ServicePrincipal `
	        -TenantId $servicePrincipalConnection.TenantId `
	        -ApplicationId $servicePrincipalConnection.ApplicationId `
	        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
	}
	catch {
	    if (!$servicePrincipalConnection)
	    {
	        $ErrorMessage = "Connection $connectionName not found."
	        throw $ErrorMessage
	    } else{
	        Write-Error -Message $_.Exception
	        throw $_.Exception
	    }
	}

	#Get all ARM resources from all resource groups
	try{		
        #Making sure the order of scaling will not cause resource conflict (since scaling down can potentially not have enough instances)
        if($ScalingDirection -eq 'DOWN'){
        "2. Scaling down, scaling in to Instances[$InstanceCount]..."
        Set-AzureRmAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -NumberofWorkers $InstanceCount	
        "3. Scaling down, updating Tier[$Tier], Level[$ScaleLevel]..." 
        Set-AzureRmAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -Tier $Tier -WorkerSize $ScaleLevel
        "4. Successfully scaled AppServicePlan[$AppServicePlanName]!"

        }else{
        #Making sure scaling up Tier first to maximize instance available for scaling out
        "2. Scaling up, updating Tier[$Tier], Level[$ScaleLevel]..." 
        Set-AzureRmAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -Tier $Tier -WorkerSize $ScaleLevel        
        "3. Scaling up, scaling in to Instances[$InstanceCount]..."
        Set-AzureRmAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -NumberofWorkers $InstanceCount	
        "4. Successfully scaled AppServicePlan[$AppServicePlanName]!"
        }

    }catch{
		 Write-Error -Message $_.Exception
	     throw $_.Exception
	}		
}  
