BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Get-CodeFileVersion" {
  # BeforeEach {
  #   $notSupplied = '<not supplied>'
  # }

  Context "has valid path and valid version regex" {
    It "returns a version number" {
      $path = './tests/test.cs'
      $regex = $codeFileRegex
      
      $result = Get-CodeFileVersion $path $regex
      
      $result | Should -Be '0.1'
    }
  }
}