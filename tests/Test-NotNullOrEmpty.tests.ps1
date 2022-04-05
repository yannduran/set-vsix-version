BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-NotNullOrEmpty" {
  Context "parameter is null" {
    It "returns false" {
      Test-NotNullOrEmpty -value $null | Should -BeFalse
    }
  }

  Context "parameter is empty" {
    It "returns false" {
      Test-NotNullOrEmpty -value '' | Should -BeFalse
    }
  }

  Context "parameter is not null or empty" {
    It "returns true" {
      Test-NotNullOrEmpty -value 'test' | Should -BeTrue
    }
  }
}