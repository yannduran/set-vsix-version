BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-ValidParameters" {
  Context "versionNumber not supplied and no missing parameters" {
    It "returns true" {
      Test-ValidParameters `
        -versonSpecified $false `
        -gitRef 'refs/heads/master' `
        -productionRegex $productionRegex `
        -developmentVersion '1.0.0.0' `
        -manifestFilePath 'test.vsixmanifest' `
        -ErrorAction Stop `
      | Should -Be $true
    }
  }
}

Describe "Test-ValidParameters" {
  Context "versionNumber not supplied and missing gitRef" {
    It "throws an ArgumentException" {
      { 
        Test-ValidParameters `
        -versonSpecified $false `
        -gitRef '' `
        -productionRegex $productionRegex `
        -developmentVersion '1.0.0.1' `
        -manifestFilePath 'test.vsixmanifest' `
        -ErrorAction Stop `
      } | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}

Describe "Test-ValidParameters" {
  Context "versionNumber not supplied and missing productionRegex" {
    It "throws an ArgumentException" {
      { 
        Test-ValidParameters `
        -versonSpecified $false `
        -gitRef '/refs/heads/master' `
        -productionRegex '' `
        -developmentVersion '1.0.0.2' `
        -manifestFilePath 'test.vsixmanifest' `
        -ErrorAction Stop `
      } | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}

Describe "Test-ValidParameters" {
  Context "versionNumber not supplied and missing developmentVersion" {
    It "throws an ArgumentException" {
      { 
        Test-ValidParameters `
        -versonSpecified $false `
        -gitRef 'refs/heads/master' `
        -productionRegex $productionRegex `
        -developmentVersion '' `
        -manifestFilePath 'test.vsixmanifest' `
        -ErrorAction Stop `
      } | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}