




function CopyFilesToLocalDisk{

    param($pathtolocaldisk)

    Copy-item -Path $pathtolocaldisk


}

$list = @"                         
SF110SV8017600.bdbdmz.dk      
sf110sv8017700.bdbdmz.dk      
SF110SV8017800.bdbdmz.dk      
SF110SV8017900.bdbdmz.dk      
SF110SV8018000.bdbdmz.dk      
SF110SV8018100.bdbdmz.dk      
sf110sv8018200.bdbdmz.dk      
SF110SV8018300.bdbnet.dk      
SF110SV9000100.bdunet.dk      
sf110sv9001000.bdunet.dk      
sf110sv9001200.bdunet.dk      
SF110SV9002100.bdunet.dk      
SF110SV9002200.bdunet.dk      
SF110SV9002300.bdunet.dk      
SF110SV9003500.bdunet.dk      
SF110SV9003600.bdunet.dk      
SF110SV9003700.bdunet.dk      
SF110SV9003800.bdunet.dk      
SF110SV9003900.bdunet.dk      
SF110SV9004000.bdunet.dk      
SF110SV9004100.bdunet.dk      
sf110sv9004200.bdunet.dk      
sf110sv9006600.bdunet.dk      
SF110SV9006700.bdunet.dk      
sf110sv9008400.bdunet.dk      
SF110SV9008700.bdunet.dk      
sf110sv9008900.bdunet.dk      
SF110SV9014200.bdunet.dk      
sf110sv9014600.bdunet.dk      
SF110SV9014700.bdunet.dk      
sf110sv9014800.bdunet.dk      
sf110sv9014900.bdunet.dk      
SF110SV9015000.bdunet.dk      
SF110SV9015100.bdunet.dk      
SF110SV9015200.bdunet.dk      
SF110SV9015300.bdunet.dk      
sf110sv9015400.bdunet.dk      
sf110sv9015600.bdunet.dk      
SF110SV9015700.bdunet.dk      
SF110SV9015900.bdunet.dk      
sf110sv9016000.bdunet.dk      
SF110SV9016900.bdunet.dk      
SF110SV9017000.bdunet.dk      
SF201SV0001700.d102p.bdpnet.dk
SF201SV0001800.d102p.bdpnet.dk
SF201SV0002100.d102p.bdpnet.dk
SF201SV7001010.d102p.bdpnet.dk
SF201SV7001214.d102p.bdpnet.dk
SF201SV7001215.d102p.bdpnet.dk
SF201SV7001217.d102p.bdpnet.dk
"@ -split "\r\n"

function DomainCheck(){
    
    
    Write-Output "Domain: $env:USERDNSDOMAIN"
    $servers = $list | Where-Object {$_ -eq $env:USERDNSDOMAIN}


    return $servers | Out-Null
}

#foreach server i

Foreach($server in $servers){

    Copy-Item -Path "\\tsclient\y\01Migrering" -destination "\\$server\c$\ud-sys"
    Invoke-Command -ComputerName $server -ScriptBlock{

        try {
            & "C:\ud-sys\01Migrering\TSMMove.cmd" | out-file -Path "C:\ud-sys\01Migrering\$($env:computername)_tsmbackup.log"
            sleep 5
        }
        catch { $error
            
        }
        

    }

}

Copy-Item 


Copy-item -Path 

$counter = 0

#$export = 'W:\My Documents\activation issues\source3.csv'

#Write-Host 'Importing CI extended database... ' -NoNewline
$uri = "http://ciextended.corp.jndata.net/api/ciapi"
$CIE = Invoke-RestMethod -Uri $uri
#Write-Host 'DONE' -ForegroundColor Green

$list = get-content 'W:\My Documents\activation issues\source.txt'

$serverlisttocheck = @"
SF110SV8017600
SF110SV8017700
SF110SV8017800
SF110SV8017900
SF110SV8018000
SF110SV8018100
SF110SV8018200
SF110SV8018300
SF110SV9000100
SF110SV9001000
SF110SV9001200
SF110SV9002100
SF110SV9002200
SF110SV9002300
SF110SV9003500
SF110SV9003600
SF110SV9003700
SF110SV9003800
SF110SV9003900
SF110SV9004000
SF110SV9004100
SF110SV9004200
SF110SV9006600
SF110SV9006700
SF110SV9008400
SF110SV9008700
SF110SV9008900
SF110SV9014200
SF110SV9014600
SF110SV9014700
SF110SV9014800
SF110SV9014900
SF110SV9015000
SF110SV9015100
SF110SV9015200
SF110SV9015300
SF110SV9015400
SF110SV9015600
SF110SV9015700
SF110SV9015900
SF110SV9016000
SF110SV9016900
SF110SV9017000
SF201SV0001700
SF201SV0001800
SF201SV0002100
SF201SV7001010
SF201SV7001214
SF201SV7001215
SF201SV7001217
"@ -split "\r\n"


$Results=@()
foreach ($server_host in $serverlisttocheck)
{
    $counter++
    #Write-Host "Processing $ip..." -NoNewline
    
            
        
        $cie | Where-Object {$_.Hostname -eq $server_host} | % {
            Write-Host "Processing $ip..." -NoNewline

        $TableRow = [PSCustomObject]@{
                IP = $_.IP;
                Hostname =  $_.Hostname;
                Domain = $_.Domain;           
                Customer = $_.Customer;
                FQDN = $_.fqdn;
                OS = $_.OS;
                Type = $_.Type;
                IPCMDBStatus = $_.IPCMDBStatus;
                Description = $_.Description;
                BASystem = $_.BASystem;
                Application = $_.BASystem.Owner
                ApplicationName = $_.BASystem.Name
                ApplicationParent = $_.BASystem.Parent
                ServiceOwner = $_.ServiceOwner
            }
            $Results += $TableRow
            Write-Host " OK" -ForegroundColor green
           # Write-progress -activity 'Busy busy busy' -CurrentOperation $ip -PercentComplete (($counter / $list.count) * 100)
        }

        #$Results += $TableRow #| Export-Csv $export -Append
        #Write-Host " OK" -ForegroundColor green
       # Write-progress -activity 'Busy busy busy' -CurrentOperation $ip -PercentComplete (($counter / $list.count) * 100)
}

#Write-Host `n "Processing CSV... " -NoNewline
#(Get-Content $export) | select -Skip 1 | Set-Content $export 

Write-Host 'DONE' -ForegroundColor Green

#$Results | export-csv output_01.csv -NoTypeInformation