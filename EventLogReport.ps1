# Load Windows Forms
Add-Type -AssemblyName System.Windows.Forms

# Function to create a date picker dialog
function Show-DatePickerDialog {
    param (
        [string]$Title = "Select Date",
        [datetime]$InitialDate = (Get-Date)
    )

    $form = New-Object Windows.Forms.Form
    $form.Text = $Title
    $form.Width = 300
    $form.Height = 200
    $form.StartPosition = "CenterScreen"

    $datePicker = New-Object Windows.Forms.DateTimePicker
    $datePicker.Format = [Windows.Forms.DateTimePickerFormat]::Short
    $datePicker.Value = $InitialDate
    $datePicker.Location = New-Object Drawing.Point(50,50)
    $datePicker.Width = 200
    $form.Controls.Add($datePicker)

    $okButton = New-Object Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Location = New-Object Drawing.Point(50,100)
    $okButton.Width = 200
    $form.Controls.Add($okButton)

    $okButton.Add_Click({
        $form.Tag = $datePicker.Value
        $form.Close()
    })

    $form.ShowDialog() | Out-Null
    return $form.Tag
}

# Prompt for start and end dates
$startDate = Show-DatePickerDialog -Title "Select Start Date"
$endDate = Show-DatePickerDialog -Title "Select End Date"

# Adjust start and end dates to cover the entire day
$startDate = Get-Date -Year $startDate.Year -Month $startDate.Month -Day $startDate.Day -Hour 0 -Minute 0 -Second 0
$endDate = Get-Date -Year $endDate.Year -Month $endDate.Month -Day $endDate.Day -Hour 23 -Minute 59 -Second 59

# Event IDs for logon and disconnect
$EventIDs = @(4778, 4779)

# Query the Security event logs for relevant events
$logEntries = Get-WinEvent -FilterHashtable @{
    LogName = 'Security';
    StartTime = $startDate;
    EndTime = $endDate;
    ID = $EventIDs
} -ErrorAction SilentlyContinue | Select-Object TimeCreated, Id, @{Name="Account";Expression={$_.Properties[0].Value}}, @{Name="AccountDomain";Expression={$_.Properties[1].Value}}, @{Name="LogonID";Expression={$_.Properties[2].Value}}, @{Name="SessionName";Expression={$_.Properties[3].Value}}, @{Name="ClientName";Expression={$_.Properties[4].Value}}, @{Name="ClientAddress";Expression={$_.Properties[5].Value}}

# Group entries by Account
$logEntriesGrouped = $logEntries | Group-Object Account

# Function to convert Event ID to action
function Get-ActionFromEventID {
    param ($EventID)
    switch ($EventID) {
        4778 { return "Logon" }
        4779 { return "Disconnect" }
        default { return "Unknown" }
    }
}

# Create a report
$report = @()

foreach ($group in $logEntriesGrouped) {
    $account = $group.Name
    foreach ($entry in $group.Group) {
        $report += [PSCustomObject]@{
            Account = $account
            AccountDomain = $entry.AccountDomain
            LogonID = $entry.LogonID
            SessionName = $entry.SessionName
            ClientName = $entry.ClientName
            ClientAddress = $entry.ClientAddress
            TimeCreated = $entry.TimeCreated
            Action = Get-ActionFromEventID -EventID $entry.Id
        }
    }
}

# Define the path to the user's Downloads folder
$downloadsPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("UserProfile"), "Downloads")
# Define the file name
$csvFileName = "EventLogReport.csv"
# Combine the path and file name
$csvFilePath = [System.IO.Path]::Combine($downloadsPath, $csvFileName)

# Export the report to a CSV file
$report | Sort-Object TimeCreated -Descending | Export-Csv -Path $csvFilePath -NoTypeInformation

# Output the location of the saved file
Write-Output "Report saved to $csvFilePath"

# Optional: Open the file after saving (uncomment if needed)
# Start-Process -FilePath $csvFilePath
