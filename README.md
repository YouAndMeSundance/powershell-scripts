# PowerShell AD Automation

Practical PowerShell scripts for Active Directory automation. Includes:

- **New-hire provisioning from CSV**  
- **Quick access report for one or more users**  

> ⚠️ Use only in a test lab or an environment where you are authorized.  
> Requires PowerShell on a domain-joined admin workstation with the ActiveDirectory module (RSAT).

---

## Scripts

### 1) New-ADUserFromCsv.ps1
Create and enable users from a CSV. Sets name, UPN, groups, and an initial password.

**CSV headers**
GivenName,Surname,SamAccountName,UserPrincipalName,OU,Groups,Password
Jordan,Sena,jsena,jsena@corp.local
,"OU=Users,OU=Corp,DC=corp,DC=local","Domain Users;Helpdesk",P@ssw0rd!


**Run**
```powershell
# Dry run (simulates creation)
.\New-ADUserFromCsv.ps1 -Path .\new_hires.csv -WhatIf

# Live run
.\New-ADUserFromCsv.ps1 -Path .\new_hires.csv
