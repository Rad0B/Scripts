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
SF160SV00340
SF160SV00341
SF160SV00342
SF160SV00343
SF160SV00344
SF160SV00345
SF160SV00352
SF160SV00353
SF160SV00354
SF160SV00355
SF160SV00356
SF160SV00357
SF160SV00924
SF160SV00925
SF160SV00926
SF160SV00927
SF160SV00928
SF160SV00929
SF160SV00930
SF160SV00931
SF160SV00932
SF160SV00933
SF160SV00934
SF160SV00935
SF160SV00924
SF160SV00925
SF160SV00926
SF160SV00927
SF160SV00928
SF160SV00929
SF160SV00352
SF160SV00353
SF160SV00354
SF160SV00355
SF160SV00356
SF160SV00357
"@ -split "\n" | ? {$_ -ne ""} | foreach-object {$_.trim()}  | Select-Object -Unique




# Adding results to empty array
$Results=@()

#iterating through server list
foreach ($server1 in $list) 
{
    #$counter++
    Write-Host "Processing $server1..."
        $CIext | Where-Object {$_.hostname -eq $server1} | ForEach-Object {
            $TableRow = [PSCustomObject]@{
                IP = $_.ip;
                Hostname =  $_.Hostname;
                Domain = $_.Domain;           
                Customer = $_.Company;
                FQDN = $_.fqdn;
                OS = $_.OS;
                HardwareType = $_.HardwareType
                IPCMDBStatus = $_.IPCMDBStatus;
                Description = $_.Description;
                BASystem = $_.BASystem;
                DeployWindow = $_.PackageDeployWindow;
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