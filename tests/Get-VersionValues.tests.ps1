BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Get-VersionValues" {
  Context "has version number" {
    It "returns type=specified, versionToSet=1.2.3" {
      $versionNumber = '1.2.3'
      $gitRef = ''
      $productionRegex = ''
      $versionRegex = ''
      $developmentVersion = ''

      $result = Get-VersionValues `
        -versionNumber $versionNumber `
        -gitRef $gitRef `
        -productionRegex $productionRegex `
        -versionRegex $versionRegex `
        -developmentVersion $developmentVersion

      $result.refType | Should -BeNullOrEmpty
      $result.refValue | Should -BeNullOrEmpty
      $result.versionType | Should -Be 'specified'
      $result.versionValue | Should -Be $versionNumber
    }
  }

  Context "has no version number and branch ref" {
    It "returns type=branch, versionToSet=1.0.0.1" {
      $versionNumber = ''
      $gitRef = 'refs/heads/master'
      $productionRegex = ''
      $versionRegex = ''
      $developmentVersion = '1.0.0.1'
      
      $result = Get-VersionValues `
        -versionNumber $versionNumber `
        -gitRef $gitRef `
        -productionRegex $productionRegex `
        -versionRegex $versionRegex `
        -developmentVersion $developmentVersion

      $result.refType | Should -Be 'branch'
      $result.refValue | Should -Be 'master'
      $result.versionType | Should -Be 'development'
      $result.versionValue | Should -Be $developmentVersion
    }
  }

  Context "has no version number and non-production tag" {
    It "returns type=tag, versionToSet=1.0.0.2" {
      $versionNumber = ''
      $gitRef = 'refs/tags/1.2.3'
      $productionRegex = $vXdotXdotX
      $versionRegex = $XdotXdotX
      $developmentVersion = '1.0.0.2'
      
      $result = Get-VersionValues `
        -versionNumber $versionNumber `
        -gitRef $gitRef `
        -productionRegex $productionRegex `
        -versionRegex $versionRegex `
        -developmentVersion $developmentVersion

      $result.refType | Should -Be 'tag'
      $result.refValue | Should -Be '1.2.3'
      $result.versionType | Should -Be 'development'
      $result.versionValue | Should -Be $developmentVersion
    }
  }

  Context "has no version number and production tag" {
    It "returns type=tag, versionToSet=2.3.0" {
      $versionNumber = ''
      $gitRef = 'refs/tags/v2.3.0'
      $productionRegex = $vXdotXdotX
      $versionRegex = $XdotXdotX
      $developmentVersion = '1.0.0.3'
      
      $result = Get-VersionValues `
        -versionNumber $versionNumber `
        -gitRef $gitRef `
        -productionRegex $productionRegex `
        -versionRegex $versionRegex `
        -developmentVersion $developmentVersion

      $result.refType | Should -Be 'tag'
      $result.refValue | Should -Be 'v2.3.0'
      $result.versionType | Should -Be 'production'
      $result.versionValue | Should -Be '2.3.0'
    }
  }
}