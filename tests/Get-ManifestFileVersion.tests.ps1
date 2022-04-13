BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Get-ManifestFileVersion" {
  # BeforeEach {
  #   $notSupplied = '<not supplied>'
  # }

  Context "has valid path and valid version regex" {
    It "returns a version number" {
      $path = './tests/test.vsixmanifest'
      $regex = $manifestFileRegex
      
      $result = Get-ManifestFileVersion $path $regex
      
      $result | Should -Be '0.1'
    }
  }
}