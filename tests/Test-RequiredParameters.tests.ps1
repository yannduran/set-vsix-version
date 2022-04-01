BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-RequiredParameters" {
  Context "has version number and no manifestFilePath" {
    It "throws an ArgumentException" {
      {
        Test-RequiredParameters `
          -versonSpecified $true `
          -gitRef '' `
          -productionRegex ''$productionRegex'' `
          -developmentVersion '' `
          -manifestFileExists $false `
          -ErrorAction Stop `
      } `
      | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}

Describe "Test-RequiredParameters" {
  Context "has no manifestFilePath" {
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
  Context "has no versionNumber and no missing parameters" {
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
  Context "has no versionNumber and no gitRef" {
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
  Context "has no versionNumber and no productionRegex" {
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
  Context "has no versionNumber and no developmentVersion" {
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