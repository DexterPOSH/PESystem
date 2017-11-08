if(-not $ENV:BHProjectPath)
{
    Set-BuildEnvironment -Path $PSScriptRoot\..\..\..
}


Import-Module -Name ShiPS
Import-Module -Name DellPEWSMANTools
Import-Module 
Describe "PS Drive checks" {
    
    Context "PSDrive mapped correctly" {

        $PSDrive = Get-PSDrive -Name PESystem

        It "Should exist" {
            $PSDrive | Should NOT BeNullOrEmpty
        }
    }

    Context "PSDrive should contain PESystems" {

        $PESystems = Get-ChildItem -Path PESystem:\

        It "Should contain only Container objects" {
            $PESystems.ForEach({
                $PSItem.PSISContainer | Should Be $true
            })
        }
    }
}