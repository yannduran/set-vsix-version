BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Invoke-FileNotFoundException" {
  It "throws file not found exception" {
    { 
      $name = 'Test'

      Invoke-FileNotFoundException `
        -name $name `
        -ErrorAction Stop
    } | Should -Throw -ExceptionType FileNotFoundException
  }
}