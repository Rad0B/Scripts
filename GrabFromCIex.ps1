#Write-Host 'Importing CI extended database... ' -NoNewline
$uri="http://ciextended.corp.jndata.net/api/ciapi"
$CIext = Invoke-RestMethod -Uri $uri

# Outfile
# $CIext | Export-Csv -Path .\Out\CIext_report_$(get-date -Format "yyyyMMdd_HHmm").csv -NoTypeInformation


##############################
#
# List of servers to check
#
##############################
$list = @"
#IP
"@ -split "\n" | foreach-object {$_.trim()}

# Adding results to empty array
$Results=@()

#iterating through server list
foreach ($server1 in $list) 
{
    #$counter++
    Write-Host "Processing $server1..."
        $CIext | Where-Object {$_.IP -eq $server1} | ForEach-Object {
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
            Write-Host "OK" -ForegroundColor green
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