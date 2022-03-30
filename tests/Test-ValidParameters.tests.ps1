BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-ValidParameters" {
  Context "versionNumber is valid and githubRef is not valid" {
    It "throws an ArgumentException" {
      { Test-ValidParameters `
        -versonNumber '1.2.3' `
        -githubRef '' `
        -productionRegex '^$' `
        -developmentVersion '1.0.0.1' `
        -manifestFilePath 'test.vsixmanifest' `
        -ErrorAction Stop } `
        | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}

Describe "Test-ValidParameters" {
  Context "versionNumber is valid and productionRegex is not valid" {
    It "throws an ArgumentException" {
      { Test-ValidParameters `
        -versonNumber '1.2.3' `
        -githubRef '/refs/heads/,aster' `
        -productionRegex '' `
        -developmentVersion '1.0.0.2' `
        -manifestFilePath 'test.vsixmanifest' `
        -ErrorAction Stop } `
        | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}

Describe "Test-ValidParameters" {
  Context "versionNumber is valid and developmentVersion is not valid" {
    It "throws an ArgumentException" {
      { Test-ValidParameters `
        -versonNumber '1.2.3' `
        -githubRef 'refs/heads/master' `
        -productionRegex '^$' `
        -developmentVersion '' `
        -manifestFilePath 'test.vsixmanifest' `
        -ErrorAction Stop } `
        | Should -Throw -ExceptionType System.ArgumentException
    }
  }
}