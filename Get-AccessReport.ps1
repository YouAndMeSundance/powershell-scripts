<#
.SYNOPSIS
Quick access report for one or more AD users.

.DESCRIPTION
Shows Enabled status, Locked flag, and a semicolon list of group memberships.
Outputs objects so you can pipe to Export-Csv.

.EXAMPLE
# Single user
.\Get-AccessReport.ps1 -Identity jsena

# Multiple users
.\Get-AccessReport.ps1 -Identity jsena, mgibson, aturner

# Export to CSV
.\Get-AccessReport.ps1 -Identity jsena, mgibson | Export-Csv report.csv -NoTypeInformation
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string[]]$Identity
)

begin {
    if (-not (Get-Module -ListAvailable ActiveDirectory)) {
        Write-Error "ActiveDirectory module not found. Install RSAT and try again."
        exit 1
    }
    Import-Module ActiveDirectory -ErrorAction Stop
}

process {
    foreach ($id in $Identity) {
        try {
            $u = Get-ADUser -Identity $id -Properties LockedOut, Enabled, MemberOf
        } catch {
            Write-Warning "User not found: $id"
            continue
        }

        $groups = @()
        if ($u.MemberOf) {
            foreach ($dn in $u.MemberOf) {
                try {
                    $g = Get-ADGroup -Identity $dn
                    $groups += $g.Name
                } catch {
                    # ignore errors resolving groups
                }
            }
        }

        [pscustomobject]@{
            User    = $u.SamAccountName
            Enabled = [bool]$u.Enabled
            Locked  = [bool]$u.LockedOut
            Groups  = ($groups -join '; ')
        }
    }
}
