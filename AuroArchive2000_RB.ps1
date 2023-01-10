$list = get-content "C:\temp\scripts\list.txt" | select-string -Pattern "SystemCenterCentral.Utilities.Certificates.CertificateAboutToExpire.Monitor" | select-string -Pattern "bec.dk"
$list = $list -replace "(.*PROBLEM.-.)|(/.*)","" | sort | get-unique


$success = 0
$failure = 0
$warning = 0

Write-Host "Please provide credentials for the automata (will use current user for now)"
#$cred = Get-Credential $env:USERDOMAIN\$env:USERNAME

foreach ($server in $list) 
    {
        try 
            {
                Invoke-Command -ErrorAction Stop -WarningAction Stop <#-Credential $cred#> -ComputerName $server -ScriptBlock {
                        $personalStore = Get-Item cert:\LocalMachine\My 
                        $personalStore.Open('ReadWrite,IncludeArchived') 
                        $before = $personalStore.Certificates | Select Thumbprint, Subject, Archived, NotAfter | where-object Archived -eq $false | measure | % {$_.count}
                        #$personalStore.Certificates | Select NotAfter, Archived, Subject | sort NotAfter | ft -AutoSize
                        foreach ($cert in $personalStore.certificates |  where {$_.notAfter -lt (Get-Date)})  { $cert.Archived=$true }
                        $after= $personalStore.Certificates | Select Thumbprint, Subject, Archived, NotAfter | where-object Archived -eq $false | measure | % {$_.count}
                        $done = $before - $after
                        
                        
                        Write-Host "$env:COMPUTERNAME.$env:DOMAINDNS - $done certs where archived"
                   }
                        $success++
            }
        catch 
            {
                [string]$sers = $server
                $srv = ($sers.Split('.')[1]+"\"+$sers.Split('.')[0]).toupper()
                if (($error[0] | select-string -SimpleMatch "Access is denied")) 
                    {
                        Write-Host $srv "Access denied!" -ForegroundColor Yellow
                        $warning++
                    }
                else 
                    {
                        Write-Host $srv "is DOWN/cant connect" -ForegroundColor Red
                        $failure++
                    }
            }
              
    }

    Write-Host `n`n
    Write-Host "Number of servers checked: "$list.Count
    
    Write-Host "Succesful ones: "$success
    Write-Host "Failed ones: "$failure
    Write-Host "Access denied: "$warning

    pause
