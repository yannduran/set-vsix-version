BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Invoke-Exception" {
  It "throws exception" {
    {
      $name = 'Test'

      Invoke-Exception `
        -name $name `
        -ErrorAction Stop
    } | Should -Throw -ExceptionType Exception
  }
}