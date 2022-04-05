BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "New-FileNotFoundException" {
  It "throws file not found exception" {
    { 
      $name = 'Test'

      New-FileNotFoundException `
        -name $name `
        -ErrorAction Stop
    } | Should -Throw -ExceptionType FileNotFoundException
  }
}