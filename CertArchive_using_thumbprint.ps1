$list = get-content "C:\temp\list.txt" | select-string -Pattern "SystemCenterCentral.Utilities.Certificates.CertificateAboutToExpire.Monitor" | select-string -Pattern "bec.dk"
[array]$list_formatted = $list -replace "(.*PROBLEM.-.)|(\/S.*Monitor)|(\-P[0-9].is.*)",""

$success = 0
$failure = 0
$warning = 0

Write-Output "`nChecking servers in $env:USERDNSDOMAIN domain:"

foreach ($item in $list_formatted) 
    {
        $server = ($item -split '\s')[0]
        $cert_thumbprint = ($item -split '\s')[1]

            try
                {
                    Invoke-Command -ComputerName $server -ErrorAction Stop -WarningAction Stop -ScriptBlock {
                        
                        $personalStore = New-Object System.Security.Cryptography.X509Certificates.X509Store(“\\$using:server\My”,”LocalMachine”)
                        $personalStore.Open('ReadWrite, IncludeArchived')
                        $cert = $personalStore.Certificates | Where-Object {$_.Thumbprint -eq $using:cert_thumbprint}
                        
                        if(($cert.Archived -eq $false) -AND ($cert.NotAfter -lt (Get-Date))){
                            $cert.Archived=$true
                            Write-Host "$($using:server): Cert $($Cert.Subject), Thumbprint: $($Cert.Thumbprint) has been archived." -ForegroundColor Green
                        }

                        elseif($Cert.Archived -eq $true){
                            Write-Host "$($using:server): Cert $($Cert.Subject), Thumbprint: $($Cert.Thumbprint) is already archived." -ForegroundColor Yellow
                        }
                    }
                            $success++
                }
            catch 
                {
                    if (($error[0] | select-string -SimpleMatch "Access is denied")) 
                        {
                            Write-Host "$($server): Access denied!" -ForegroundColor DarkYellow
                            $warning++
                        }
                    else 
                        {
                            Write-Host "$($server): is DOWN/cant connect" -ForegroundColor Red
                            $failure++
                        }
                }
                
    }

    Write-Host "`n"
    Write-Host "Number of certs checked: $($list_formatted.Count)"
    
    Write-Host "Succesful ones: "$success
    Write-Host "Failed ones: "$failure
    Write-Host "Access denied: "$warning

    Pause