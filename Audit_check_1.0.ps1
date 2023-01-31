[CmdletBinding()]

param(

    [string]$MappedDriveLetterPath = 'K',
    [string]$LogFolderLocation = "D:\nobackup\AuditLog_$((get-date).tostring("yyyyMMdd")).csv", #"$PSScriptRoot\Logs\AuditLog_$((get-date).tostring("yyyyMMdd")).csv", #provide absolute path to folder
    [int]$SleepTimeBetweenPaths = 0
)

######################
#
#   Script variables
#
######################

$ScriptDateTime = (get-date -Format G)
$CurrentLocation = pwd
$ErrorActionPreference = 'Stop'

#$MappedDriveLetterPath = "K"
$MappedDriveLetterPath = $MappedDriveLetterPath.TrimEnd(":").TrimEnd("\")

$MappedDrive = (Get-ItemProperty "HKCU:\Network\$($MappedDriveLetterPath)").RemotePath #make it dynamic depending on mapped drive letter
[array]$MappedDriveFolders = Get-ChildItem -Path $MappedDrive | Where-Object {$_.PSIsContainer -eq $true}

$ProgressCounter = 1

######################################
#
#   Logs folder verificaton/creation
#
######################################

$LogsFolder = "$PSScriptRoot\Logs"
    if(!(Test-Path $LogsFolder)){
        [void](New-Item -Path $LogsFolder -ItemType Directory)
    }
[string]$LogsTest = 'Test'

########################
#
#   Write-Log function
#
########################

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$AuditPath,

        [Parameter()]
        [string]$WasAuditinPlace,

        [Parameter()]
        [string]$Account,

        [Parameter()]
        [string]$AuditType,

        [Parameter()]
        [string]$AuditRules,

        [Parameter()]
        [string]$Comments,

        [Parameter()]
        [string]$LogPath = $LogFolderLocation
    )
 
        [pscustomobject][ordered]@{
            Time = $ScriptDateTime
            Path = $AuditPath
            WasAuditinPlace = $WasAuditinPlace
            Account = $Account
            AuditType = $AuditType
            AuditRules = $AuditRules
            Comments = ''

        } | Export-Csv -Path $LogPath -Append -NoTypeInformation
}

###############
#
#  AuditRule
#
###############

#User - everyone or NT AUTHORITY\Authenticated Users
$AuditUser = "Everyone"
#Audit rules to log
$AuditRules = "CreateFiles,CreateDirectories,Delete,DeleteSubdirectoriesAndFiles,ChangePermissions,Takeownership"
#Inheritance 
$InheritType = "ContainerInherit,ObjectInherit"
#Audit type - success/failure
$AuditType = "Success"
#Combining all rules together 
$AccessRule = New-Object System.Security.AccessControl.FileSystemAuditRule($AuditUser,$AuditRules,$InheritType,"None",$AuditType)

#######################################
#
#   Checking and settings up auditing
#
#######################################

$MappedDriveFolders.ForEach({
        $Path = $_
        $ACLAuditStr = (Get-ACL -Path $Path.Fullname -Audit).AuditToString
        #Write progress bar 
        Write-Progress -Activity "Checking path $($Path.FullName)" -Status "Checking $ProgressCounter of $($MappedDriveFolders.count)" -PercentComplete (($ProgressCounter / $($MappedDriveFolders.count))* 100)
        $ProgressCounter++
    
    if ($ACLAuditStr -eq ""){

        Write-Host "No audit on $($Path.FullName) ... adding audit policy" -ForegroundColor Magenta ; sleep -Seconds 1
            if($AccessRule){
                $ACLonDir = Get-Acl -Path $($Path.FullName)
                $ACLonDir.SetAuditRule($AccessRule)
                $ACLonDir | Set-Acl -Path $($Path.FullName)
            }
            else{"No access rule defined"}

          $ACLAuditStrVerify = ((Get-ACL -Path $Path.Fullname -Audit).AuditToString) -split "\n"  
            foreach($ACLAuditStrVerify1 in $ACLAuditStrVerify){
               <# [PSCustomObject]@{
                    Path = $Path.FullName
                    Account = ($ACLAuditStrVerify1 -split "\s{2}")[0] -replace "Success|Failure", ""
                    AuditType = (($ACLAuditStrVerify1 -split "\s{2}")[0] -split "\s{1}")[-1];
                    AuditRules = ($ACLAuditStrVerify1 -split "\s{2}")[1];
                } #>
                    $ACLAuditStrVerifyTable1 = [PSCustomObject]@{
                            Path = $Path.FullName
                            Account = ($ACLAuditStrVerify1 -split "\s{2}")[0] -replace "Success|Failure", ""
                            AuditType = (($ACLAuditStrVerify1 -split "\s{2}")[0] -split "\s{1}")[-1];
                            AuditRules = ($ACLAuditStrVerify1 -split "\s{2}")[1];
                        }
    
            Write-Log -AuditPath $ACLAuditStrVerifyTable1.Path -WasAuditinPlace 'False' -Account $($ACLAuditStrVerifyTable1.Account) -AuditType $($ACLAuditStrVerifyTable1.AuditType) -AuditRules $($ACLAuditStrVerifyTable1.AuditRules)

            }
    }

    Else {

        Write-Host "Audit already in place on $($Path.FullName)" -ForegroundColor Cyan

        $ACLAuditStrMulti = ((Get-ACL -Path $Path.FullName -Audit).AuditToString) -split "\n" 
        foreach($ACLAuditStr1 in $ACLAuditStrMulti){
           <# [PSCustomObject]@{
                Path = $Path.FullName
                Account = ($ACLAuditStr1 -split "\s{2}")[0] -replace "Success|Failure", ""
                AuditType = (($ACLAuditStr1 -split "\s{2}")[0] -split "\s{1}")[-1];
                AuditRules = ($ACLAuditStr1 -split "\s{2}")[1];
            }#>
                $ACLAuditStrMultiTable  = [PSCustomObject]@{
                    Path = $Path.FullName
                    Account = ($ACLAuditStr1 -split "\s{2}")[0] -replace "Success|Failure", ""
                    AuditType = (($ACLAuditStr1 -split "\s{2}")[0] -split "\s{1}")[-1];
                    AuditRules = ($ACLAuditStr1 -split "\s{2}")[1];
            }

             Write-Log -AuditPath $ACLAuditStrMultiTable.Path -WasAuditinPlace 'True' -Account $($ACLAuditStrMultiTable.Account) -AuditType $($ACLAuditStrMultiTable.AuditType) -AuditRules $($ACLAuditStrMultiTable.AuditRules)
       
        }
    
    
    }

    if($SleepTimeBetweenPaths){Start-Sleep -Seconds $SleepTimeBetweenPaths}

})

Write-Host ""
Write-Host "Log saved under $($LogFolderLocation)" -ForegroundColor Green
