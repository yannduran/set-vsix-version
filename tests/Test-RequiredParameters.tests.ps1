BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-RequiredParameters" {
  Context "has version number but manifest file doesn't exist" {
    It "throws an FileNotFoundException" {
      {
        Test-RequiredParameters `
          -versionSpecified $true `
          -gitRef '' `
          -productionRegex '' `
          -developmentVersion '' `
          -manifestFileExists $false `
          -ErrorAction Stop `
      } `
      | Should -Throw -ExceptionType System.IO.FileNotFoundException
    }
  }
}

Describe "Test-RequiredParameters" {
  Context "has version number and manifest file exists" {
    It "returns true" {
        Test-RequiredParameters `
          -versionSpecified $true `
          -gitRef '' `
          -productionRegex '' `
          -developmentVersion '' `
          -manifestFileExists $true `
          -ErrorAction Stop `
      | Should -Be $true
    }
  }
}

Describe "Test-RequiredParameters" {
  Context "has no versionNumber and no missing parameters" {
    It "returns true" {
      Test-RequiredParameters `
        -versionSpecified $false `
        -gitRef 'refs/heads/master' `
        -productionRegex $vXdotXdotX `
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
          -versionSpecified $false `
          -gitRef '' `
          -productionRegex $vXdotXdotX `
          -developmentVersion '1.0.0.1' `
          -manifestFileExists $true `
          -ErrorAction Stop `
      } | Should -Throw -ExceptionType ArgumentException
    }
  }
}

Describe "Test-RequiredParameters" {
  Context "has no versionNumber and no productionRegex" {
    It "throws an ArgumentException" {
      { 
        Test-RequiredParameters `
          -versionSpecified $false `
          -gitRef '/refs/heads/master' `
          -productionRegex '' `
          -developmentVersion '1.0.0.2' `
          -manifestFileExists $true `
          -ErrorAction Stop `
      } | Should -Throw -ExceptionType ArgumentException
    }
  }
}

Describe "Test-RequiredParameters" {
  Context "has no versionNumber and no developmentVersion" {
    It "throws an ArgumentException" {
      { 
        Test-RequiredParameters `
          -versionSpecified $false `
          -gitRef 'refs/heads/master' `
          -productionRegex $vXdotXdotX `
          -developmentVersion '' `
          -manifestFileExists $true `
          -ErrorAction Stop `
      } | Should -Throw -ExceptionType ArgumentException
    }
  }
}