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
  Context "has no version number and non-production tag" {
    It "returns development version" {
      $gitRef = 'refs/tags/1.2.3'
      $developmentVersion = '1.0.0.1'

      Get-VersionToSet `
        -gitRef $gitRef `
        -productionRegex $vXdotXdotX `
        -developmentVersion $developmentVersion `
      | Should -Be $developmentVersion
    }
  }
}

Describe "Get-VersionToSet" {
  Context "has no version number and production tag" {
    It "returns tag" {
      $tag = 'v1.2.3'
      $gitRef = 'refs/tags/' + $tag

      Get-VersionToSet `
        -gitRef $gitRef `
        -productionRegex $vXdotXdotX `
        -developmentVersion $developmentVersion `
      | Should -Be $tag
    }
  }
}

Describe "Get-VersionToSet" {
  Context "has no version number and branch ref" {
    It "returns development version" {
      $gitRef = 'refs/heads/1.2.3'
      $developmentVersion = '1.0.0.1'

      Get-VersionToSet `
        -gitRef $gitRef `
        -productionRegex $vXdotXdotX `
        -developmentVersion $developmentVersion `
      | Should -Be $developmentVersion
    }
  }
}