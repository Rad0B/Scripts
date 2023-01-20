$ss = @"
sf000sv80325.res000m.sif.jndata.net

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
sf000sv90436.res000t.sif.jndata.net
sf000sv90465.res000t.sif.jndata.net
sf000sv90464.res000t.sif.jndata.net
sf000sv90437.res000t.sif.jndata.net
sf000sv90463.res000t.sif.jndata.net
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
sf100sv90454.jnmain50.corp.jndata.net
sf100sv90455.jnmain50.corp.jndata.net
sf100sv90453.jnmain50.corp.jndata.net
sf100sv90483.jnmain50.corp.jndata.net
sf100sv90934.jnmain50.corp.jndata.net
sf100sv90521.jnmain50.corp.jndata.net
sf100sv90544.jnmain50.corp.jndata.net
sf100sv90497.jnmain50.corp.jndata.net
sf100sv90481.jnmain50.corp.jndata.net
sf100sv90293.jnmain50.corp.jndata.net
sf100sv90461.jnmain50.corp.jndata.net
sf100sv90465.jnmain50.corp.jndata.net
sf100sv90241.jnmain50.corp.jndata.net
sf100sv90550.jnmain50.corp.jndata.net
sf100sv90551.jnmain50.corp.jndata.net
sf100sv90547.jnmain50.corp.jndata.net
sf100sv90194.jnmain50.corp.jndata.net
sf100sv90222.jnmain50.corp.jndata.net
sf100sv90511.jnmain50.corp.jndata.net
sf100sv90512.jnmain50.corp.jndata.net
sf100sv90200.jnmain50.corp.jndata.net
sf100sv90956.jnmain50.corp.jndata.net
sf100sv90291.jnmain50.corp.jndata.net
sf100sv90240.jnmain50.corp.jndata.net
sf100sv90456.jnmain50.corp.jndata.net
sf100sv90955.jnmain50.corp.jndata.net
sf100sv90236.jnmain50.corp.jndata.net
sf100sv90543.jnmain50.corp.jndata.net
sf100sv90230.jnmain50.corp.jndata.net
sf100sv90516.jnmain50.corp.jndata.net
sf100sv90238.jnmain50.corp.jndata.net
sf100sv90196.jnmain50.corp.jndata.net
sf100sv90471.jnmain50.corp.jndata.net
sf100sv90531.jnmain50.corp.jndata.net
sf100sv90530.jnmain50.corp.jndata.net
sf100sv90221.jnmain50.corp.jndata.net
sf100sv90429.jnmain50.corp.jndata.net
sf100sv90466.jnmain50.corp.jndata.net
"@ -split "\n" | % {$_.trimend("")}


$ss | % { 

    $ErrorActionPreference = 'Stop'

    try{
    Invoke-Command -ComputerName $_ -ScriptBlock {
     
    
    Get-NetConnectionProfile | select networkcategory}
    }

    catch{Write-Warning $error[0].Exception.Message}

}


$serversPublic = @"
sf100sv90455.jnmain50.corp.jndata.net
sf100sv90453.jnmain50.corp.jndata.net
sf100sv90544.jnmain50.corp.jndata.net
sf100sv90222.jnmain50.corp.jndata.net
sf100sv90291.jnmain50.corp.jndata.net
sf100sv90456.jnmain50.corp.jndata.net
sf100sv90221.jnmain50.corp.jndata.net
"@ -split "\n" | % {$_.trimend("")}

Foreach($server1 in $serversPublic){

    Invoke-Command -ComputerName $server1 -ScriptBlock {
        Write-Host "Checking $($env:computername)" -ForegroundColor Magenta
        Get-Service 'nlasvc' | Restart-Service -Verbose -Force
        Start-Sleep -Seconds 3
        Get-NetConnectionProfile
    
    }

}

$SPNs = @"
Orders.Cows.Api/nks02240.nkd01100.nykreditnet.net
Orders.Cows.Api/nks02240
Orders.Cows.Api/nks02241.nkd01100.nykreditnet.net
Orders.Cows.Api/nks02241
Orders.Cows.Api/nks02242.nkd01100.nykreditnet.net
Orders.Cows.Api/nks02242
Orders.Cows.Api/itwmprod
"@ -split "\n"

$ServiceAccount = 'SYSTEM10084P'
setspn -L $ServiceAccount

if($SPNs.Count -gt 1){

    foreach($SPN1 in $SPNs){
        setspn -S $SPN1 $ServiceAccount ;
        sleep -Seconds 2 }

}