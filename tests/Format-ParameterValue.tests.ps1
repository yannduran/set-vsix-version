BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Format-ParameterValue" {
  BeforeEach {
    $notSupplied = '<not supplied>'
  }

  Context "value is null" {
    It "returns $notSupplied" {
      $value = $null
      $result = Format-ParameterValue $value
      
      $result | Should -Be $notSupplied
    }
  }

  Context "value is empty" {
    It "returns $notSupplied" {
      $value = ''
      $result = Format-ParameterValue $value
      
      $result | Should -Be $notSupplied
    }
  }

  Context "value is not null or empty" {
    It "returns the value in single quotes" {
      $value = 'v1.2.3'
      $result = Format-ParameterValue $value
     
      $result | Should -Be "'$value'"
    }
  }
}