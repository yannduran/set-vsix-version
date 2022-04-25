BeforeAll {
  . ./src/vsix-Version-functions.ps1
}

Describe "Get-VersionTypeName" {
  Context "has version number" {
    It "returns '$versionTypeName'" {
      $params = @{
        versionNumber = '1.2.3'
      }
      $type = $versionTypeName
      $values = Get-Values @params

      $result = Get-VersionTypeName $values

      $result| Should -Be $type
    }
  }

  Context "has no version number and branch ref" {
    It "returns '$versionTypeName'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/heads/master';
        developmentVersion = '1.0.0.1'
      }
      $type = $versionTypeName
      $values = Get-Values @params

      $result = Get-VersionTypeName $values

      $result | Should -Be $type
    }
  }

  Context "has no version number and non-production tag" {
    It "returns '$versionTypeName'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/tags/1.2.3';
        productionRegex = $vXdotXdotX;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.2'
      }
      $type = $versionTypeName
      $values = Get-Values @params

      $result = Get-VersionTypeName $values

      $result | Should -Be $type
    }
  }

  Context "has no version number and production tag" {
    It "return '$versionTypeName'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/tags/v2.3.0';
        productionRegex = $vXdotXdotX;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.3'
      }
      $type = $versionTypeName
      $values = Get-Values @params

      $result = Get-VersionTypeName $values

      $result | Should -Be $type
    }
  }
}