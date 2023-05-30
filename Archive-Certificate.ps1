function Archive-Certificate{

    [CmdLetBinding(DefaultParameterSetName='BySerialNumber')]
    
    param(    
        [parameter(Mandatory=$false,ParameterSetName='BySerialNumber')][string]$SerialNumber,
        [parameter(Mandatory=$false,ParameterSetName='ByThumbPrint')][string]$ThumbPrint,
        [Parameter(Mandatory=$false)][string[]]$ComputerName = $env:COMPUTERNAME,
        [switch]$ListOnly
    )

    [int]$ProgressCounter = 1

        foreach($ComputerName1 in $ComputerName){

            $personalStore = New-Object System.Security.Cryptography.X509Certificates.X509Store(“\\$ComputerName1\My”,”LocalMachine”)
            $personalStore.Open('ReadWrite, IncludeArchived')
        
            if($ListOnly){
                $personalStore.Certificates | Select-Object Subject, SerialNumber, @{label='ValidTo';e={$_.NotAfter}}, FriendlyName, Archived `
                | Sort-Object -Property Archived | Format-Table -Wrap -AutoSize
                break
            }

            if($SerialNumber){
            
                $FoundCertbySerial = $personalStore.Certificates | Where-Object {$_.SerialNumber -eq $SerialNumber}
                    if($FoundCertbySerial.count){
                        foreach($FoundCertbySerial1 in $FoundCertbySerial){
                            if($FoundCertbySerial1.Archived -eq $false){
                            $FoundCertbySerial1.Archived = $true
                            Write-Host "Cert $($FoundCertbySerial1.Subject), SN: $($FoundCertbySerial1.SerialNumber) on $Computername1 has been archived." -ForegroundColor Green
                            }
                            elseif($FoundCertbySerial1.Archived -eq $true){
                                Write-Host "Cert $($FoundCertbySerial1.Subject), SN: $($FoundCertbySerial1.SerialNumber) on $Computername1 is already archived." -ForegroundColor Yellow                
                            }
                        }
                    }
                    Else{Write-Host "Cert SN: $SerialNumber on $Computername1 does not exist." -ForegroundColor Red}
            }
            elseif($ThumbPrint){
                
                $FoundCertbyThumb = $personalStore.Certificates | Where-Object {$_.Thumbprint -eq $ThumbPrint}
                    if($FoundCertbyThumb.count){
                        foreach($FoundCertbyThumb1 in $FoundCertbyThumb){
                            if($FoundCertbyThumb1.Archived -eq $false){
                            $FoundCertbyThumb1.Archived = $true
                            Write-Host "Cert $($FoundCertbyThumb1.Subject), Thumbprint: $($FoundCertbyThumb1.Thumbprint) on $Computername1 has been archived." -ForegroundColor Green
                            }
                            elseif($FoundCertbyThumb1.Archived -eq $true){
                                Write-Host "Cert $($FoundCertbyThumb1.Subject), Thumbprint: $($FoundCertbyThumb1.Thumbprint) on $Computername1 is already archived." -ForegroundColor Yellow                
                            }
                        }
                    }
                    Else{Write-Host "Cert ThumbPrint: $ThumbPrint on $Computername1 does not exist." -ForegroundColor Red}
            }
        } #end foreach ComputerName

        
    } #end Archive-Certificate

