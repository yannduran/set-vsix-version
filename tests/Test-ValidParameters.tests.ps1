BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-RequiredParameters" {
  Context "manifestFilePath is not supplied" {
    It "throws an ArgumentException" {
      {
        Test-RequiredParameters `
          -versonSpecified $false `
          -gitRef 'refs/heads/master' `
          -productionRegex $productionRegex `
          -developmentVersion '1.0.0.0' `
          -manifestFileExists $false `
          -ErrorAction Stop `
      } `
      | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}

Describe "Test-RequiredParameters" {
  Context "versionNumber not supplied and no missing parameters" {
    It "returns true" {
      Test-RequiredParameters `
        -versonSpecified $false `
        -gitRef 'refs/heads/master' `
        -productionRegex $productionRegex `
        -developmentVersion '1.0.0.0' `
        -manifestFileExists $true `
        -ErrorAction Stop `
      | Should -Be $true
    }
  }
}

Describe "Test-RequiredParameters" {
  Context "versionNumber not supplied and missing gitRef" {
    It "throws an ArgumentException" {
      { 
        Test-RequiredParameters `
          -versonSpecified $false `
          -gitRef '' `
          -productionRegex $productionRegex `
          -developmentVersion '1.0.0.1' `
          -manifestFileExists $true `
          -ErrorAction Stop `
      } | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}

Describe "Test-RequiredParameters" {
  Context "versionNumber not supplied and missing productionRegex" {
    It "throws an ArgumentException" {
      { 
        Test-RequiredParameters `
          -versonSpecified $false `
          -gitRef '/refs/heads/master' `
          -productionRegex '' `
          -developmentVersion '1.0.0.2' `
          -manifestFileExists $true `
          -ErrorAction Stop `
      } | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}

Describe "Test-RequiredParameters" {
  Context "versionNumber not supplied and missing developmentVersion" {
    It "throws an ArgumentException" {
      { 
        Test-RequiredParameters `
          -versonSpecified $false `
          -gitRef 'refs/heads/master' `
          -productionRegex $productionRegex `
          -developmentVersion '' `
          -manifestFileExists $true `
          -ErrorAction Stop `
      } | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}