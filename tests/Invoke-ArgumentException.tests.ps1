BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Invoke-ArgumentException" {
  It "throws argument exception" {
    { 
      $name = 'Test'

      Invoke-ArgumentException `
        -name $name `
        -ErrorAction Stop
    } | Should -Throw -ExceptionType ArgumentException
  }
}