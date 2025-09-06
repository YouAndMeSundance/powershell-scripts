# PowerShell AD Automation

This repository contains PowerShell scripts for automating common Active Directory tasks.  
The focus is on **new-hire provisioning** and **user access reporting**, two workflows that are common in IT and SOC environments.

---

## Scripts

### 🔹 New-ADUserFromCsv.ps1
Creates and enables new AD users from a CSV file.  
- Sets attributes like name, UPN, and OU placement  
- Applies an initial password (with option to force change at next login)  
- Adds users to one or more security groups  

**CSV format**
GivenName,Surname,SamAccountName,UserPrincipalName,OU,Groups,Password
Jordan,Sena,jsena,jsena@corp.local,"OU=Users,OU=Corp,DC=corp,DC=local","Domain Users;Helpdesk",P@ssw0rd!

pgsql
Copy code

**Run**
```powershell
# Simulate (no changes made)
.\New-ADUserFromCsv.ps1 -Path .\new_hires.csv -WhatIf

# Create accounts
.\New-ADUserFromCsv.ps1 -Path .\new_hires.csv
🔹 Get-AccessReport.ps1
Generates a quick access report for one or more AD users.

Shows whether the account is enabled or locked

Lists all group memberships

Output can be piped into Export-Csv

Run

powershell
Copy code
# Single user
.\Get-AccessReport.ps1 -Identity jsena

# Multiple users
.\Get-AccessReport.ps1 -Identity jsena, mgibson, aturner

# Export to CSV
.\Get-AccessReport.ps1 -Identity jsena, mgibson | Export-Csv .\access_report.csv -NoTypeInformation
Sample output

pgsql
Copy code
User    Enabled Locked Groups
----    ------- ------ -----------------------------------------
jsena   True    False  Domain Users; Helpdesk; VPN-Access
Setup
Install RSAT with the Active Directory module on your workstation.

Open PowerShell as Administrator and import the AD module:

powershell
Copy code
Import-Module ActiveDirectory
Place your CSV (like new_hires.csv) in the same directory as the script or specify a full path.

Notes
Passwords from the CSV are set as the initial password. By default, users are flagged to change it at first login.

Separate multiple groups with a semicolon ;.

Wrap OU paths and group lists in quotes if they contain commas or spaces.

Always test first with the -WhatIf switch before running in production.

Files
New-ADUserFromCsv.ps1 → Bulk user creation from CSV

Get-AccessReport.ps1 → Quick user/group membership report

new_hires.csv → Example CSV for provisioning

License
MIT
