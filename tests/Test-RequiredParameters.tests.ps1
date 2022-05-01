BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Test-RequiredParameters" {
  Context "has version number but manifest file doesn't exist" {
    It "throws an FileNotFoundException" {
      $result = {
        Test-RequiredParameters `
          -versionSpecified $true `
          -gitRef '' `
          -productionRegex '' `
          -developmentVersion '' `
          -manifestFileExists $false `
          -ErrorAction Stop `
      }
      $result | Should -Throw -ExceptionType System.IO.FileNotFoundException
    }
  }

  Context "has versionNumber and manifest file exists" {
    It "returns true" {
      $result = Test-RequiredParameters `
        -versionSpecified $true `
        -gitRef '' `
        -productionRegex '' `
        -developmentVersion '' `
        -manifestFileExists $true `
        -ErrorAction Stop

      $result | Should -BeTrue
    }
  }

  Context "has no versionNumber and no missing required parameters" {
    It "returns true" {
      $result = Test-RequiredParameters `
        -versionSpecified $false `
        -gitRef 'refs/heads/master' `
        -productionRegex $productionRegex `
        -developmentVersion '1.0.0.0' `
        -manifestFileExists $true `
        -ErrorAction Stop

        $result | Should -BeTrue
    }
  }

  Context "has no versionNumber and no gitRef" {
    It "throws an ArgumentException" {
      $result = {
        Test-RequiredParameters `
          -versionSpecified $false `
          -gitRef '' `
          -productionRegex $productionRegex `
          -developmentVersion '1.0.0.1' `
          -manifestFileExists $true `
          -ErrorAction Stop `
      }
      $result | Should -Throw -ExceptionType ArgumentException
    }
  }

  Context "has no versionNumber and no productionRegex" {
    It "throws an ArgumentException" {
      $result = {
        Test-RequiredParameters `
          -versionSpecified $false `
          -gitRef '/refs/heads/master' `
          -productionRegex '' `
          -developmentVersion '1.0.0.2' `
          -manifestFileExists $true `
          -ErrorAction Stop `
      }
      $result | Should -Throw -ExceptionType ArgumentException
    }
  }

  Context "has no versionNumber and no developmentVersion" {
    It "throws an ArgumentException" {
      $result = {
        Test-RequiredParameters `
          -versionSpecified $false `
          -gitRef 'refs/heads/master' `
          -productionRegex $productionRegex `
          -developmentVersion '' `
          -manifestFileExists $true `
          -ErrorAction Stop `
      }
      $result | Should -Throw -ExceptionType ArgumentException
    }
  }
}