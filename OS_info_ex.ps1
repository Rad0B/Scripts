#$list = read-Host -Prompt "Enter absolute path to file"
$list = "C:\Users\$($env:username)\Desktop\list.txt"
$output_dir = "$home\desktop\Results_$((get-date).tostring("yyyyMMdd_HHmm")).txt"
 
 $lista = cat $list | % {$_.ToString().TrimEnd()}

 $ErrorActionPreference = 'Stop'

 $ErroringList = @()

Write-output "COMPUTERNAME;FQDN;DOMAINNAME;OSVERSION;LASTBOOTUP;LASTSUCCESFULBOOT;APPLICATIONS;PATCHES" > $output_dir

Foreach($item in $lista){

    Write-Host "Checking $item" -ForegroundColor Magenta

  try{
    $command = Invoke-command -ComputerName $item -ScriptBlock {
        
    $domainname = (gcim -classname Win32_ComputerSystem).domain
    $fqdn = $env:computername +'.'+ (gcim -classname Win32_ComputerSystem).domain
    $allproducts = gcim -ClassName Win32_Product
    $osversion = (gcim -classname Win32_OperatingSystem).Caption
    $appversion = ($allproducts | where {($_.vendor -eq 'McAfee, LLC.' -or $_.vendor -eq 'Carbon Black, Inc' -or $_.vendor -eq 'VMware, Inc.')} | select Name, Version, InstallDate | sort installedon | Format-Table -HideTableHeaders | Out-String ) -replace "Package ",'' -replace ' was.*','' | foreach {$_ -replace '\n',',' -replace "\W{2,4}","" -replace "\s{1,100}","-" }
    $lastboot = (gcim -classname Win32_OperatingSystem).LastBootUpTime
    $patches = (Get-WinEvent -FilterHashtable @{logname = 'setup'; id = 2} | where TimeCreated -ge (get-date).AddDays(-7) | select TimeCreated, Message | Format-Table -HideTableHeaders | Out-String ) -replace "Package ",'' -replace ' was.*','' | foreach {$_ -replace '\n',',' -replace "\W{2,4}","" -replace "\s{1,100}","-" }
    $lastrestart = (Get-EventLog -LogName 'System' | where {$_.EventID -eq '1074' -and $_.Message -like '*restart*'} | where TimeGenerated -ge (get-date).AddDays(-7)).TimeGenerated
    Write-output "$env:computername;$fqdn;$domainname;$osversion;$lastboot;$lastrestart;$appversion;$patches"

        #to run locally
       <#
       $command = Write-output "$env:computername;$fqdn;$domainname;$osversion;$lastboot;$lastrestart;$appversion;$patches"
       $output_dir = "$home\desktop\Results_$((get-date).tostring("yyyyMMdd_HHmm")).txt"
       Write-output "COMPUTERNAME;FQDN;DOMAINNAME;OSVERSION;LASTBOOTUP;LASTSUCCESFULBOOT;APPLICATIONS;PATCHES" > $output_dir
       $command >> $output_dir 
       #>

    }
 
        $command >> $output_dir

}

    catch {

        $ErroringList += [PSCustomObject]@{
        ErrorServer = $Error[0].TargetObject
        ErrorMessage = $Error[0].Exception.Message
    }
    }
}

if($ErroringList -ne $null){Write-Host "Server erroring:" ; $ErroringList <#| ft -AutoSize -Wrap#>}

 $ErrorActionPreference = 'Continue'