BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Get-VersionTypeValue" {
  Context "has version number" {
    It "returns '$versionSpecifiedValue'" {
      $params = @{
        versionNumber = '1.2.3'
      }
      $values = Get-Values @params

      $result = Get-VersionTypeValue $values

      $result| Should -Be $specifiedVersionValue
    }
  }

  Context "has no version number and branch ref" {
    It "returns '$developmentVersionValue'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/heads/master';
        developmentVersion = '1.0.0.1'
      }
      $values = Get-Values @params

      $result = Get-VersionTypeValue $values

      $result | Should -Be $developmentVersionValue
    }
  }

  Context "has no version number and non-production tag" {
    It "returns '$developmentVersionValue'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/tags/1.2.3';
        productionRegex = $vXdotXdotX;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.2'
      }
      $values = Get-Values @params

      $result = Get-VersionTypeValue $values

      $result | Should -Be $developmentVersionValue
    }
  }

  Context "has no version number and production tag" {
    It "returns '$productionVersionValue'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/tags/v2.3.0';
        productionRegex = $vXdotXdotX;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.3'
      }
      $values = Get-Values @params

      $result = Get-VersionTypeValue $values

      $result | Should -Be $productionVersionValue
    }
  }
}