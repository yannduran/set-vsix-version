BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "New-ArgumentException" {
  It "throws argument exception" {
    { 
      $name = 'Test'

      New-ArgumentException `
        -name $name `
        -ErrorAction Stop
    } | Should -Throw -ExceptionType ArgumentException
  }
}