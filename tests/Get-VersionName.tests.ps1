BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Get-VersionName" {
  Context "has version number" {
    It "returns '$versionNameString'" {
      $params = @{
        versionNumber = '1.2.3'
      }
      $values = Get-Values @params

      $result = Get-VersionName $values

      $result| Should -Be $versionNameString
    }
  }

  Context "has no version number and branch ref" {
    It "returns '$versionNameString'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/heads/master';
        developmentVersion = '1.0.0.1'
      }
      $values = Get-Values @params

      $result = Get-VersionName $values

      $result | Should -Be $versionNameString
    }
  }

  Context "has no version number and non-production tag" {
    It "returns '$versionNameString'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/tags/1.2.3';
        productionRegex = $productionRegex;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.2'
      }
      $values = Get-Values @params

      $result = Get-VersionName $values

      $result | Should -Be $versionNameString
    }
  }

  Context "has no version number and production tag" {
    It "return '$versionNameString'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/tags/v2.3.0';
        productionRegex = $productionRegex;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.3'
      }
      $values = Get-Values @params

      $result = Get-VersionName $values

      $result | Should -Be $versionNameString
    }
  }
}