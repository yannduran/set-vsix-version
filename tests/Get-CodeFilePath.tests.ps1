BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Get-CodeFilePath" {

  Context "has valid manifest file path" {
    It "returns the code file path that matches the supplied manifest file path" {
      $result = Get-CodeFilePath $manifestFilePath

      $result | Should -Be $codeFilePath
    }
  }
}