BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Format-ParameterName" {
  # BeforeEach {
  #   $notSupplied = '<not supplied>'
  # }

  Context "name is 'version-number' and width is '0'" {
    It "returns 'version-number'" {
      $name = 'version-number'
      $width = 0
      
      $result = Format-ParameterName $name $width
      
      $result | Should -Be 'version-number'
    }
  }

  Context "name is 'git-ref' and width is '14'" {
    It "returns ' - gitref        '" {
      $name = 'git-ref'
      $width = 14
      
      $result = Format-ParameterName $name $width
      
      $result | Should -Be 'git-ref       '
    }
  }
}