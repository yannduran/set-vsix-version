BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-ManifestFileExists" {
  Context "file doesn't exist" {
    It "throws an argument exception" {
      $manifestFileExists = $false

      $result = { 
        Test-ManifestFileExists `
          -manifestFileExists $manifestFileExists `
          -ErrorAction Stop
      } 
      
      $result | Should -Throw -ExceptionType System.IO.FileNotFoundException
    }
  }

  Context "file does exist" {
    It "returns true" {
      $manifestFileExists = $true

      $result = Test-ManifestFileExists `
        -manifestFileExists $manifestFileExists `
        -ErrorAction Stop
      
      $result | Should -Be $null -Because "'Test-ManifestFileExists' doesn't return a value"
    }
  }
}