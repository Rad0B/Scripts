function Unarchive-Certificate{

    [CmdLetBinding(DefaultParameterSetName='BySerialNumber')]
    
    param(    
        [parameter(Mandatory=$false,ParameterSetName='BySerialNumber')][string]$SerialNumber,
        [parameter(Mandatory=$false,ParameterSetName='ByThumbPrint')][string]$ThumbPrint,
        [Parameter(Mandatory=$false)][string[]]$ComputerName = $env:COMPUTERNAME
    )

    [int]$ProgressCounter = 1

        foreach($ComputerName1 in $ComputerName){

            $personalStore = New-Object System.Security.Cryptography.X509Certificates.X509Store(“\\$ComputerName1\My”,”LocalMachine”)
            $personalStore.Open('ReadWrite, IncludeArchived')

            if($SerialNumber){
            
                $FoundCertbySerial = $personalStore.Certificates | Where-Object {$_.SerialNumber -eq $SerialNumber}
                    if($FoundCertbySerial.count){
                        foreach($FoundCertbySerial1 in $FoundCertbySerial){
                            if($FoundCertbySerial1.Archived -eq $true){
                            $FoundCertbySerial1.Archived = $false
                            Write-Host "Unarchived: Cert $($FoundCertbySerial1.Subject), SN: $($FoundCertbySerial1.SerialNumber) on $Computername1." -ForegroundColor Green
                            }
                            elseif($FoundCertbySerial1.Archived -eq $false){
                                Write-Host "Cert $($FoundCertbySerial1.Subject), SN: $($FoundCertbySerial1.SerialNumber) on $Computername1 is NOT archived." -ForegroundColor Yellow                
                            }
                        }
                    }
                    Else{Write-Host "Cert SN: $SerialNumber on $Computername1 does not exist." -ForegroundColor Red}
            }
            elseif($ThumbPrint){
                
                $FoundCertbyThumb = $personalStore.Certificates | Where-Object {$_.Thumbprint -eq $ThumbPrint}
                    if($FoundCertbyThumb.count){
                        foreach($FoundCertbyThumb1 in $FoundCertbyThumb){
                            if($FoundCertbyThumb1.Archived -eq $true){
                            $FoundCertbyThumb1.Archived = $false
                            Write-Host "Unarchived: Cert $($FoundCertbyThumb1.Subject), Thumbprint: $($FoundCertbyThumb1.Thumbprint) on $Computername1." -ForegroundColor Green
                            }
                            elseif($FoundCertbyThumb1.Archived -eq $false){
                                Write-Host "Cert $($FoundCertbyThumb1.Subject), Thumbprint: $($FoundCertbyThumb1.Thumbprint) on $Computername1 is NOT archived." -ForegroundColor Yellow                
                            }
                        }
                    }
                    Else{Write-Host "Cert ThumbPrint: $ThumbPrint on $Computername1 does not exist." -ForegroundColor Red}
            }
        } #end foreach ComputerName        
    } #end Archive-Certificate