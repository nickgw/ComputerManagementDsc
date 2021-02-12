$script:dscModuleName = 'ComputerManagementDsc'
$script:dscResourceName = 'DSC_WindowsEventLog'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

# Begin Testing
try
{
    InModuleScope $script:dscResourceName {
        $fullParams = @{
            IsEnabled             = $true
            LogFilePath           = '%SystemRoot%\System32\Winevt\Logs\Application.evtx'
            LogMode               = 'Circular'
            LogName               = 'Application'
            LogRetentionDays      = 0
            MaximumSizeInBytes    = [System.Int64] 525074432
            RestrictGuestAccess   = $true
            SecurityDescriptor    = 'O:BAG:SYD:(A;;0x2;;;S-1-15-2-1)' + `
                '(A;;0xf0007;;;SY)(A;;0x7;;;BA)' + `
                '(A;;0x7;;;SO)(A;;0x3;;;IU)' + `
                '(A;;0x3;;;SU)(A;;0x3;;;S-1-5-3)' + `
                '(A;;0x3;;;S-1-5-33)(A;;0x1;;;S-1-5-32-573)'
            RegisteredSource      = 'PesterTest'
            CategoryResourceFile  = 'C:\WINDOWS\System32\PesterTest.dll'
            MessageResourceFile   = 'C:\WINDOWS\System32\PesterTest.dll'
            ParameterResourceFile = 'C:\WINDOWS\System32\PesterTest.dll'
        }

        $mocks = @{
            GetCimInstancePesterTestExist = New-Object -TypeName PSObject -Property @{
                LogfileName = 'Application'
                Name        = '%SystemRoot%\System32\Winevt\Logs\Application.evtx'
                Sources     = @(
                    'Application',
                    'Application Error',
                    'Application Hang',
                    'Application Management',
                    'PesterTest'
                )
            }

            GetCimInstancePesterTestNotExist = New-Object -TypeName PSObject -Property @{
                LogfileName = 'Application'
                Name        = '%SystemRoot%\System32\Winevt\Logs\Application.evtx'
                Sources     = @(
                    'Application',
                    'Application Error',
                    'Application Hang',
                    'Application Management'
                )
            }

            GetEventLogAppLogDefaults = New-Object -TypeName PSObject -Property @{
                Log                  = 'Application'
                MinimumRetentionDays = 0
            }

            GetWinEventAppLogDefaults = New-Object `
                -TypeName System.Diagnostics.Eventing.Reader.EventLogConfiguration `
                -ArgumentList 'Application' `
                -Property @{
                    IsEnabled          = $true
                    LogFilePath        = '%SystemRoot%\System32\Winevt\Logs\Application.evtx'
                    LogMode            = 'Circular'
                    MaximumSizeInBytes = [System.Int64] 525074432
                    SecurityDescriptor = 'O:BAG:SYD:(A;;0x2;;;S-1-15-2-1)' + `
                        '(A;;0xf0007;;;SY)(A;;0x7;;;BA)' + `
                        '(A;;0x7;;;SO)(A;;0x3;;;IU)' + `
                        '(A;;0x3;;;SU)(A;;0x3;;;S-1-5-3)' + `
                        '(A;;0x3;;;S-1-5-33)(A;;0x1;;;S-1-5-32-573)'
            }

            GetWELRegisteredSourceFilePesterTestExist = New-Object -TypeName PSObject -Property @{
                CategoryCount        = 1
                CategoryMessageFile  = 'C:\WINDOWS\System32\PesterTest.dll'
                EventMessageFile     = 'C:\WINDOWS\System32\PesterTest.dll'
                ParameterMessageFile = 'C:\WINDOWS\System32\PesterTest.dll'
            }
        }

        $setCasesGeneric = @(
            @{
                EventLogSetting = 'IsEnabled'
                NewValue        = $false
            }
            @{
                EventLogSetting = 'LogFilePath'
                NewValue        = '%SystemRoot%\System32\Winevt\Logs\NewApplication.evtx'
            }
            @{
                EventLogSetting = 'LogMode'
                NewValue        = 'AutoBackup'
            }
            @{
                EventLogSetting = 'MaximumSizeInBytes'
                NewValue        = 1MB
            }
            @{
                EventLogSetting = 'SecurityDescriptor'
                NewValue        = 'O:BAG:SYD:(A;;0x2;;;S-1-15-2-1)(A;;0xf0007;;;SY)(A;;0x7;;;BA)'
            }
            @{
                EventLogSetting = 'RestrictGuestAccess'
                NewValue        = $false
            }
        )

        $testCasesGeneric = @(
            @{
                EventLogSetting = 'IsEnabled'
                NewValue        = $false
            }
            @{
                EventLogSetting = 'LogFilePath'
                NewValue        = '%SystemRoot%\System32\Winevt\Logs\NewApplication.evtx'
            }
            @{
                EventLogSetting = 'LogMode'
                NewValue        = 'AutoBackup'
            }
            @{
                EventLogSetting = 'LogRetentionDays'
                NewValue        = 30
            }
            @{
                EventLogSetting = 'MaximumSizeInBytes'
                NewValue        = 1MB
            }
            @{
                EventLogSetting = 'SecurityDescriptor'
                NewValue        = 'O:BAG:SYD:(A;;0x2;;;S-1-15-2-1)(A;;0xf0007;;;SY)(A;;0x7;;;BA)'
            }
            @{
                EventLogSetting = 'RegisteredSource'
                NewValue        = 'NewPesterTest'
            }
            @{
                EventLogSetting = 'RestrictGuestAccess'
                NewValue        = $false
            }
        )

        $testCasesEventSource = @(
            @{
                EventLogSetting = 'CategoryResourceFile'
                NewValue        = 'C:\WINDOWS\System32\NewPesterTest.dll'
            }
            @{
                EventLogSetting = 'MessageResourceFile'
                NewValue        = 'C:\WINDOWS\System32\NewPesterTest.dll'
            }
            @{
                EventLogSetting = 'ParameterResourceFile'
                NewValue        = 'C:\WINDOWS\System32\NewPesterTest.dll'
            }
        )

        Describe '$($script:dscResourceName)\Get-TargetResource' -Tag 'Get' {
            Context 'When getting a request for a non-existent target resource' {
                It 'Should throw when an event log does not exist' {
                    { Get-TargetResource `
                        -LogName 'UndefinedLog' `
                        -Verbose
                    } | Should -Throw
                }
            }

            Context 'When getting the default target resource' {
                Mock -CommandName Get-EventLog {
                    return $mocks.GetEventLogAppLogDefaults
                }
                Mock -CommandName Get-WinEvent {
                    return $mocks.GetWinEventAppLogDefaults
                }

                It 'Should get the current event log configuration state' {
                    $eventLogConfiguration = Get-TargetResource `
                        -LogName 'Application' `
                        -Verbose

                    $eventLogConfiguration | Should -BeOfType Hashtable
                    $eventLogConfiguration.LogName | Should -Be 'Application'
                    $eventLogConfiguration.MaximumSizeInBytes | Should -BeOfType Int64
                    $eventLogConfiguration.IsEnabled | Should -BeOfType Boolean
                    $eventLogConfiguration.LogMode | Should -BeIn @('AutoBackup', 'Circular', 'Retain')
                    $eventLogConfiguration.LogRetentionDays | Should -BeOfType Int
                    $eventLogConfiguration.LogFilePath | Should -Not -BeNullOrEmpty
                    $eventLogConfiguration.SecurityDescriptor | Should -Not -BeNullOrEmpty
                    $eventLogConfiguration.RestrictGuestAccess | Should -BeOfType Boolean
                }

                It 'Should return empty strings for an undefined event source' {
                    Mock -CommandName Get-CimInstance {
                        return $mocks.GetCimInstancePesterTestNotExist
                    }

                    $eventLogConfiguration = Get-TargetResource `
                        -LogName 'Application' `
                        -RegisteredSource 'PesterTest' `
                        -Verbose

                    $eventLogConfiguration.RegisteredSource | Should -BeNullOrEmpty
                    $eventLogConfiguration.CategoryMessageFile | Should -BeNullOrEmpty
                    $eventLogConfiguration.MessageResourceFile | Should -BeNullOrEmpty
                    $eventLogConfiguration.ParameterResourceFile | Should -BeNullOrEmpty
                }

                It 'Should return resource file locations for a defined event source' {
                    Mock -CommandName Get-CimInstance {
                        return $mocks.GetCimInstancePesterTestExist
                    }
                    Mock -CommandName Get-ItemProperty {
                        return $mocks.GetWELRegisteredSourceFilePesterTestExist
                    }

                    $eventLogConfiguration = Get-TargetResource `
                        -LogName 'Application' `
                        -RegisteredSource 'PesterTest' `
                        -Verbose

                    $eventLogConfiguration.RegisteredSource | Should -Not -BeNullOrEmpty
                    $eventLogConfiguration.CategoryResourceFile | Should -Not -BeNullOrEmpty
                    $eventLogConfiguration.MessageResourceFile | Should -Not -BeNullOrEmpty
                    $eventLogConfiguration.ParameterResourceFile | Should -Not -BeNullOrEmpty
                }
            }
        }

        Describe '$($script:dscResourceName)\Test-TargetResource' -Tag 'Test' {
            Context 'When testing a request with a non-existent target resource' {
                It 'Should throw when an event log does not exist' {
                    { Test-TargetResource `
                        -LogName 'UndefinedLog' `
                        -Verbose
                    } | Should -Throw
                }
            }

            Context 'When testing a request with values that are out of bounds or invalid' {
                Mock -CommandName Get-EventLog {
                        return $mocks.GetEventLogAppLogDefaults
                }
                Mock -CommandName Get-WinEvent {
                    return $mocks.GetWinEventAppLogDefaults
                }

                It 'Should throw when MaximumSizeInBytes is less than 64KB' {
                    { Test-TargetResource `
                        -LogName 'Application' `
                        -MaximumSizeInBytes 0 `
                        -Verbose
                    } | Should -Throw
                }

                It 'Should throw when MaximumSizeInBytes is greater than 4GB' {
                    { Test-TargetResource `
                        -LogName 'Application' `
                        -MaximumSizeInBytes 5GB `
                        -Verbose
                    } | Should -Throw
                }

                It 'Should throw when LogMode is not a valid keyword' {
                    { Test-TargetResource `
                        -LogName 'Application' `
                        -LogMode Rectangular `
                        -Verbose
                    } | Should -Throw
                }

                It 'Should throw when LogRentionDays is less than 0' {
                    { Test-TargetResource `
                        -LogName 'Application' `
                        -LogRetentionDays -1 `
                        -Verbose
                    } | Should -Throw
                }

                It 'Should throw when LogRentionDays is greater than 365' {
                    { Test-TargetResource `
                        -LogName 'Application' `
                        -LogRetentionDays 366 -Verbose
                    } | Should -Throw
                }
            }

            Context 'When the event log is in the desired state' {
                Mock -CommandName Get-EventLog {
                    return $mocks.GetEventLogAppLogDefaults
                }
                Mock -CommandName Get-WinEvent {
                    return $mocks.GetWinEventAppLogDefaults
                }
                Mock -CommandName Get-CimInstance {
                    return $mocks.GetCimInstancePesterTestExist
                }
                Mock -CommandName Get-ItemProperty {
                    return $mocks.GetWELRegisteredSourceFilePesterTestExist
                }
                Mock -CommandName Get-WindowsEventLogRestrictGuestAccess {
                    return $true
                }

                It 'Should return true when all resources are in the desired state' {
                    $Result = Test-TargetResource @fullParams
                    $Result | Should -BeTrue
                }
            }

            Context 'When the event log is not in the desired state' {
                Mock -CommandName Get-EventLog {
                    return $mocks.GetEventLogAppLogDefaults
                }
                Mock -CommandName Get-WinEvent {
                    return $mocks.GetWinEventAppLogDefaults
                }
                Mock -CommandName Get-CimInstance {
                    return $mocks.GetCimInstancePesterTestExist
                }
                Mock -CommandName Get-ItemProperty {
                    return $mocks.GetWELRegisteredSourceFilePesterTestExist
                }
                Mock -CommandName Get-WindowsEventLogRestrictGuestAccess {
                    return $true
                }

                It 'Should return false when <EventLogSetting> setting changes are required' `
                    -TestCases $testCasesGeneric {

                    param (
                        [Parameter()]
                        $EventLogSetting,

                        [Parameter()]
                        $NewValue
                    )

                    $CaseParams = @{
                        LogName          = 'Application'
                        $EventLogSetting = $NewValue
                        Verbose          = $true
                    }

                    $Result = Test-TargetResource @CaseParams
                    $Result | Should -BeFalse
                }

                It 'Should return false when <EventLogSetting> setting changes are required' `
                    -TestCases $testCasesEventSource {

                    param (
                        [Parameter()]
                        $EventLogSetting,

                        [Parameter()]
                        $NewValue
                    )

                    $CaseParams = @{
                        LogName          = 'Application'
                        RegisteredSource = 'PesterTest'
                        $EventLogSetting = $NewValue
                        Verbose          = $true
                    }

                    $Result = Test-TargetResource @CaseParams
                    $Result | Should -BeFalse
                }
            }
        }

        Describe '$($script:dscResourceName)\Set-TargetResource' -Tag 'Set' {
            Context 'When configuration is required' {
                Mock -CommandName Get-EventLog {
                    return $mocks.GetEventLogAppLogDefaults
                }
                Mock -CommandName Get-WinEvent {
                    return $mocks.GetWinEventAppLogDefaults
                }
                Mock -CommandName New-EventLog
                Mock -CommandName Remove-EventLog
                $NewResFile = 'C:\WINDOWS\System32\NewPesterTest.dll'

                It 'Should set the <EventLogSetting> when it needs to be changed' `
                    -TestCases $setCasesGeneric {

                    param (
                        [Parameter()]
                        $EventLogSetting,

                        [Parameter()]
                        $NewValue
                    )

                    $CaseParams = @{
                        LogName          = 'Application'
                        $EventLogSetting = $NewValue
                        Verbose          = $true
                    }

                    Mock -CommandName Save-WindowsEventLog

                    Set-TargetResource @CaseParams

                    Assert-MockCalled -CommandName Save-WindowsEventLog -Times 1
                }

                It 'Should set the LogRetentionDays when it needs to be changed' `
                    -TestCases $SetCasesLogRetention {

                    Mock -CommandName Limit-EventLog

                    Set-TargetResource `
                        -LogName 'Application' `
                        -LogRetentionDays 30 `
                        -LogMode AutoBackup `
                        -Verbose

                    Assert-MockCalled -CommandName Limit-EventLog -Times 1
                }

                It 'Should set the RegisteredSource when it needs to be changed' {
                    Set-TargetResource `
                        -LogName 'Application' `
                        -RegisteredSource 'NewPesterTest' `
                        -Verbose

                    Assert-MockCalled -CommandName New-Eventlog -Times 1
                    Assert-MockCalled -CommandName Remove-EventLog  -Times 0
                }

                It 'Should set the CategoryResourceFile when it needs to be changed' {
                    Mock -CommandName Get-WindowsEventLogRegisteredSource {
                        return 'PesterTest'
                    }

                    Set-TargetResource `
                        -LogName 'Application' `
                        -RegisteredSource 'PesterTest' `
                        -CategoryResourceFile $NewResFile `
                        -Verbose

                    Assert-MockCalled -CommandName New-Eventlog -Times 1
                    Assert-MockCalled -CommandName Remove-EventLog  -Times 1
                }

                It 'Should set the MessageResourceFile when it needs to be changed' {
                    Mock -CommandName Get-WindowsEventLogRegisteredSource {
                        return 'PesterTest'
                    }

                    Set-TargetResource `
                        -LogName 'Application' `
                        -RegisteredSource 'PesterTest' `
                        -MessageResourceFile $NewResFile `
                        -Verbose

                    Assert-MockCalled -CommandName New-Eventlog -Times 1
                    Assert-MockCalled -CommandName Remove-EventLog  -Times 1
                }

                It 'Should set the ParameterResourceFile when it needs to be changed' {
                    Mock -CommandName Get-WindowsEventLogRegisteredSource {
                        return 'PesterTest'
                    }

                    Set-TargetResource `
                        -LogName 'Application' `
                        -RegisteredSource 'PesterTest' `
                        -ParameterResourceFile $NewResFile `
                        -Verbose

                    Assert-MockCalled -CommandName New-Eventlog -Times 1
                    Assert-MockCalled -CommandName Remove-EventLog  -Times 1
                }

                It 'Should set the RestrictGuestAccess and change the user-provided DACL when it needs to be changed' {
                    Mock -CommandName Get-WindowsEventLogRestrictGuestAccess {
                        return $true
                    }
                    Mock -CommandName Set-ItemProperty

                    Set-TargetResource `
                        -LogName 'Application' `
                        -SecurityDescriptor 'O:BAG:SYD:(A;;0x7;;;BA)' `
                        -RestrictGuestAccess $false `
                        -Verbose

                    Assert-MockCalled -CommandName Save-WindowsEventLog -Times 1
                    Assert-MockCalled -CommandName Set-ItemProperty -Times 1
                }

                It 'Should set the RestrictGuestAccess and change the system-level DACL when it needs to be changed' {
                    Mock -CommandName Get-WindowsEventLogRestrictGuestAccess {
                        return $true
                    }
                    Mock -CommandName Set-ItemProperty

                    Set-TargetResource `
                        -LogName 'Application' `
                        -RestrictGuestAccess $false `
                        -Verbose

                    Assert-MockCalled -CommandName Save-WindowsEventLog -Times 1
                }
            }
        }

        Describe '$($script:dscResourceName)\Get-WindowsEventLogRestrictGuestAccess' -Tag 'Helper' {
            Context 'When testing the helper function' {

                It 'Should not throw under any circumstances' {
                    { Get-WindowsEventLogRestrictGuestAccess `
                        -LogName 'UndefinedLog'
                    } | Should -Not -Throw
                }

                It 'Should return true when RestrictGuestAccess is 1' {
                    Mock -CommandName Get-ItemProperty {
                        return [PSCustomObject]@{
                            RestrictGuestAccess = 1
                        }
                    }

                    ( Get-WindowsEventLogRestrictGuestAccess `
                        -LogName 'Application'
                    ) | Should -BeTrue
                }

                It 'Should return false when RestrictGuestAccess is 0' {
                    Mock -CommandName Get-ItemProperty {
                        return [PSCustomObject]@{
                            RestrictGuestAccess = 0
                        }
                    }

                    ( Get-WindowsEventLogRestrictGuestAccess `
                        -LogName 'Application'
                    ) | Should -BeFalse
                }
            }
        }

        Describe '$($script:dscResourceName)\Get-WindowsEventLogRetentionDays' -Tag 'Helper' {
            Context 'When testing the helper function' {

                It 'Should throw when an event log does not exist' {
                    { Get-WindowsEventLogRetentionDays `
                        -LogName 'UndefinedLog'
                    } | Should -Throw
                }
            }
        }

        Describe '$($script:dscResourceName)\Register-WindowsEventLogSource' -Tag 'Helper' {
            Context 'When testing a request with values that are out of bounds or invalid' {

                It 'Should throw when CategoryResourceFile is an invalid path' {
                    { Register-WindowsEventLogSource `
                        -LogName 'Application' `
                        -SourceName 'PesterTest' `
                        -CategoryResourceFile 'foo>bar'
                    } | Should -Throw
                }

                It 'Should throw when MessageResourceFile is an invalid path' {
                    { Register-WindowsEventLogSource `
                        -LogName 'Application' `
                        -SourceName 'PesterTest' `
                        -MessageResourceFile 'foo>bar'
                    } | Should -Throw
                }

                It 'Should throw when ParameterResourceFile is an invalid path' {
                    { Register-WindowsEventLogSource `
                        -LogName 'Application' `
                        -SourceName 'PesterTest' `
                        -ParameterResourceFile 'foo>bar'
                    } | Should -Throw
                }

                It 'Should throw when the New-EventLog cmdlet encounters an error' {
                    Mock -CommandName New-EventLog { throw }

                    { Register-WindowsEventLogSource `
                        -LogName 'Application' `
                        -SourceName 'PesterTest'
                    } | Should -Throw
                }

                It 'Should throw when the Remove-EventLog cmdlet encounters an error' {
                    Mock -CommandName Remove-EventLog { throw }

                    { Register-WindowsEventLogSource `
                        -LogName 'Application' `
                        -SourceName 'PesterTest'
                    } | Should -Throw
                }
            }
        }

        Describe '$($script:dscResourceName)\Set-WindowsEventLogRestrictGuestAccess' -Tag 'Helper' {
            Context 'When testing a request with values that are out of bounds or invalid' {

                It 'Should throw when the Set-ItemProperty cmdlet encounters an error' {
                    Mock -CommandName Set-ItemProperty { throw }

                    { Set-WindowsEventLogRestrictGuestAccess `
                        -LogName 'Application' `
                        -RestrictGuestAccess $true `
                        -Sddl 'O:BAG:SYD:(A;;0x2;;;S-1-15-2-1)'
                    } | Should -Throw
                }
            }
        }

        Describe '$($script:dscResourceName)\Set-WindowsEventLogRetentionDays' -Tag 'Helper' {
            Context 'When testing a request with values that are out of bounds or invalid' {

                It 'Should throw when setting retention days in the wrong log mode' {
                    Mock -CommandName Get-EventLog { throw }

                    { Set-WindowsEventLogRetentionDays `
                        -LogName 'Application' `
                        -LogRetentionDays 30 `
                        -LogMode Circular
                    } | Should -Throw
                }

                It 'Should throw when the Get-EventLog cmdlet encounters an error' {
                    Mock -CommandName Get-EventLog { throw }

                    { Set-WindowsEventLogRetentionDays `
                        -LogName 'Application' `
                        -LogRetentionDays 30 `
                        -LogMode AutoBackup
                    } | Should -Throw
                }

                It 'Should throw when the Get-EventLog cmdlet encounters an error' {
                    Mock -CommandName Get-EventLog { throw }

                    { Set-WindowsEventLogRetentionDays `
                        -LogName 'Application' `
                        -LogRetentionDays 30 `
                        -LogMode AutoBackup
                    } | Should -Throw
                }

                It 'Should throw when the Limit-EventLog cmdlet encounters an error' {
                    Mock -CommandName Limit-EventLog { throw }

                    { Set-WindowsEventLogRetentionDays `
                        -LogName 'Application' `
                        -LogRetentionDays 30 `
                        -LogMode AutoBackup
                    } | Should -Throw
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
