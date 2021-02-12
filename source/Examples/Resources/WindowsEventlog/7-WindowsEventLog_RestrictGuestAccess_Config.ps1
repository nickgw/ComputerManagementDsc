<#PSScriptInfo
.VERSION 1.0.0
.GUID 857f9f25-082e-4274-9efd-0908f49bb516
.AUTHOR DSC Community
.COMPANYNAME DSC Community
.COPYRIGHT Copyright the DSC Community contributors. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/dsccommunity/ComputerManagementDsc/blob/master/LICENSE
.PROJECTURI https://github.com/dsccommunity/ComputerManagementDsc
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES First version.
.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core
#>

#Requires -module ComputerManagementDsc

<#
    .DESCRIPTION
        Example script that prohibits guests from accessing
        the System event log.
#>
Configuration WindowsEventLog_RestrictGuestAccess_Config
{
    Import-DSCResource -ModuleName ComputerManagementDsc

    Node localhost
    {
        WindowsEventLog System
        {
            LogName             = 'System'
            RestrictGuestAccess = $true
        }
    }
}

<#
    .DESCRIPTION
        Example script that allows guests to access
        the Application event log.
#>
Configuration WindowsEventLog_RestrictGuestAccess_Config
{
    Import-DSCResource -ModuleName ComputerManagementDsc

    Node localhost
    {
        WindowsEventLog System
        {
            LogName             = 'System'
            RestrictGuestAccess = $false
        }
    }
}
