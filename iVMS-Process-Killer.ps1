<#
.SYNOPSIS
  Monitors for iVMS-4200 launch and enforces a 30-minute runtime limit.

.DESCRIPTION
  Uses WMI event subscriptions to detect wehn iVMS-4200.Framework.C.exe starts.
  After 30 minutes, terminates all related processes - including CrashServerDamon 
  and other iVMS-4200.* modules.  Designed for bandwidth senstive or shared environments.
  Logs all actions to local file.

.Notes
  Author: Jack Haggerty
  Created: 2025-06-03
#>

# === Configuration ===
$triggerProcess = "iVMS-4200.Framework.C.exe"
$killAfter = 60    # 30 minutes
$logPath = "C:\Logs\ivms-usage-limiter.log"

# === Logging Function ===
function Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $msg" | Out-File -FilePath $logPath -Append
}

# === Make Sure Log Directory Exists ===
$logDir = Split-Path $logPath
if (!(Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

Log "Started iVMS WMI Monitor Loop"

# === Main Loop ===
while ($true) {
    try {
        # Cleanup any previous WMI Subscriptions
        Unregister-Event -SourceIdentifier "iVMSWatch" -ErrorAction SilentlyContinue
        Remove-Event -SourceIdentifier "iVMSWatch" -ErrorAction SilentlyContinue

        # Register for iVMS main process starting
        $query = "SELECT * FROM Win32_ProcessStartTrace WHERE ProcessName = '$triggerProcess'"
        Register-WmiEvent -Query $query -SourceIdentifier "iVMSWatch" | Out-Null
        Log "Waiting for $triggerProcess to launch..."

        # Wait for process start event (up to 1 hr)
        $event = Wait-Event -SourceIdentifier "iVMSWatch" -Timeout 3600

        if ($event -ne $null) {
            $ivmsPid = $event.SourceEventArgs.NewEvent.ProcessID
            Log "Detected iVMS launch. PID: $ivmsPid"

            Start-Sleep -Seconds $killAfter

            # Kill all iVMS-related processes simultaneously
            $processPatterns = @("iVMS-4200.*", "CrashServerDamon", "nginx", "WatchDog")
            $targets = Get-Process | Where-Object {
                $name = $_.ProcessName
                $processPatterns | ForEach-Object { if ($name -like $_) {return $true}}
                }

                if ($targets.Count -gt 0) {
                    foreach ($proc in $targets) {
                        try {
                            Stop-Process -Id $proc.Id -Force
                            Log "Killed $($proc.ProcessName) (PID $($proc.Id)): $_"
                        } catch {
                            Log "No iVMS or CrashServerDamon processes found at kill time."
                        }

                        # Clean up WMI event subscription
                        Unregister-Event -SourceIdentifier "iVMSWatch" -ErrorAction SilentlyContinue
                        Remove-Event -SourceIdentifier "iVMSWatch" -ErrorAction SilentlyContinue
                    }
                } else {
                    Log "Timeout: No iVMS launch detected within the hour."
                }
        }
    } catch {
            Log "Script error: $_"
            Start-Sleep -Seconds 10
    }
  }

















            
        
