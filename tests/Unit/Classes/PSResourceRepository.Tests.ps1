<#
    .SYNOPSIS
        Unit test for PSResourceRepository DSC resource.
#>

# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

try
{
    if (-not (Get-Module -Name 'DscResource.Test'))
    {
        # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
        if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
        {
            # Redirect all streams to $null, except the error stream (stream 2)
            & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
        }

        # If the dependencies has not been resolved, this will throw an error.
        Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
    }
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
}

try
{
    $script:dscModuleName = 'ComputerManagementDsc'

    Import-Module -Name $script:dscModuleName

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName

    Describe 'PSResourceRepository' {
        Context 'When class is instantiated' {
            It 'Should not throw an exception' {
                InModuleScope -ScriptBlock {
                    { [PSResourceRepository]::new() } | Should -Not -Throw
                }
            }

            It 'Should have a default or empty constructor' {
                InModuleScope -ScriptBlock {
                    $instance = [PSResourceRepository]::new()
                    $instance | Should -Not -BeNullOrEmpty
                }
            }

            It 'Should be the correct type' {
                InModuleScope -ScriptBlock {
                    $instance = [PSResourceRepository]::new()
                    $instance.GetType().Name | Should -Be 'PSResourceRepository'
                }
            }
        }
    }

    Describe 'PSResourceRepository\Get()' -Tag 'Get' {

        Context 'When the expected repo is present' {

            Mock Get-PSRepository {
                return @{
                    Name                      = 'PSGallery'
                    SourceLocation            = 'https://www.powershellgallery.com/api/v2'
                    ScriptSourceLocation      = 'https://www.powershellgallery.com/api/v2/items/psscript'
                    PublishLocation           = 'https://www.powershellgallery.com/api/v2/package/'
                    ScriptPublishLocation     = 'https://www.powershellgallery.com/api/v2/package/'
                    InstallationPolicy        = 'Untrusted'
                    PackageManagementProvider = 'NuGet'
                }
            }

            It 'Should return the correct results when ensure is Present' {
                InModuleScope -ScriptBlock {
                    $script:mockPSResourceRepositoryInstance = [PSResourceRepository] @{
                        Name                      = 'PSGallery'
                        SourceLocation            = 'https://www.powershellgallery.com/api/v2'
                        ScriptSourceLocation      = 'https://www.powershellgallery.com/api/v2/items/psscript'
                        PublishLocation           = 'https://www.powershellgallery.com/api/v2/package/'
                        ScriptPublishLocation     = 'https://www.powershellgallery.com/api/v2/package/'
                        InstallationPolicy        = 'Untrusted'
                        PackageManagementProvider = 'NuGet'
                        Ensure                    = 'Present'
                    }

                    $currentState = $script:mockPSResourceRepositoryInstance.Get()
                    $currentState.Name                      | Should -Be 'PSGallery'
                    $currentState.Ensure                    | Should -Be 'Present'
                    $currentState.SourceLocation            | Should -Be 'https://www.powershellgallery.com/api/v2'
                    $currentState.ScriptSourceLocation      | Should -Be 'https://www.powershellgallery.com/api/v2/items/psscript'
                    $currentState.PublishLocation           | Should -Be 'https://www.powershellgallery.com/api/v2/package/'
                    $currentState.ScriptPublishLocation     | Should -Be 'https://www.powershellgallery.com/api/v2/package/'
                    $currentState.InstallationPolicy        | Should -Be 'Untrusted'
                    $currentState.PackageManagementProvider | Should -Be 'NuGet'
                }
            }

            It 'Should return the correct results when ensure is Absent' {
                InModuleScope -ScriptBlock {
                    $script:mockPSResourceRepositoryInstance = [PSResourceRepository] @{
                        Name           = 'PSGallery'
                        SourceLocation = 'https://www.powershellgallery.com/api/v2'
                        Ensure         = 'Absent'
                    }

                    $currentState = $script:mockPSResourceRepositoryInstance.Get()
                    $currentState.Name                      | Should -Be 'PSGallery'
                    $currentState.Ensure                    | Should -Be 'Present'
                    $currentState.SourceLocation            | Should -Be 'https://www.powershellgallery.com/api/v2'
                    $currentState.ScriptSourceLocation      | Should -Be 'https://www.powershellgallery.com/api/v2/items/psscript'
                    $currentState.PublishLocation           | Should -Be 'https://www.powershellgallery.com/api/v2/package/'
                    $currentState.ScriptPublishLocation     | Should -Be 'https://www.powershellgallery.com/api/v2/package/'
                    $currentState.InstallationPolicy        | Should -Be 'Untrusted'
                    $currentState.PackageManagementProvider | Should -Be 'NuGet'
                }
            }

        }

        Context 'When the expected repo is absent' {
            Mock Get-PSRepository {
                return $null
            }

            It 'Should return the correct results when ensure is Present' {
                InModuleScope -ScriptBlock {
                    $script:mockPSResourceRepositoryInstance = [PSResourceRepository] @{
                        Name                      = 'PSGallery'
                        SourceLocation            = 'https://www.powershellgallery.com/api/v2'
                        ScriptSourceLocation      = 'https://www.powershellgallery.com/api/v2/items/psscript'
                        PublishLocation           = 'https://www.powershellgallery.com/api/v2/package/'
                        ScriptPublishLocation     = 'https://www.powershellgallery.com/api/v2/package/'
                        InstallationPolicy        = 'Untrusted'
                        PackageManagementProvider = 'NuGet'
                        Ensure                    = 'Present'
                    }

                    $currentState = $script:mockPSResourceRepositoryInstance.Get()
                    $currentState.Name                      | Should -Be 'PSGallery'
                    $currentState.Ensure                    | Should -Be 'Absent'
                    $currentState.SourceLocation            | Should -Be 'https://www.powershellgallery.com/api/v2'
                    $currentState.ScriptSourceLocation      | Should -BeNullOrEmpty
                    $currentState.PublishLocation           | Should -BeNullOrEmpty
                    $currentState.ScriptPublishLocation     | Should -BeNullOrEmpty
                    $currentState.InstallationPolicy        | Should -BeNullOrEmpty
                    $currentState.PackageManagementProvider | Should -BeNullOrEmpty
                }
            }

            It 'Should return the correct results when ensure is Absent' {
                InModuleScope -ScriptBlock {
                    $script:mockPSResourceRepositoryInstance = [PSResourceRepository] @{
                        Name           = 'PSGallery'
                        SourceLocation = 'https://www.powershellgallery.com/api/v2'
                        Ensure         = 'Absent'
                    }

                    $currentState = $script:mockPSResourceRepositoryInstance.Get()
                    $currentState.Name                      | Should -Be 'PSGallery'
                    $currentState.Ensure                    | Should -Be 'Absent'
                    $currentState.SourceLocation            | Should -Be 'https://www.powershellgallery.com/api/v2'
                    $currentState.ScriptSourceLocation      | Should -BeNullOrEmpty
                    $currentState.PublishLocation           | Should -BeNullOrEmpty
                    $currentState.ScriptPublishLocation     | Should -BeNullOrEmpty
                    $currentState.InstallationPolicy        | Should -BeNullOrEmpty
                    $currentState.PackageManagementProvider | Should -BeNullOrEmpty
                }
            }
        }

        Context 'When the expected repo is present but not in the correct state' {
            return @{
                Name                      = 'PSGallery'
                SourceLocation            = 'https://www.notcorrect.com/api/v2'
                ScriptSourceLocation      = 'https://www.notcorrect.com/api/v2/items/psscript'
                PublishLocation           = 'https://www.notcorrect.com/api/v2/package/'
                ScriptPublishLocation     = 'https://www.notcorrect.com/api/v2/package/'
                InstallationPolicy        = 'Trusted'
                PackageManagementProvider = 'Package'
            }

            It 'Should return the correct results when ensure is Present' {
                InModuleScope -ScriptBlock {
                    $script:mockPSResourceRepositoryInstance = [PSResourceRepository] @{
                        Name                      = 'PSGallery'
                        SourceLocation            = 'https://www.powershellgallery.com/api/v2'
                        ScriptSourceLocation      = 'https://www.powershellgallery.com/api/v2/items/psscript'
                        PublishLocation           = 'https://www.powershellgallery.com/api/v2/package/'
                        ScriptPublishLocation     = 'https://www.powershellgallery.com/api/v2/package/'
                        InstallationPolicy        = 'Untrusted'
                        PackageManagementProvider = 'NuGet'
                        Ensure                    = 'Present'
                    }

                    $currentState = $script:mockPSResourceRepositoryInstance.Get()
                    $currentState.Name                      | Should -Be 'PSGallery'
                    $currentState.Ensure                    | Should -Be 'Present'
                    $currentState.SourceLocation            | Should -Be 'https://www.notcorrect.com/api/v2'
                    $currentState.ScriptSourceLocation      | Should -Be 'https://www.notcorrect.com/api/v2/items/psscript'
                    $currentState.PublishLocation           | Should -Be 'https://www.notcorrect.com/api/v2/package/'
                    $currentState.ScriptPublishLocation     | Should -Be 'https://www.notcorrect.com/api/v2/package/'
                    $currentState.InstallationPolicy        | Should -Be 'Trusted'
                    $currentState.PackageManagementProvider | Should -Be 'Package'
                }
            }

            It 'Should return the correct results when ensure is Absent' {
                InModuleScope -ScriptBlock {
                    $script:mockPSResourceRepositoryInstance = [PSResourceRepository] @{
                        Name                      = 'PSGallery'
                        SourceLocation            = 'https://www.powershellgallery.com/api/v2'
                        Ensure                    = 'Absent'
                    }

                    $currentState = $script:mockPSResourceRepositoryInstance.Get()
                    $currentState.Name                      | Should -Be 'PSGallery'
                    $currentState.Ensure                    | Should -Be 'Present'
                    $currentState.SourceLocation            | Should -Be 'https://www.notcorrect.com/api/v2'
                    $currentState.ScriptSourceLocation      | Should -Be 'https://www.notcorrect.com/api/v2/items/psscript'
                    $currentState.PublishLocation           | Should -Be 'https://www.notcorrect.com/api/v2/package/'
                    $currentState.ScriptPublishLocation     | Should -Be 'https://www.notcorrect.com/api/v2/package/'
                    $currentState.InstallationPolicy        | Should -Be 'Trusted'
                    $currentState.PackageManagementProvider | Should -Be 'Package'
                }
            }
        }

        Context 'When the system is in the desired state' {
            Context 'When the repository should be Present' {

                Mock Get-PSRepository {
                    return @{
                        Name                      = 'PSGallery'
                        SourceLocation            = 'https://www.powershellgallery.com/api/v2'
                        ScriptSourceLocation      = 'https://www.powershellgallery.com/api/v2/items/psscript'
                        PublishLocation           = 'https://www.powershellgallery.com/api/v2/package/'
                        ScriptPublishLocation     = 'https://www.powershellgallery.com/api/v2/package/'
                        InstallationPolicy        = 'Untrusted'
                        PackageManagementProvider = 'NuGet'
                    }
                }

                It 'Should return the correct result when the Repository is present and all params are passed' {

                    InModuleScope -ScriptBlock {
                        $script:mockPSResourceRepositoryInstance = [PSResourceRepository] @{
                            Name                      = 'PSGallery'
                            SourceLocation            = 'https://www.powershellgallery.com/api/v2'
                            ScriptSourceLocation      = 'https://www.powershellgallery.com/api/v2/items/psscript'
                            PublishLocation           = 'https://www.powershellgallery.com/api/v2/package/'
                            ScriptPublishLocation     = 'https://www.powershellgallery.com/api/v2/package/'
                            InstallationPolicy        = 'Untrusted'
                            PackageManagementProvider = 'NuGet'
                        }

                        $currentState = $script:mockPSResourceRepositoryInstance.Get()
                        $currentState.Name                      | Should -Be 'PSGallery'
                        $currentState.Ensure                    | Should -Be 'Present'
                        $currentState.SourceLocation            | Should -Be 'https://www.powershellgallery.com/api/v2'
                        $currentState.ScriptSourceLocation      | Should -Be 'https://www.powershellgallery.com/api/v2/items/psscript'
                        $currentState.PublishLocation           | Should -Be 'https://www.powershellgallery.com/api/v2/package/'
                        $currentState.ScriptPublishLocation     | Should -Be 'https://www.powershellgallery.com/api/v2/package/'
                        $currentState.InstallationPolicy        | Should -Be 'Untrusted'
                        $currentState.PackageManagementProvider | Should -Be 'NuGet'
                    }
                }

                It 'Should return the correct result when the Repository is present and the minimum params are passed' {
                    Mock Get-PSRepository {
                        return @{
                            Name                      = 'PSGallery'
                            SourceLocation            = 'https://www.powershellgallery.com/api/v2'
                            ScriptSourceLocation      = 'https://www.powershellgallery.com/api/v2/items/psscript'
                            PublishLocation           = 'https://www.powershellgallery.com/api/v2/package/'
                            ScriptPublishLocation     = 'https://www.powershellgallery.com/api/v2/package/'
                            InstallationPolicy        = 'Untrusted'
                            PackageManagementProvider = 'NuGet'
                        }
                    }

                    InModuleScope -ScriptBlock {
                        $script:mockPSResourceRepositoryInstance = [PSResourceRepository] @{
                            Name           = 'PSGallery'
                            SourceLocation = 'https://www.powershellgallery.com/api/v2'
                            Ensure         = 'Absent'
                        }
                        $currentState = $script:mockPSResourceRepositoryInstance.Get()
                        $currentState.Name                      | Should -Be 'PSGallery'
                        $currentState.Ensure                    | Should -Be 'Present'
                        $currentState.SourceLocation            | Should -Be 'https://www.powershellgallery.com/api/v2'
                        $currentState.ScriptSourceLocation      | Should -Be 'https://www.powershellgallery.com/api/v2/items/psscript'
                        $currentState.PublishLocation           | Should -Be 'https://www.powershellgallery.com/api/v2/package/'
                        $currentState.ScriptPublishLocation     | Should -Be 'https://www.powershellgallery.com/api/v2/package/'
                        $currentState.InstallationPolicy        | Should -Be 'Untrusted'
                        $currentState.PackageManagementProvider | Should -Be 'NuGet'
                    }
                }
            }

            Context 'When the respository should be Absent' {
                It 'Should return the correct result when the Repository is Absent' {
                    InModuleScope -ScriptBlock {
                        Mock Get-PSRepository {
                            return $null
                        }

                        $script:mockPSResourceRepositoryInstance = [PSResourceRepository] @{
                                Name           = 'PSGallery'
                                Ensure         = 'Absent'
                                SourceLocation = 'https://www.powershellgallery.com/api/v2'
                            }

                        $currentState = $script:mockPSResourceRepositoryInstance.Get()
                        $currentState.Name                      | Should -Be 'PSGallery'
                        $currentState.SourceLocation            | Should -Be 'https://www.powershellgallery.com/api/v2'
                        $currentState.Ensure                    | Should -Be 'Absent'
                        $currentState.InstallationPolicy        | Should -BeNullOrEmpty
                        $currentState.ScriptSourceLocation      | Should -BeNullOrEmpty
                        $currentState.PublishLocation           | Should -BeNullOrEmpty
                        $currentState.ScriptPublishLocation     | Should -BeNullOrEmpty
                        $currentState.PackageManagementProvider | Should -BeNullOrEmpty
                    }
                }
            }
        }

        Context 'When the system is not in the desired state' {
            Context 'When the repository is present but should be absent' {
                It 'Should return the correct value' {
                    Mock Get-PSRepository {
                        return @{
                            Name                      = 'PSGallery'
                            SourceLocation            = 'https://www.powershellgallery.com/api/v2'
                            ScriptSourceLocation      = 'https://www.powershellgallery.com/api/v2/items/psscript'
                            PublishLocation           = 'https://www.powershellgallery.com/api/v2/package/'
                            ScriptPublishLocation     = 'https://www.powershellgallery.com/api/v2/package/'
                            InstallationPolicy        = 'Untrusted'
                            PackageManagementProvider = 'NuGet'
                        }
                    }

                    InModuleScope -ScriptBlock {
                        $script:mockPSResourceRepositoryInstance = [PSResourceRepository] @{
                            Name           = 'PSGallery'
                            SourceLocation = 'https://www.powershellgallery.com/api/v2'
                            Ensure         = 'Absent'
                        }
                        $currentState = $script:mockPSResourceRepositoryInstance.Get()
                        $currentState.Name                      | Should -Be 'PSGallery'
                        $currentState.Ensure                    | Should -Be 'Present'
                        $currentState.SourceLocation            | Should -Be 'https://www.powershellgallery.com/api/v2'
                        $currentState.ScriptSourceLocation      | Should -Be 'https://www.powershellgallery.com/api/v2/items/psscript'
                        $currentState.PublishLocation           | Should -Be 'https://www.powershellgallery.com/api/v2/package/'
                        $currentState.ScriptPublishLocation     | Should -Be 'https://www.powershellgallery.com/api/v2/package/'
                        $currentState.InstallationPolicy        | Should -Be 'Untrusted'
                        $currentState.PackageManagementProvider | Should -Be 'NuGet'
                    }
                }
            }

            Context 'When the repository is absent but should be present' {
                InModuleScope -ScriptBlock {
                    Mock Get-PSRepository {
                        return $null
                    }

                    $script:mockPSResourceRepositoryInstance = [PSResourceRepository] @{
                        Name           = 'PSGallery'
                        SourceLocation = 'https://www.powershellgallery.com/api/v2'
                        Ensure         = 'Present'
                    }
                    $currentState = $script:mockPSResourceRepositoryInstance.Get()
                    $currentState.Name                      | Should -Be 'PSGallery'
                    $currentState.Ensure                    | Should -Be 'Absent'
                    $currentState.SourceLocation            | Should -Be 'https://www.powershellgallery.com/api/v2'
                    $currentState.ScriptSourceLocation      | Should -BeNullOrEmpty
                    $currentState.PublishLocation           | Should -BeNullOrEmpty
                    $currentState.ScriptPublishLocation     | Should -BeNullOrEmpty
                    $currentState.InstallationPolicy        | Should -BeNullOrEmpty
                    $currentState.PackageManagementProvider | Should -BeNullOrEmpty
                }
            }
        }
    }

    Describe 'PSResourceRepository\Set()' -Tag 'Set' {
        Context 'When the system is in the desired state' {
        }

        Context 'When the system is not in the desired state' {
        }
    }

    Describe 'PSResourceRepository\Test()' -Tag 'Test' {
        Context 'When the system is in the desired state' {
        }

        Context 'When the system is not in the desired state' {
        }
    }

    Describe 'PSResourceRepository\GetCurrentState()' -Tag 'GetCurrentState' {
    }

    Describe 'PSResourceRepository\Modify()' -Tag 'Modify' {
        Context 'When the system is not in the desired state' {
        }
    }

    Describe 'PSResourceRepository\AssertProperties()' -Tag 'AssertProperties' {
    }
}
finally
{
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}
