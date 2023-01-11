#$list = read-Host -Prompt "Enter absolute path to file"

Begin{

    $lista = cat ("C:\Users\$($env:username)\Desktop\list.txt") | % {$_.ToString().TrimEnd()}
    #$output_dir = "$home\desktop\Results_$((get-date).tostring("yyyyMMdd_HHmm")).txt"
    $ErrorActionPreference = 'Stop'
    $ErroringList = @()
    
    #Write-output "COMPUTERNAME;FQDN;DOMAINNAME;OSVERSION;LASTBOOTUP;LASTSUCCESFULBOOT;APPLICATIONS;PATCHES" > $output_dir
    
    }
    
    Process{
    
    
    #Invoke-AsWorkflow -PSComputerName $lista -CommandName Get-OSInfoExtended
    
    Workflow Get-OSInfoExtendedOnMany {
    
        param (
        
            [string[]]$Serverlist
        
        )
    
    
        InlineScript{
    
            Write-Host "Checking $($using:serverlist.count) servers..."
    
            try{
    
                Invoke-Command -ComputerName $using:Serverlist -ScriptBlock{
    
                        $domainname = (gcim -classname Win32_ComputerSystem).domain
                        $fqdn = $env:computername +'.'+ (gcim -classname Win32_ComputerSystem).domain
                        $allproducts = gcim -ClassName Win32_Product
                        $osversion = (gcim -classname Win32_OperatingSystem).Caption
                        $appversion = ($allproducts | where {($_.vendor -eq 'McAfee, LLC.' -or $_.vendor -eq 'Carbon Black, Inc' -or $_.vendor -eq 'VMware, Inc.')} | select Name, Version, InstallDate | sort installedon | Format-Table -HideTableHeaders | Out-String ) -replace "Package ",'' -replace ' was.*','' | foreach {$_ -replace '\n',',' -replace "\W{2,4}","" -replace "\s{1,100}","-" }
                        $lastboot = (gcim -classname Win32_OperatingSystem).LastBootUpTime
                        $patches = (Get-WinEvent -FilterHashtable @{logname = 'setup'; id = 2} | where TimeCreated -ge (get-date).AddDays(-7) | select TimeCreated, Message | Format-Table -HideTableHeaders | Out-String ) -replace "Package ",'' -replace ' was.*','' | foreach {$_ -replace '\n',',' -replace "\W{2,4}","" -replace "\s{1,100}","-" }
                        $lastrestart = (Get-EventLog -LogName 'System' | where {$_.EventID -eq '1074' -and $_.Message -like '*restart*'} | where TimeGenerated -ge (get-date).AddDays(-7)).TimeGenerated
                        Write-output "$env:computername;$fqdn;$domainname;$osversion;$lastboot;$lastrestart;$appversion;$patches"
    
                         #$command >> $output_dir
    
                }
            }
            catch{
    
                $ErroringList += [PSCustomObject]@{
                ErrorServer = $Error.TargetObject
                ErrorMessage = $Error.Exception.Message
                }
            }
            finally{
    
                if($ErroringList -ne $null){Write-Host "Server erroring:" ; $ErroringList <#| ft -AutoSize -Wrap#>}
    
            }
    
    
        }
    }
    
    Get-OSInfoExtendedOnMany -Serverlist $lista
    
    }
    
    End{
    
        $ErrorActionPreference = 'Continue'
    
    
    }
     