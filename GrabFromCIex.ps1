# script to parse ip's from elastic to human readable host format. If run first time uncomment line 8 and 9.

$counter = 0

$export = 'W:\My Documents\activation issues\source3.csv'

#Write-Host 'Importing CI extended database... ' -NoNewline
$uri="http://ciextended.corp.jndata.net/api/ciapi"
$CIE = Invoke-RestMethod -Uri $uri
#Write-Host 'DONE' -ForegroundColor Green

#$list = get-content 'W:\My Documents\activation issues\source.txt'
$list = @"
SF600LX00107
SF600SV00013
SF600SV00755
SF600SV01050
SF600SV01212
NESI-JN-C1-02
SF600LX00079
SF600LX00111
SF600LX00112
SF600LX00117
SF600LX00123
SF600SV00547
SF600SV00921
SF600SV01006
SF600SV01007
SF600SV01663
SF600SV01664
SF600XC00047
SF600XC00048
SF600XC00049
"@ -split "\n" | % {$_.trim()}
$Results=@()
foreach ($s1 in $list) 
{
    $counter++
    #Write-Host "Processing $ip..." -NoNewline
    
            
        
        $cie | Where-Object {$_.hostname -eq $s1} | % {
            Write-Host "Processing $s1..." -NoNewline

        $TableRow = [PSCustomObject]@{
                IP = $_.ip;
                Hostname =  $_.Hostname;
                Domain = $_.Domain;           
                Customer = $_.Customer;
                FQDN = $_.fqdn;
                OS = $_.OS;
                HardwareType = $_.HardwareType
                IPCMDBStatus = $_.IPCMDBStatus;
                Description = $_.Description;
                BASystem = $_.BASystem;
                ScannedModel = $_.ScannedModel
                Application = $_.BASystem.Owner
                ApplicationName = $_.BASystem.Name
                ApplicationParent = $_.BASystem.Parent
                ServiceOwner = $_.ServiceOwner
            }
            $Results += $TableRow
            Write-Host " OK" -ForegroundColor green

           
            #Write-progress -activity 'Busy busy busy' -CurrentOperation $ip -PercentComplete (($counter / $list.count) * 100)
        }

        #$Results += $TableRow #| Export-Csv $export -Append
        #Write-Host " OK" -ForegroundColor green
       # Write-progress -activity 'Busy busy busy' -CurrentOperation $ip -PercentComplete (($counter / $list.count) * 100)
}

#Write-Host `n "Processing CSV... " -NoNewline
#(Get-Content $export) | select -Skip 1 | Set-Content $export 

Write-Host 'DONE' -ForegroundColor Green

#$Results | export-csv output_01.csv -NoTypeInformation

$Properties = @(
    domain = 'BE';

    )


    $phyDCs =@()
    $list | % {
        
        if ($CIE | ? hostname -eq $_ | ? hardwaretype -eq "physical") {
                $phyDCs += "$_"

        } 
    
    }