BeforeAll { 
  . ./src/set-vsix-version.ps1
}

Describe "Set-VsixVersion" {
  Context "Version supplied, with manfest file path" {
    It "Returns version set" {
      $versionNumber = "1.2.3"
      $manifestFilePath = "./tests/test.vsixmanifest"

      Set-VsixVersion `
        -versionNumber $versionNumber `
        -manifestFilePath $manifestFilePath `
        | Should -Be $versionNumber
    }
  }
}