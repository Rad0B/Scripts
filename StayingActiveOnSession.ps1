#
#   Active session script running indefinately.
#   To run StayingActiveOnSession.ps1 script select 'Run with Powershell'
#   To terminate press "Ctrl + C" or close command line window
#

function StayingActiveOnSession{
    [CmdletBinding()]
    param(
        [int]$sleep = 200,
        [int]$MousePositionInteration = 1
    )
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Add-Type -assemblyName System.Windows.Forms
$WShell = New-Object -ComObject "WScript.Shell"

    while($true){
        Clear-Host
        Write-Verbose -Message "`nRunning Active Session script - to terminate press 'Ctrl + C' or close command line window"
        #Keyboard pressing
        $WShell.SendKeys("{SCROLLLOCK}") #{SCROLLLOCK}
        Start-Sleep -Seconds 10
        $WShell.SendKeys("{SCROLLLOCK}")

        #Mouse movement
        $mouseposition = [System.Windows.Forms.Cursor]::Position
        $xposition = $mouseposition.X + $MousePositionInteration
        $yposition = $mouseposition.Y + $MousePositionInteration
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($xposition,$yposition)
        $MousePositionInteration *= -1

        #Sleep
        Start-Sleep -Seconds $sleep
    }
}

#Running function with default parameters
StayingActiveOnSession -Verbose