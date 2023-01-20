function Get-ClusterInfo{
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false,ValueFromPipeline)]
        [string]$Cluster = $($env:COMPUTERNAME),
        [switch]$Detailed = $false # to check
    )      

    # use this server as testing environment -> sf100sv90532.jnmain50.corp.jndata.net
    #
    #disk sizes and locations - maybe a switch operator
    #cluster shares details 
    #last cluster events last 24h
            
    #Virtual Terminal escape sequences
    begin{
        $esc =[char]27
        $Green = 92
        $Red = 91
        $Yellow = 93

        $CurrentErrorPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
    }
    process{
            
        try{
                $Clustername = Get-Cluster -Name $Cluster
            }
        catch{Write-Warning $error[0].Exception.Message ; break}
            
            Write-Host "Info taken: $((Get-Date).Datetime) (via $env:COMPUTERNAME)" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Nodes" -ForegroundColor Cyan -NoNewline
            $ClusterNodes = $Clustername | Get-ClusterNode
            try{
                    $ClusterNodes | % {
                        [PSCustomObject]@{
                            Node = $_.NodeName
                            Cluster = $_.Cluster
                            State = $_.State
                            LastBootTime = $((get-ciminstance win32_operatingsystem -ComputerName $_.NodeName -ea Stop).Lastbootuptime)
                            ClusSvcLastStart = (Get-WinEvent -FilterHashtable @{Logname="System";ID=7036} -ComputerName $_.NodeName -ea Stop | ? Message -like "*Cluster Service service entered the running state*" | Select-Object -First 1).timeCreated
                            NodeIP = (Get-NetIPConfiguration -ComputerName $_.NodeName).ipv4address.ipv4address
                        }
                    } | Format-Table -AutoSize -Wrap
                }catch{
                "" ; Write-Warning $error[0].Exception.Message
                $ClusterNodes | ForEach-Object {
                    [PSCustomObject]@{
                        Node = $_.NodeName
                        Cluster = $_.Cluster
                        State = $_.State
                    }
                    } | Format-Table -AutoSize -Wrap
            }
            
            Write-Host "Resources / Groups" -ForegroundColor Cyan -NoNewline
            $ClusterResources = $Clustername | Get-ClusterResource | Sort-Object -Property Ownergroup
            $ClusterResources | ForEach-Object{
            if($Host.UI.SupportsVirtualTerminal -eq $true){
                $ResourceState = 
                if (($_.State -ne 'Online') -and ($_.OwnerGroup -match "Offline")){"$esc[${Yellow}m$($_.State)$esc[0m"}
                elseif(($_.State -ne 'Online') -and ($_.OwnerGroup -notmatch "Offline")){"$esc[${Red}m$($_.State)$esc[0m"}
                else {$_.State}
            }else {$ResourceState = $_.State}
                    [PSCustomObject]@{
                        ResourceName = $_.Name
                        State = $ResourceState #$_.State
                        OwnerGroup = $_.OwnerGroup
                        Ownernode = $_.Ownernode
                        ResourceType = $_.ResourceType
                    }
                } | Format-Table -AutoSize -Wrap
            
            Write-Host "Network" -ForegroundColor Cyan -NoNewline
            $ClusterNetwork = $Clustername | Get-ClusterNetwork
            $ClusterNetworkNICs = $Clustername | get-clusternetworkinterface
            $ClusterNetworkNICs | % {
                [PSCustomObject]@{         
                    AdapterName = $_.Name
                    IP = $_.Address
                    State = $_.State
                    AdapterType = $_.Adapter                  
                    Node = $_.Node
                    "ClusterNetwork : State" = "$($ClusterNetwork.Name) : $($ClusterNetwork.State)"
                }
            } | Format-Table -AutoSize -Wrap

            if($Detailed){

                $ClusterResourceDisks = $Clustername | Get-ClusterResource | ? resourcetype -EQ "Physical Disk"
                Write-Host "Disks ($($ClusterResourceDisks.Count))" -ForegroundColor Cyan -NoNewline
                $DiskInfo=@()
                if(!($ClusterResourceDisks.count)){
                    Write-Host ""
                    Write-Host "No cluster disks configured" -ForegroundColor Yellow 
                }
                else{
                    $ClusterResourceDisks | ForEach-Object {

                    $ClusterResourceDisk1 = $_
                    $MSClusterRes = Get-WmiObject MSCluster_Resource -Namespace root/mscluster -ComputerName $Clustername.Name  | ? { $_.ID -eq $ClusterResourceDisk1.ID}
                    $MSClusterDisk = Get-WmiObject -Namespace root/mscluster -Query "Associators of {$MSClusterRes} Where ResultClass=MSCluster_Disk" -ComputerName $Clustername.Name 
                    $MSClusterPartition = Get-WmiObject -Namespace root/mscluster -Query "Associators of {$MSClusterDisk} Where ResultClass=MSCluster_DiskPartition" -ComputerName $Clustername.Name

                    #HealthStatus info
                            if ($ClusterResourceDisk1.OwnerNode.Name -eq $env:COMPUTERNAME){
                                $Health = Get-Volume -Path "\\?\Volume{$($MSClusterPartition.VolumeGuid)}\"
                            } else {
                                $Health = Invoke-Command -ComputerName $($ClusterResourceDisk1.OwnerNode.Name) -ScriptBlock `
                                {Get-Volume -Path "\\?\Volume{$(($using:MSClusterPartition).VolumeGuid)}\"}
                            }
                        

                        $DiskInfo += [PSCustomObject]@{
                            Name = $ClusterResourceDisk1.Name;
                            ClusterRole = $ClusterResourceDisk1.OwnerGroup
                            'DriveLetter / GUID' = $MSClusterPartition.Path
                            'FreeSpace%' = "$([math]::Round(($MSClusterPartition.FreeSpace / $MSClusterPartition.TotalSize)*100,2))%"
                            #'FreeSpace%' = "Free: $($MSClusterPartition.FreeSpace) / Total Size: $($MSClusterPartition.TotalSize)"
                            HealthStatus = $Health.HealthStatus
                            OperationalStatus = $Health.OperationalStatus
                        }
                    }
                }

                $DiskInfo | Format-Table -AutoSize -Wrap

            }
    }
    end {
        $ErrorActionPreference = $CurrentErrorPreference
    }
}
            
Get-ClusterInfo -Detailed