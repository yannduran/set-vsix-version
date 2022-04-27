BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Select-VersionNumber" {
  Context "for source that matches regex" {
    It "returns the version number" {
      $source = '1.2.3'
      $regex = $XdotXdotX

      Select-VersionNumber `
        -source $source `
        -regex $regex `
      | Should -Be $source
    }
  }

  Context "for embedded version number" {
    It "returns the extracted version number" {
      $numericVersion = '1.2.3'
      $source = "v$numericVersion"
      $regex = $XdotXdotX

      Select-VersionNumber `
        -source $source `
        -regex $regex `
      | Should -Be $numericVersion
    }
  }

  Context "for no version number" {
    It "returns an empty string" {
      $source = 'abcde'
      $regex = $XdotXdotX

      Select-VersionNumber `
        -source $source `
        -regex $regex `
      | Should -Be ''
    }
  }
}