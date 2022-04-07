BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Get-MaxNameWidth" {
  Context "has version-number and git-ref" {
    It "returns 14" {
      $params = ('version-number',''),('git-ref','')

      $result = Get-MaxNameWidth $params 
      
      $result | Should -Be 14
    }
  }

  Context "has git-ref and version-number" {
    It "returns 14" {
      $params = ('git-ref',''),('version-number','')

      $result = Get-MaxNameWidth $params 
      
      $result | Should -Be 14
    }
  }
}