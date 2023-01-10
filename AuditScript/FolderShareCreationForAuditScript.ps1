

############################################
#
#   Creating testing locations 
#
############################################


#First step


#Parameter assignment for sake of testing
$MappedDriveLetterPath = "K"
$MappedDriveLetterPath = $MappedDriveLetterPath.TrimEnd(":").TrimEnd("\")


#Folder creation and share creation

$AuditTestEnvPath = "C:\thissrv\Audit_test_env_mapped_drive"
if(!(Test-Path -Path $AuditTestEnvPath)){$null = New-item -Path $AuditTestEnvPath -ItemType Directory -Force}
New-SmbShare -Name "$($MappedDriveLetterPath)_drive" -Path $AuditTestEnvPath -Temporary -FullAccess "Everyone"

#Create mapped drive K: pointing to \\localhost\K_drive

$MappedDrive = (Get-ItemProperty "HKCU:\Network\$($MappedDriveLetterPath)").RemotePath #make it dynamic depending on mapped drive letter
[array]$MappedDriveFolders = Get-ChildItem -Path $MappedDrive | Where-Object {$_.PSIsContainer -eq $true}



#Share Creation

[int]$NumberOfTestlocations = 3
for($i=1;$i -le $NumberOfTestlocations; $i++){
   
    $Share1 = "$MappedDrive\Share_no_$i"
    if(!(Test-Path -Path $Share1)){$null = New-item -Path $Share1 -ItemType Directory -Force}
    
    #Creating subfolders within AuditTest each psdrive
    [array]$DirsToAudit = ls -Path $Share1  | Where-Object {$_.PSIsContainer -eq $true}
    $DirCount = 3
        if($DirsToAudit.Count -lt $DirCount){
            1..$DirCount | % {
                New-Item -Name "Testing_audit$($i)_subfolder$($_)" -Path $Share1 -ItemType Directory -ea SilentlyContinue 
            }
        }

} ; $i=0


#########################



<#Cleaning PSDrives and folder contents
Get-PSDrive -Name AuditTest* | Remove-PSDrive  -Verbose
ls -Path "C:\thissrv\audittest*" | Remove-Item -Recurse -Verbose
#>
