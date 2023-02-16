function IsConnecting([string[]]$ComputerName = $env:COMPUTERNAME){

    try{Test-Connection -ComputerName $ComputerName -Count 1 -Quiet}
    catch{$Error[0].Exception.Message}

}


function Get-FreeSpace ([string[]]$DriveLetter,[switch]$AllDrives,[string[]]$ComputerName = $env:COMPUTERNAME){
    
    foreach($ComputerName1 in $ComputerName){

            try{
                if(IsConnecting -ComputerName $ComputerName1){

                    if($AllDrives){
                        $DriveLetter = (Get-WmiObject -ComputerName $ComputerName1 -Class win32_logicaldisk | Where-Object {$_.MediaType -notmatch '5|6'}).DeviceID
                    }
                        foreach($DriveLetter1 in $DriveLetter){

                            if($DriveLetter1 -match '^\\\\\?\\Vol'){
                                if(!($DriveLetter1 -match '\\$')){$DriveLetter1 += '\'}
                                $LogDiskDetails = Get-Volume -ObjectId $DriveLetter1 -CimSession $ComputerName1
                                if($LogDiskDetails){
                                    [Pscustomobject]@{
                                        ComputerName = $ComputerName1 ;
                                        Drive =$LogDiskDetails.UniqueId;
                                        VolumeName = $LogDiskDetails.FileSystemLabel ;
                                        SizeGB = [Math]::Round($LogDiskDetails.Size/1GB,3) ;
                                        FreeSpaceGB = [Math]::Round($LogDiskDetails.SizeRemaining/1GB,3) ;
                                        'FreeSpace%' =  [string]([Math]::Round(($LogDiskDetails.SizeRemaining/$LogDiskDetails.Size)*100,2)) + "%"
                                        Time = $(Get-date -format g)#$((get-date).GetDateTimeFormats()[26]); #for DK culture at least
                                    }
                                }
                                else {Write-Warning "Drive $DriveLetter1 is unavailable on $computername1"}                        
                            }
                            else{
                                if(!($DriveLetter1 -match '\:$')){$DriveLetter1 += ':'}
                                $LogDiskDetails = Get-WmiObject -ComputerName $ComputerName1 -Class win32_logicaldisk | Where-Object {$_.DeviceID -eq $DriveLetter1}
                                if($LogDiskDetails){
                                    [Pscustomobject]@{
                                        ComputerName = $ComputerName1 ;
                                        Drive =$LogDiskDetails.DeviceID ;
                                        VolumeName = $LogDiskDetails.VolumeName ;
                                        SizeGB = [Math]::Round($LogDiskDetails.Size/1GB,3) ;
                                        FreeSpaceGB = [Math]::Round($LogDiskDetails.Freespace/1GB,3) ;
                                        'FreeSpace%' =  [string]([Math]::Round(($LogDiskDetails.Freespace/$LogDiskDetails.Size)*100,2)) + "%"
                                        Time = $(Get-date -format g)#$((get-date).GetDateTimeFormats()[26]); #for DK culture at least
                                    }
                                }
                                else {Write-Warning "Drive $DriveLetter1 is unavailable on $computername1"}
                            }
                            
                        }
                }
                else{Write-Warning "Check $ComputerName1 connectivity"}
            }
            catch{$Error[0].Exception.Message}
    }
}
#Get-FreeSpace -AllDrives
#Get-FreeSpace -DriveLetter C:

Get-FreeSpace -DriveLetter C: