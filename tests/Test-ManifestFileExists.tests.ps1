BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-ManifestFileExists" {
  Context "file doesn't exist" {
    It "throws an argument exception" {
      $manifestFilePath = "does/not/exist/test.vsixmanifest"

      { 
        Test-ManifestFileExists `
          -path $manifestFilePath `
          -ErrorAction Stop
      } | Should -Throw -ExceptionType FileNotFoundException
    }
  }

  Context "file does exist" {
    It "returns true" {
      $manifestFilePath = "./tests/test.vsixmanifest"

      Test-ManifestFileExists `
        -path $manifestFilePath `
        -ErrorAction Stop `
      | Should -BeTrue
    }
  }
}