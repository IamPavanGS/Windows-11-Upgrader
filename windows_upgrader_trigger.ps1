#####################################################################
# Conver the script to exe windows_upgrader_trigger.exe
#####################################################################


$Logfile = "C:\Users\Public\Win11_$env:computername.log"

if(!(Test-Path $Logfile)){

New-Item -Path "C:\Users\Public\Win11_$env:computername.log"

}

function Write-Log
{
Param ([string]$LogString)
$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$LogMessage = "$Stamp $LogString"
Add-content $LogFile -value $LogMessage
}


function ShowBalloonTipInfo 
{
 
[CmdletBinding()]
param
(
[Parameter()]
$Text,
 
[Parameter()]
$Title,
 

$Icon = 'Info'
)
 
Add-Type -AssemblyName System.Windows.Forms
 

if ($script:balloonToolTip -eq $null)
{

$script:balloonToolTip = New-Object System.Windows.Forms.NotifyIcon 
}
 
$path = Get-Process -id $pid | Select-Object -ExpandProperty Path
$balloonToolTip.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balloonToolTip.BalloonTipIcon = $Icon
$balloonToolTip.BalloonTipText = $Text
$balloonToolTip.BalloonTipTitle = $Title
$balloonToolTip.Visible = $true
 

$balloonToolTip.ShowBalloonTip(3000)
}
 

$isoDir= "C:\Users\Public\Windows11.iso"
$opDir="C:\Windows11Setup"
$arguments=@("x", "-y", "`"$isoDir`"", "-o`"$opDir`"");
$param1=$args[0]
$fpSwitch=$null

If( -not (Test-Path -Path $isoDir -PathType Leaf)){exit 2}


If( -not ([string]::IsNullOrEmpty($param1)))
    {
        $fpSwitch=$param1
    }
Else 
    {
        $fpSwitch="/auto upgrade /DynamicUpdate disable /ShowOOBE none /quiet /noreboot /compat IgnoreWarning /BitLocker TryKeepActive /EULA accept"
    }

$archi=(Get-WmiObject Win32_OperatingSystem).OSArchitecture
If($archi -like '64-bit')
    {
        $ex =start-process -FilePath "C:\Program Files (x86)\DesktopCentral_Agent\bin\7z.exe" -ArgumentList $arguments -wait -PassThru -WindowStyle Hidden 
    }
Else
    {
        $ex =start-process -FilePath "C:\Program Files\DesktopCentral_Agent\bin\7z.exe" -ArgumentList $arguments -wait -PassThru -WindowStyle Hidden 	
    }

$ts = New-TimeSpan -Days 0 -Hours 0 -Minutes 2
$setTime = (Get-Date) + $ts
$fTime = $setTime.ToString('HH:mm')

$Trigger= New-ScheduledTaskTrigger -At $fTime -Once
$User= "NT AUTHORITY\SYSTEM"

$Action= New-ScheduledTaskAction -Execute "C:\Windows11Setup\setup.exe" -Argument $fpSwitch;

If($ex.ExitCode -eq 0)
    {
    Write-Log -LogString "Extraction is complete"
        Register-ScheduledTask -TaskName "Windows 11 FeaturePack Upgrade (DC)" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest -Force | Out-Null
        Start-Sleep -s 120
        Write-Log -LogString "TaskScheduler was successfully created"
        $exCode = (Get-ScheduledTask | Where { $PSITEM.TaskName -eq "Windows 11 FeaturePack Upgrade (DC)"} | get-ScheduledTaskInfo).LastTaskResult

        While(($exCode -eq 267011) -or ($exCode -eq 267009))
            {
                $exCode = (Get-ScheduledTask | Where { $PSITEM.TaskName -eq "Windows 11 FeaturePack Upgrade (DC)"} | get-ScheduledTaskInfo).LastTaskResult
                Start-Sleep -s 120 
            }
        Unregister-ScheduledTask -TaskName "Windows 11 FeaturePack Upgrade (DC)" -Confirm:$false
        Write-Log -LogString "Windows 11 Upgrade was successfully completed"
        [System.Windows.Forms.MessageBox]::Show("Windows 11 Upgradation is complete, Kindly restart the system for it to take effect.", "Upgrade Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        ShowBalloonTipInfo ("Qualitest Notification : ","Windows 11 Upgradation is complete, Kindly restart the system for it to take effect.")

 }

$exCode = '{0:X}' -f $exCode
$exCode = [bigint]::Parse($exCode, 'AllowHexSpecifier')
Write-Output $exCode
exit $exCode



