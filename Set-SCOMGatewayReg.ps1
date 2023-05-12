function Set-SCOMGatewayReg {

    [CmdletBinding()]

    param (

        [parameter(Mandatory=$false)][string]$CustMgmtGroupName = 'P01_160', #BEC
        [parameter(Mandatory=$false)][string[]]$ComputerName = $env:COMPUTERNAME,
        [parameter(Mandatory=$false)][string]$CorrectGatewaySrv = 'SF160SV00849.sw.corp.becnet.dk',
        [parameter(Mandatory=$false)][int64]$CorrectNetTimeOutMs = 4294967295

    )
    $Changed = $false    
    $SCOMMgmtGroup = "HKLM:\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Agent Management Groups\$CustMgmtGroupName\Parent Health Services\0"
    $SCOMMgmtGroup_NetworkName = (Get-ItemProperty -Path $SCOMMgmtGroup -Name NetworkName).NetworkName
    $SCOMMgmtGroup_AuthName = (Get-ItemProperty -Path $SCOMMgmtGroup -Name AuthenticationName).AuthenticationName
    $SCOMMgmtGroup_TimeOut = (Get-ItemProperty -Path $SCOMMgmtGroup -Name NetworkTimeoutMilliseconds).NetworkTimeoutMilliseconds

    if($SCOMMgmtGroup_NetworkName -ne $CorrectGatewaySrv){
    
        $null = Set-ItemProperty -Path $SCOMMgmtGroup -Name NetworkName -Value $CorrectGatewaySrv #-Confirm
        $Changed = $true
    }

    if($SCOMMgmtGroup_AuthName -ne $CorrectGatewaySrv){
    
        $null = Set-ItemProperty -Path $SCOMMgmtGroup -Name AuthenticationName -Value $CorrectGatewaySrv #-Confirm
        $Changed = $true
    }

    if($SCOMMgmtGroup_TimeOut -ne $CorrectNetTimeOutMs){
    
        $null = Set-ItemProperty -Path $SCOMMgmtGroup -Name NetworkTimeoutMilliseconds -Value $CorrectNetTimeOutMs #-Confirm
        $Changed = $true
    }

    else {
    
        Write-Host "$Env:ComputerName - Config is correct:" -ForegroundColor Green
        $(Get-ItemProperty -path $SCOMMgmtGroup)

    }

    if($Changed){
        $SCOMMgmtGroup = "HKLM:\SOFTWARE\Microsoft\Microsoft Operations Manager\3.0\Agent Management Groups\$CustMgmtGroupName\Parent Health Services\0"
        Get-Service HealthService | Restart-Service -Force -Verbose
        Write-Host "$Env:ComputerName - Config is changed:" -ForegroundColor Yellow
        $(Get-ItemProperty -path $SCOMMgmtGroup)
    }    

}

#$servers = "sf160ps01009.sw.corp.becnet.dk","sf160ps01010.sw.corp.becnet.dk","sf160ps01011.sw.corp.becnet.dk","sf160ps01012.sw.corp.becnet.dk"

#Invoke-Command -ComputerName $servers -ScriptBlock ${function:Set-SCOMGatewayReg}