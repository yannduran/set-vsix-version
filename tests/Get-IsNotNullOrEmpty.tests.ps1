BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Get-IsNotNullOrEmpty" {
  Context "parameter is null" {
    It "returns false" {
      Get-IsNotNullOrEmpty -value $null | Should -BeFalse
    }
  }

  Context "parameter is empty" {
    It "returns false" {
      Get-IsNotNullOrEmpty -value '' | Should -BeFalse
    }
  }

  Context "parameter is not null or empty" {
    It "returns true" {
      Get-IsNotNullOrEmpty -value 'test' | Should -BeTrue
    }
  }
}