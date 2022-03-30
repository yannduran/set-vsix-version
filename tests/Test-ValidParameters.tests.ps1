BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-ValidParameters" {
  Context "versionNumber not supplied and no missing parameters" {
    It "throws an ArgumentException" {
      { 
        Test-ValidParameters `
        -versonNumber '' `
        -githubRef 'refs/heads/master' `
        -productionRegex '^$' `
        -developmentVersion '1.0.0.0' `
        -manifestFilePath 'test.vsixmanifest' `
        -ErrorAction Stop `
      } | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}

Describe "Test-ValidParameters" {
  Context "versionNumber supplied and missing githubRef" {
    It "throws an ArgumentException" {
      { 
        Test-ValidParameters `
        -versonNumber '1.2.3' `
        -githubRef '' `
        -productionRegex '^$' `
        -developmentVersion '1.0.0.1' `
        -manifestFilePath 'test.vsixmanifest' `
        -ErrorAction Stop `
      } | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}

Describe "Test-ValidParameters" {
  Context "versionNumber supplied and missing productionRegex" {
    It "throws an ArgumentException" {
      { 
        Test-ValidParameters `
        -versonNumber '1.2.3' `
        -githubRef '/refs/heads/master' `
        -productionRegex '' `
        -developmentVersion '1.0.0.2' `
        -manifestFilePath 'test.vsixmanifest' `
        -ErrorAction Stop `
      } | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}

Describe "Test-ValidParameters" {
  Context "versionNumber supplied and missing developmentVersion" {
    It "throws an ArgumentException" {
      { 
        Test-ValidParameters `
        -versonNumber '1.2.3' `
        -githubRef 'refs/heads/master' `
        -productionRegex '^$' `
        -developmentVersion '' `
        -manifestFilePath 'test.vsixmanifest' `
        -ErrorAction Stop `
      } | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}