BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Get-IsNullOrEmpty" {
  Context "parameter is null" {
    It "returns false" {
      Get-IsNullOrEmpty -value $null | Should -BeTrue
    }
  }

  Context "parameter is empty" {
    It "returns false" {
      Get-IsNullOrEmpty -value '' | Should -BeTrue
    }
  }

  Context "parameter is not null or empty" {
    It "returns true" {
      Get-IsNullOrEmpty -value 'test' | Should -BeFalse
    }
  }
}