BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-ValidParameter" {
  Context "Parameter is null" {
    It "Returns false" {
      Test-ValidParameter -value $null | Should -Be $false
    }
  }

  Context "Parameter is empty" {
    It "Returns false" {
      Test-ValidParameter -value '' | Should -Be $false
    }
  }
}