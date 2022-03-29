BeforeAll { 
  . ./src/vsix-version-functions.ps1
  # $ErrorActionPreference = 'Stop'
}

Describe "Test-ValidInput" {
  Context "Value is null" {
    It "Returns false" {
      Test-ValidInput -value $null | Should -Be $false
    }
  }

  Context "Value is empty" {
    It "Returns false" {
      Test-ValidInput -value '' | Should -Be $false
    }
  }
}