BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-ValidParameter" {
  Context "parameter is null" {
    It "returns false" {
      Test-ValidParameter -value $null | Should -Be $false
    }
  }

  Context "parameter is empty" {
    It "returns false" {
      Test-ValidParameter -value '' | Should -Be $false
    }
  }
}