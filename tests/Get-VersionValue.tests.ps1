BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Get-VersionValue" {
  Context "has version number" {
    It "returns '1.2.3'" {
      $versionNumber = '1.2.3'
      $params = @{
        versionNumber = $versionNumber
      }

      $values = Get-Values @params

      $result = Get-VersionValue $values

      $result | Should -Be $versionNumber
    }
  }

  Context "has no version number and branch ref" {
    It "returns '1.0.0.1'" {
      $versionNumber = '1.0.0.1'
      $params = @{
        versionNumber = '';
        gitRef = 'refs/heads/master';
        developmentVersion = $versionNumber
      }
      $values = Get-Values @params

      $result = Get-VersionValue $values

      $result | Should -Be $versionNumber
    }
  }

  Context "has no version number and non-production tag" {
    It "returns '1.0.0.2'" {
      $versionNumber = '1.0.0.2'
      $params = @{
        versionNumber = '';
        gitRef = 'refs/tags/1.2.3';
        productionRegex = $productionVersionRegex;
        versionRegex = $XdotXdotX;
        developmentVersion = $versionNumber
      }
      $values = Get-Values @params

      $result = Get-VersionValue $values

      $result | Should -Be $versionNumber
    }
  }

  Context "has no version number and production tag" {
    It "return '2.3.0'" {
      $versionNumber = '2.3.0'
      $params = @{
        versionNumber = '';
        gitRef = 'refs/tags/v$versionNumber';
        productionRegex = $productionVersionRegex;
        versionRegex = $XdotXdotX;
        developmentVersion = $versionNumber
      }
      $values = Get-Values @params

      $result = Get-VersionValue $values

      $result | Should -Be $versionNumber
    }
  }
}