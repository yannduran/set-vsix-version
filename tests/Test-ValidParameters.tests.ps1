BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-ValidParameters" {
  Context "versionNumber is valid, githubRef is not valid" {
    It "Throws an ArgumentException" {
      { Test-ValidInputs `
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