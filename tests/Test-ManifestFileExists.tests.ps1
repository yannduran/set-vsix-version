BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-ManifestFileExists" {
  Context "File doesn't exist" {
    It "Throws argument exception" {
      $manifestFilePath = "does/not/exist/test.vsixmanifest"

      { 
        Test-ManifestFileExists `
          -path $manifestFilePath `
          -ErrorAction Stop
      } | Should -Throw -ExceptionType FileNotFoundException
    }
  }

  Context "File does exist" {
    It "Returns true" {
      $manifestFilePath = "./tests/test.vsixmanifest"

      Test-ManifestFileExists `
        -path $manifestFilePath `
        -ErrorAction Stop `
      | Should -Be $true
    }
  }
}