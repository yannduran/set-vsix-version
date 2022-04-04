      $productionRegex = $vXdotXdotX
BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Get-VersionToSet" {
  Context "has version number" {
    It "returns version number" {
      $versionNumber = '1.2.3'
      $gitRef = ''
      $productionRegex = ''
      $developmentVersion = ''

      Get-VersionToSet `
        -versionNumber $versionNumber `
        -gitRef $gitRef `
        -productionRegex $productionRegex `
        -developmentVersion $developmentVersion `
      | Should -Be $versionNumber
    }
  }
}

Describe "Get-VersionToSet" {
  Context "has no version number and branch ref" {
    It "returns development version" {
      $versionNumber = ''
      $gitRef = 'refs/heads/master'
      $productionRegex = $vXdotXdotX
      $developmentVersion = '1.0.0.1'

      Get-VersionToSet `
        -versionNumber $versionNumber `
        -gitRef $gitRef `
        -productionRegex $productionRegex `
        -developmentVersion $developmentVersion `
      | Should -Be $developmentVersion
    }
  }
}

Describe "Get-VersionToSet" {
  Context "has no version number and non-production tag" {
    It "returns development version" {
      $versionNumber = ''
      $gitRef = 'refs/tags/1.2.3'
      $productionRegex = $vXdotXdotX
      $developmentVersion = '1.0.0.2'

      Get-VersionToSet `
        -versionNumber $versionNumber `
        -gitRef $gitRef `
        -productionRegex $productionRegex `
        -developmentVersion $developmentVersion `
      | Should -Be $developmentVersion
    }
  }
}

Describe "Get-VersionToSet" {
  Context "has no version number and production tag" {
    It "returns extracted version number" {
      $versionNumber = ''
      $version = '2.3.0'
      $gitRef = 'refs/tags/v' + $version
      $productionRegex = $vXdotXdotX
      $versionRegex = $XdotXdotX
      $developmentVersion = '1.0.0.3'

      Get-VersionToSet `
        -versionNumber $versionNumber `
        -gitRef $gitRef `
        -productionRegex $productionRegex `
        -versionRegex $versionRegex `
        -developmentVersion $developmentVersion `
      | Should -Be $version
    }
  }
}