<# 
.SYNOPSIS
    Installs the iVMS Process Killer scheduled task.

.DESCRIPTION
    This script creates a C:\Scripts directory, copies all necessary Powershell scripts into it, and registers
    a scheduled task named "iVMS-Process-Killer" to run at system startup with SYSTEM-level privileges.
    The task runs ivms-process-killer.ps1, which monitors iVMS-4200 and enforces a 30-minute auto-shutdown policy.

.NOTES
    Author: Jack Haggerty
    Create: 2025-06-03
    Requires: Administrator
#>

# Create scripts directory
$targetDir = "C:\Scripts"
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

# Copy all scripts to C:\Scripts
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Copy-Item "$scriptRoot\*.ps1" -Destination $targetDir -Force

# Register the scheduled task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Scripts\iVMS-Process-Killer.ps1"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName "iVMS-Process-Killer" -Action $action -Trigger $trigger -Principal $principal -Force
