BeforeAll { 
  . ./src/vsix-version-functions.ps1
  # $ErrorActionPreference = 'Stop'
}

Describe "Test-ValidManifest" {
  Context "File doesn't exist" {
    It "Throws argument exception" {
      $manifestFilePath = "does/not/exist/test.vsixmanifest"

      { Test-ValidManifest -path $manifestFilePath -ErrorAction Stop } | Should -Throw -ExceptionType System.ArgumentException
    }
  }

  Context "File does exist" {
    It "Returns true" {
      $manifestFilePath = "./tests/test.vsixmanifest"

      { Test-ValidManifest -path $manifestFilePath -ErrorAction Stop } | Should -Be $true}
  }
}