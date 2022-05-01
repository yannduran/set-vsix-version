BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Get-RefValue" {
  Context "has version number" {
    It "returns ''" {
      $params = @{
        versionNumber = '1.2.3'
      }
      $values = Get-Values @params

      $refValue = Get-RefValue $values

      $refValue| Should -BeNullOrEmpty
    }
  }

  Context "has no version number and branch ref" {
    It "returns 'master'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/heads/master';
        developmentVersion = '1.0.0.1'
      }
      $values = Get-Values @params

      $refValue = Get-RefValue $values

      $refValue| Should -Be 'master'
    }
  }

  Context "has no version number and non-production tag" {
    It "returns '1.2.3'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/tags/1.2.3';
        productionRegex = $productionVersionRegex;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.2'
      }
      $values = Get-Values @params

      $result = Get-RefValue $values

      $result | Should -Be '1.2.3'
    }
  }

  Context "has no version number and production tag" {
    It "return 'tag'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/tags/v2.3.0';
        productionRegex = $productionVersionRegex;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.3'
      }
      $values = Get-Values @params

      $result = Get-RefValue $values

      $result | Should -Be 'v2.3.0'
    }
  }
}