<#
.SYNOPSIS
Create and enable AD users from a CSV.

.DESCRIPTION
Reads a CSV with user details and creates AD accounts, sets an initial password,
adds users to groups, and enables accounts. Supports -WhatIf.

.CSV FORMAT (headers)
GivenName,Surname,SamAccountName,UserPrincipalName,OU,Groups,Password

.EXAMPLE
.\New-ADUserFromCsv.ps1 -Path .\new_hires.csv -WhatIf
.\New-ADUserFromCsv.ps1 -Path .\new_hires.csv
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$Path,

    [switch]$SkipPasswordChangeAtLogon
)

function Set-InitialPassword {
    param(
        [string]$Sam,
        [string]$Password
    )
    $secure = ConvertTo-SecureString -String $Password -AsPlainText -Force
    Set-ADAccountPassword -Identity $Sam -NewPassword $secure -Reset
    if (-not $SkipPasswordChangeAtLogon) {
        Set-ADUser -Identity $Sam -ChangePasswordAtLogon $true
    }
}

if (-not (Get-Module -ListAvailable ActiveDirectory)) {
    Write-Error "ActiveDirectory module not found. Install RSAT and try again."
    exit 1
}

Import-Module ActiveDirectory -ErrorAction Stop

if (-not (Test-Path $Path)) {
    Write-Error "CSV not found: $Path"
    exit 1
}

$rows = Import-Csv -Path $Path
if (-not $rows) {
    Write-Error "CSV is empty."
    exit 1
}

foreach ($r in $rows) {
    $given   = $r.GivenName
    $sur     = $r.Surname
    $sam     = $r.SamAccountName
    $upn     = $r.UserPrincipalName
    $ou      = $r.OU
    $groups  = $r.Groups
    $pwd     = $r.Password

    if ([string]::IsNullOrWhiteSpace($sam) -or [string]::IsNullOrWhiteSpace($ou)) {
        Write-Warning "Skipping row with missing SamAccountName or OU."
        continue
    }

    $name = "$given $sur".Trim()
    $display = $name

    $exists = Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue
    if ($exists) {
        Write-Warning "User already exists: $sam"
        continue
    }

    $params = @{
        Name               = $display
        GivenName          = $given
        Surname            = $sur
        SamAccountName     = $sam
        UserPrincipalName  = $upn
        DisplayName        = $display
        Path               = $ou
        Enabled            = $false
    }

    if ($PSCmdlet.ShouldProcess($sam, "Create AD user")) {
        try {
            New-ADUser @params
            if ($pwd) {
                Set-InitialPassword -Sam $sam -Password $pwd
            }
            Enable-ADAccount -Identity $sam
            Write-Host "Created and enabled: $sam"
        } catch {
            Write-Error "Failed to create $sam. $_"
            continue
        }
    }

    # Groups
    if ($groups) {
        $groupList = $groups -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        foreach ($g in $groupList) {
            if ($PSCmdlet.ShouldProcess("$sam -> $g", "Add to group")) {
                try {
                    $grp = Get-ADGroup -Identity $g -ErrorAction Stop
                    Add-ADGroupMember -Identity $grp.SamAccountName -Members $sam -ErrorAction Stop
                    Write-Host "  Added $sam to $g"
                } catch {
                    Write-Warning "  Could not add $sam to $g. $_"
                }
            }
        }
    }
}
