BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Format-ParameterPair" {
  # BeforeEach {
  #   $notSupplied = '<not supplied>'
  # }

  Context "name is 'version-number' and width is '0'" {
    It "returns '$(" - version-number = '1.2.3'")'" {
      $name = 'version-number'
      $value = '1.2.3'
      $width = 0
      
      $result = Format-ParameterPair $name $value $width
      
      $result | Should -Be " - version-number = '1.2.3'"
    }
  }

  Context "name is 'git-ref' and width is '14'" {
    It "returns '$(" - gitref         = 'refs/heads/master'")'" {
      $name = 'git-ref'
      $value = 'refs/heads/master'
      $width = 14
      
      $result = Format-ParameterPair $name $value $width
      
      $result | Should -Be " - git-ref        = 'refs/heads/master'"
    }
  }
}