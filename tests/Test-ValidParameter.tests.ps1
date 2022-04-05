BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-ValidParameter" {
  Context "parameter is null and no message supplied" {
    It "returns false" {
      Test-ValidParameter -value $null | Should -BeFalse
    }
  }

  Context "parameter is null and message supplied" {
    It "throws ArgumentException" {
      {
        Test-ValidParameter -value $null -message $message -ErrorAction Stop
      } | Should -Throw -ExceptionType ArgumentException
    }
  }

  Context "parameter is empty and no message supplied" {
    It "returns false" {
      Test-ValidParameter -value '' | Should -BeFalse
    }
  }

  Context "parameter is empty and message supplied" {
    It "throws ArgumentException" {
      {
        Test-ValidParameter -value $null -message $message -ErrorAction Stop
      } | Should -Throw -ExceptionType ArgumentException
    }
  }

  Context "parameter is a string and no message supplied" {
    It "returns true" {
      Test-ValidParameter -value 'a string' | Should -BeTrue
    }
  }
}