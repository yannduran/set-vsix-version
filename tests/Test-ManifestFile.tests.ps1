BeforeAll { 
  . ./src/vsix-version-functions.ps1
  # $ErrorActionPreference = 'Stop'
}

Describe "Test-ManifestFile" {
  Context "File doesn't exist" {
    It "Throws argument exception" {
      $manifestFilePath = "does/not/exist/test.vsixmanifest"

      # $actual | Should -Be $false
      { Test-ManifestFile -path $manifestFilePath } | Should -Throw -ExceptionType System.ArgumentException
    }
  }

  Context "File does exist" {
    It "Returns true" {
      $manifestFilePath = "./tests/test.vsixmanifest"

      # $actual | Should -Be $false
      Test-ManifestFile -path $manifestFilePath | Should -Be $true
    }
  }
}