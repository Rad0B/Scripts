function Test-SSL3{
    param (
        [string[]]$ComputerName = $Env:COMPUTERNAME
    )

    $ErrorActionPreference = 'Stop'
    $Results = @()
    
    Foreach($Comp1 in $ComputerName){
        Write-Host "Checking $Comp1 ..." -ForegroundColor Magenta
        
        try{
        invoke-command -ComputerName $Comp1 -scriptblock {

            $SChannel = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
            $SSL30_Server_reg = Join-Path -Path $SChannel -ChildPath "SSL 3.0\Server"
            $SSL30_Client_reg = Join-Path -Path $SChannel -ChildPath "SSL 3.0\Client"

               if((Test-Path -Path $SChannel) -and ((Get-ChildItem -path $SChannel).count -ne 0)){
                    if(Test-Path $SSL30_Server_reg){
                       # "SSL 3.0\Server - True - this path exists"

                            $SSL30_Server_info = Get-ItemProperty -Path $SSL30_Server_reg
                            $SSL30_Server_info_prop = $SSL30_Server_info | Select -Property $(($SSL30_Server_info.PSobject.Properties | ? Name -NotLike "PS*").Name)
                            $SSL30_Server_table = [PSCustomObject]@{
                                ServerName = $using:Comp1;
                                RegPath = $SSL30_Server_reg;
                            }
                            foreach($SSL30_Server_info_prop1 in $SSL30_Server_info_prop.psobject.properties.name){

                                $SSL30_Server_table | Add-Member -MemberType NoteProperty -Name $SSL30_Server_info_prop1 -Value $SSL30_Server_info_prop.$SSL30_Server_info_prop1 -Force
                            }
                                
                            $SSL30_Server_table

                    }
                    if(Test-Path -Path $SSL30_Client_reg){
                        #"SSL 3.0\Client - True - this path exists"

                            $SSL30_Client_info = Get-ItemProperty -Path $SSL30_Client_reg
                            $SSL30_Client_info_prop = $SSL30_Client_info | Select -Property $(($SSL30_Client_info.PSobject.Properties | ? Name -NotLike "PS*").Name)
                            $SSL30_Client_table = [PSCustomObject]@{
                                ServerName = $using:Comp1;
                                RegPath = $SSL30_Client_reg;
                            }
                            foreach($SSL30_Client_info_prop1 in $SSL30_Client_info_prop.psobject.properties.name){

                                $SSL30_Client_table | Add-Member -MemberType NoteProperty -Name $SSL30_Client_info_prop1 -Value $SSL30_Client_info_prop.$SSL30_Client_info_prop1 -Force
                            }
                                
                            $SSL30_Client_table
                    }

                    #else {"No SSL3.0 hives in registry on $using:Comp1"}

               }

               else {"No SSL3.0 hives in registry on $using:Comp1"}

        }
    }

    catch{
       Write-Warning "Error: $($error[0].Exception)"
    }

    }
}






<#
    #$ErrorActionPreference = "SilentlyContinue"
    If (Test-Administrator) {} Else {Write-Host "This Function needs to run elevated, exiting...." -foregroundcolor Yellow;exit}
      $SChannel = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
      $null = New-Item "$($SChannel)\SSL 3.0\Server" -Force
      $null = New-Item "$($SChannel)\SSL 3.0\Client" -Force
      $null = New-ItemProperty -Path "$($SChannel)\SSL 3.0\Server" -Name DisabledByDefault -Value 1 -PropertyType DWORD
      $null = New-ItemProperty -Path "$($SChannel)\SSL 3.0\Server" -Name Enabled -Value 0 -PropertyType DWORD
      $null = New-ItemProperty -Path "$($SChannel)\SSL 3.0\Client" -Name Enabled -Value 0 -PropertyType DWORD
      $null = New-ItemProperty -Path "$($SChannel)\SSL 3.0\Client" -Name DisabledByDefault -Value 1 -PropertyType DWORD
    }
    


$servers = @"
NKS01371.nkd01100.nykreditnet.net
nks01415.nkd01100.nykreditnet.net
NKS01471.nkd01100.nykreditnet.net
NKS01571.nkd01100.nykreditnet.net
nks01627.nkd01100.nykreditnet.net
NKS01628.nkd01100.nykreditnet.net
NKS01662.nkd01100.nykreditnet.net
NKS01716.nkd01100.nykreditnet.net
NKS01205.nkd01100.nykreditnet.net
NKS01372.nkd01100.nykreditnet.net
NKS01374.nkd01100.nykreditnet.net
nks01416.nkd01100.nykreditnet.net
NKS01469.nkd01100.nykreditnet.net
nks01593.nkd01100.nykreditnet.net
nks01663.nkd01100.nykreditnet.net
"@ -split "\n"

$servers = $servers | % {$_.trimend()}

#>