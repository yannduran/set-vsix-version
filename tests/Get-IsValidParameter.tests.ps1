BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Get-IsValidParameter" {
  Context "parameter is null and no message supplied" {
    It "returns false" {
      Get-IsValidParameter -value $null | Should -BeFalse
    }
  }

  Context "parameter is null and message supplied" {
    It "throws ArgumentException" {
      {
        Get-IsValidParameter -value $null -message $message -ErrorAction Stop
      } | Should -Throw -ExceptionType ArgumentException
    }
  }

  Context "parameter is empty and no message supplied" {
    It "returns false" {
      Get-IsValidParameter -value '' | Should -BeFalse
    }
  }

  Context "parameter is empty and message supplied" {
    It "throws ArgumentException" {
      {
        Get-IsValidParameter -value $null -message $message -ErrorAction Stop
      } | Should -Throw -ExceptionType ArgumentException
    }
  }

  Context "parameter is a string and no message supplied" {
    It "returns true" {
      Get-IsValidParameter -value 'a string' | Should -BeTrue
    }
  }
}