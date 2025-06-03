# ivms-usage-limiter

## Overview
This PowerShell script monitors for the launch of **iVMS-4200.Framework.C.exe** and automatically terminates all related processes after **30 minutes** of runtime. It's designed for shared or bandwidth-sensitive environments where long-running iVMS sessions can disrupt network performance.

## Why This Exists
At one store location, a user frequently forgot to close iVMS-4200. This system has **only 100 Mbps upload/download**, and iVMS alone was consuming **20–25 Mbps**, effectively throttling a **quarter of the total bandwidth**. As a result, critical systems (e.g., POS terminals, VoIP phones, cloud apps) experienced noticeable slowdowns.

Rather than relying on manual reminders, this script ensures iVMS is automatically closed after 30 minutes, protecting the network and keeping other services responsive.

## How It Works
- Uses **WMI event subscription** to detect when iVMS-4200 is launched.
- Waits 30 minutes.
- Kills all iVMS-related processes, including **CrashServerDamon**.
- Logs actions to: `C:\Logs\ivms-usage-limiter.log`.

---

## Deployment

### Requirements
- Windows machine
- Administrator privileges
- PowerShell execution policy must allow script execution (handled automatically)

---

### Installation Steps

1. **Download or Clone the Repository**
   ```powershell
   git clone https://github.com/your-username/ivms-terminator.git
   cd ivms-terminator
2. **Run the Setup Script as Administrator
   This script will:
  
    - Create `C:\Scripts` if it doesn’t exist  
    - Copy the necessary PowerShell scripts to `C:\Scripts`  
    - Register a scheduled task named `iVMS-Terminator` to run at startup as `SYSTEM`
  
   ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force
    .\setup-task.ps1
