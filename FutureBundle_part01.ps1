$ss = @"
"@ -split "\r\n"

$FailingHosts = @()

foreach ($s in $ss){

    #ping $s
    try {
    
        Test-Connection -ComputerName $s -Count 1 -ea Stop | ft -AutoSize
    }
    catch {
    
        $FailingHosts += $s

    } 
}

if(!($FailingHosts.count -eq 0)){
    Write-Host "`nFailing hosts:"
    $FailingHosts
}




$ss | % { 

    $ErrorActionPreference = 'Stop'

    try{
    Invoke-Command -ComputerName $_ -ScriptBlock {
     
    
    Get-NetConnectionProfile | select networkcategory}
    

    

}

catch{Write-Warning $error[0].Exception.Message}


}


$serversPublic = @"
"@ -split "\n" | % {$_.trimend("")}

Foreach($server1 in $serversPublic){

    Invoke-Command -ComputerName $server1 -ScriptBlock {
        Write-Host "Checking $($env:computername)" -ForegroundColor Magenta
        Get-Service 'nlasvc' | Restart-Service -Verbose -Force
        Start-Sleep -Seconds 3
        Get-NetConnectionProfile
    
    }

}


$ss = @"

"@ -split "\n" | % {$_.trimend("")}


$ss | % { 

    $ErrorActionPreference = 'Stop'

    try{
    Invoke-Command -ComputerName $_ -ScriptBlock {
     
    
    Get-NetConnectionProfile | select networkcategory}
    }

    catch{Write-Warning $error[0].Exception.Message}

}

##NLA service reboot

$serversPublic = @"
"@ -split "\n" | % {$_.trimend("")}

Foreach($server1 in $serversPublic){
    Invoke-Command -ComputerName $server1 -ScriptBlock {
        Write-Host "Checking $($env:computername)" -ForegroundColor Magenta
        Get-Service 'nlasvc' | Restart-Service -Verbose -Force
        Start-Sleep -Seconds 3
        Get-NetConnectionProfile   
    }
}

## set multiple SPNs for a single account name

$SPNs = @"
"@ -split "\n"

$ServiceAccount = '<service account name'
setspn -L $ServiceAccount

if($SPNs.Count -gt 1){
    foreach($SPN1 in $SPNs){
        setspn -S $SPN1 $ServiceAccount ;
        sleep -Seconds 2 }
}
