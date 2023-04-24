Add-Type -AssemblyName System.Windows.Forms

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

Write-Log -LogString "Application started successfully"

$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows 11 Upgrader"
$form.Width = 510
$form.Height = 400
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::WhiteSmoke

# Greeting based on time of day
$currentTime = (Get-Date).Hour
if ($currentTime -ge 0 -and $currentTime -lt 12) {
    $greeting = "Good morning"
} elseif ($currentTime -ge 12 -and $currentTime -lt 18) {
    $greeting = "Good afternoon"
} else {
    $greeting = "Good evening"
}


# Branding label
$brandingLabel = New-Object System.Windows.Forms.Label
$brandingLabel.Location = New-Object System.Drawing.Point(70, 20)
$brandingLabel.Size = New-Object System.Drawing.Size(360, 30)
$brandingLabel.TextAlign = [System.Drawing.ContentAlignment]::TopCenter
$brandingLabel.Text = "Qualitest Windows Upgrader Tool"
$brandingLabel.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($brandingLabel)

$downloadButton = New-Object System.Windows.Forms.Button
$downloadButton.Location = New-Object System.Drawing.Point(20, 70)
$downloadButton.Size = New-Object System.Drawing.Size(225, 50)
$downloadButton.Text = "Download Windows 11"
$downloadButton.Padding = New-Object System.Windows.Forms.Padding(10)
$form.Controls.Add($downloadButton)

$upgradeButton = New-Object System.Windows.Forms.Button
$upgradeButton.Location = New-Object System.Drawing.Point(255, 70)
$upgradeButton.Size = New-Object System.Drawing.Size(225, 50)
$upgradeButton.Text = "Upgrade to Windows 11"
$upgradeButton.Padding = New-Object System.Windows.Forms.Padding(10)
$form.Controls.Add($upgradeButton)

$outputBox = New-Object System.Windows.Forms.RichTextBox
$outputBox.Location = New-Object System.Drawing.Point(20, 150)
$outputBox.Size = New-Object System.Drawing.Size(462, 190)
$outputBox.ReadOnly = $true
$outputBox.BackColor = [System.Drawing.Color]::DarkGray
$outputBox.ForeColor = [System.Drawing.Color]::Black
$outputBox.Font = New-Object System.Drawing.Font("Arial", 13)
$outputBox.Padding = New-Object System.Windows.Forms.Padding(10)
$outputBox.AppendText("$greeting! Welcome to the Qualitest Windows Upgrader Tool!!`n")
$form.Controls.Add($outputBox)

$downloadButton.Add_Click({

    Write-Log -LogString "Download button is clicked"

    $url = "https://www.itechtics.com/?dl_id=168"
    $filename = "$env:PUBLIC\Windows11.iso"
    $client = New-Object System.Net.WebClient
    $client.DownloadFileAsync($url, $filename)

    $outputBox.Clear()
    $outputBox.AppendText("Downloading Windows 11...`n")

    Write-Log -LogString "Download of windows 11 started"

    $client.add_DownloadProgressChanged({
        $outputBox.Clear()
        $outputBox.AppendText("Downloaded " + [math]::Round($_.BytesReceived / 1MB, 2) + "MB of " + [math]::Round($_.TotalBytesToReceive / 1MB, 2) + "MB`n")
    })

    $client.add_DownloadFileCompleted({
        
        $outputBox.AppendText("Download complete.`n")

        Write-Log -LogString "Windows 11 ISO download to Public folder"
    })
})






$upgradeButton.Add_Click({


Write-Log -LogString "Upgrade button clicked"

    # Check if the current OS is Windows 11
    $isWindows11 = $false
    $winVersion = (Get-ComputerInfo | Select-Object -expand OsName) -match 11
    if ($winVersion -eq $true) {
        $outputBox.AppendText("The running OS is already Windows 11.`n")
        Write-Log -LogString "OS is already running on windows 11"
        $isWindows11 = $true
    }

    if (-not $isWindows11) {

    $outputBox.AppendText("Windows 11 Upgrade has been started.`n")
    $outputBox.AppendText("Upgrade will take time depending on the system configuration.`n")
    $outputBox.AppendText("Kindly do not close the applciation or restart the system till the process is complete.`n")

    Start-Process -FilePath "C:\Users\Public\windows_upgrader_trigger.exe"


}
})

$form.ShowDialog() | Out-Null