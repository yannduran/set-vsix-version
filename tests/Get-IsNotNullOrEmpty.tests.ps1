BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Get-IsNotNullOrEmpty" {
  Context "value is null and no message" {
    It "returns false" {
      Get-IsNotNullOrEmpty -value $null | Should -BeFalse
    }
  }

  Context "value is null and message supplied" {
    It "throws ArgumentException" {
      {
        Get-IsNotNullOrEmpty -value $null -message $message -ErrorAction Stop
      } | Should -Throw -ExceptionType ArgumentException
    }
  }

  Context "value is empty" {
    It "returns false" {
      Get-IsNotNullOrEmpty -value '' | Should -BeFalse
    }
  }

  Context "value is empty and message supplied" {
    It "throws ArgumentException" {
      {
        Get-IsNotNullOrEmpty -value $null -message $message -ErrorAction Stop
      } | Should -Throw -ExceptionType ArgumentException
    }
  }

  Context "value is not null or empty and no message supplied" {
    It "returns true" {
      Get-IsNotNullOrEmpty -value 'test' | Should -BeTrue
    }
  }

  Context "value is not null or empty and no message supplied" {
    It "throws ArgumentException" {
        Get-IsNotNullOrEmpty -value 'test' -message $message | Should -BeTrue
    }
  }
}