Clear-Host

$servers = @"
localhost
"@ -split "\r\n" | Select-Object -Unique

$Logs=@()
$NoOfLastReboots = 5
$timestart = [datetime]'05/12/2023 00:00:00'
$timeend = [datetime]'05/12/2023 20:00:00'
$RebootTimes = [datetime]'05/01/2023 00:00:00'

foreach($s1 in $servers){

    $ErrorActionPreference = "Stop"

    try{

        Write-Host "Checking server $s1" -ForegroundColor Magenta
        $Logs += Invoke-Command -ComputerName $s1 -ScriptBlock {

           ## Reboot times

           $RebootsPerServer = Get-WinEvent -LogName System | ? providername -EQ "User32" | ? timecreated -ge $using:RebootTimes
            if($RebootsPerServer.count -ge 1){
               $RebootsPerServer | % {
                    [PSCustomObject]@{
                        Type = "Reboots"
                        Server = $env:COMPUTERNAME
                        TimeCreated = $_.TimeCreated
                        ProviderName = $_.ProviderName
                        LogsLevel = $_.LevelDisplayName
                        Message = $_.Message
                    }
               }
            }
            else{
                [PSCustomObject]@{
                    Type = "Reboots"
                    Server = $env:COMPUTERNAME
                    TimeCreated = $null
                    ProviderName = $null
                    LogsLevel = $null
                    Message = "No Reboots during month: $($using:RebootTimes.Date.Month)/$($using:RebootTimes.Date.Year)" 
                }
            }

            ### Patching events

            $PatchingPerServer = Get-WinEvent -LogName Setup | ? TimeCreated -ge $using:RebootTimes | ? Message -Match "successfully changed to the Installed state"
            if($PatchingPerServer.count -ge 1){
               $PatchingPerServer | % {
                    [PSCustomObject]@{
                        Type = "Patching"
                        Server = $env:COMPUTERNAME
                        TimeCreated = $_.TimeCreated
                        ProviderName = $_.ProviderName
                        LogsLevel = $_.LevelDisplayName
                        Message = $_.Message
                    }
               }
            }
            else{
                [PSCustomObject]@{
                    Type = "Patching"
                    Server = $env:COMPUTERNAME
                    TimeCreated = $nullvcx
                    ProviderName = $null
                    LogsLevel = $null
                    Message = "No patching KBs installed during month: $($using:RebootTimes.Date.Month)/$($using:RebootTimes.Date.Year)"
                }
            }

            ### Installation.log events
            #Write-Host "Contents of Installation.log around $(($using:timestart).ToShortDateString())"
            
            if(cat C:\logs\installation.log | sls "\.05\.2023"){
                
                $InstallationLogCnt = cat C:\logs\installation.log | sls "\.05\.2023" | sls "Packagename"
                $InstallationLogCnt | % {
                    #datetime conversion
                    $TimeCreatedConvertSplit = ($_.ToString().Substring(0,19)).Split(".")
                    $TimeCreatedReorder = '{0}.{1}.{2} {3}' -f $TimeCreatedConvertSplit[1],$TimeCreatedConvertSplit[0],$TimeCreatedConvertSplit[2],$TimeCreatedConvertSplit[3]

                    [PSCustomObject]@{
                        Type = "PackagesDeploy"
                        Server = $env:COMPUTERNAME
                        TimeCreated = [datetime]$TimeCreatedReorder
                        ProviderName = $_.ProviderName
                        LogsLevel = $_.LevelDisplayName
                        Message = $_.ToString().Substring(20,$_.ToString().Length - 20) -replace '\s{2,}',' '
                    }
                }
            }
            else{
                    [PSCustomObject]@{
                        Type = "PackagesDeploy"
                        Server = $env:COMPUTERNAME
                        TimeCreated = $null
                        ProviderName = $null
                        LogsLevel = $null
                        Message = "No contents during month: $($using:RebootTimes.Date.Month)/$($using:RebootTimes.Date.Year)" 
                    }
            }

            ####
            #   Checking error,critical, warning logs from System
            ####

            ### Installation.log events
            #Write-Host "Contents of Installation.log around $(($using:timestart).ToShortDateString())"
            
            $SystemErrorLogs = Get-WinEvent -FilterHashtable @{LogName="System";StartTime=$using:timestart;EndTime=$using:timeend}`
            | Where-Object LevelDisplayName -ne "information"`
            | Sort-Object -Property TimeCreated -Descending
            
            if($SystemErrorLogs.count -ge 1){
               $SystemErrorLogs | % {
                    [PSCustomObject]@{
                        Type = "SystemLogs"
                        Server = $env:COMPUTERNAME
                        TimeCreated = $_.TimeCreated
                        ProviderName = $_.ProviderName
                        LogsLevel = $_.LevelDisplayName
                        Message = $_.Message
                    }
               }
            }
            else{
                [PSCustomObject]@{
                    Type = "SystemLogs"
                    Server = $env:COMPUTERNAME
                    TimeCreated = $null
                    ProviderName = $null
                    LogsLevel = $null
                    Message = "No system error/warning logs during time span: $using:timestart - $using:timeend" 
                }
            }

            #### All KBs installed

        $AllKBsPerServer = Get-WinEvent -LogName Setup | ? TimeCreated -ge ([datetime]'01/01/2023 00:00:00') | ? Message -Match "successfully changed to the Installed state"
            if($AllKBsPerServer.count -ge 1){
               $AllKBsPerServer | % {
                    [PSCustomObject]@{
                        Type = "PatchingState"
                        Server = $env:COMPUTERNAME
                        TimeCreated = $_.TimeCreated
                        ProviderName = ($_.Message).TrimStart("Package ").TrimEnd(" was successfully changed to the Installed state.")
                        LogsLevel = $_.LevelDisplayName
                        Message = $_.Message
                    }
               }
            }
            else{
                [PSCustomObject]@{
                        Type = "PatchingState"
                        Server = $env:COMPUTERNAME
                        TimeCreated = $null
                        ProviderName = $null
                        LogsLevel = $null
                        Message = "KBs not found"
                    }
            }

            #### Proxy settings netsh winhttp show proxy

            $ProxyPerServer =  (netsh winhttp show proxy) -split "\r"
            $ProxyPerServerParsed = $null
            for($i=0;$i -le $ProxyPerServer.Length;$i++){[string]$ProxyPerServerParsed += $ProxyPerServer[$i]}
                    [PSCustomObject]@{
                        Type = "Proxy(global)"
                        Server = $env:COMPUTERNAME
                        TimeCreated = $null
                        ProviderName = $null
                        LogsLevel = $null
                        Message = $ProxyPerServerParsed
                    } 
        }#end invoke
    
    }
    catch{       
        $Error[0].Exception.Message
    }
}

return $Logs