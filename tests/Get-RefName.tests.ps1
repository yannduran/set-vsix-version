BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Get-RefName" {
  Context "has version number" {
    It "returns ''" {
      $params = @{
        versionNumber = '1.2.3'
      }
      $values = Get-Values @params

      $result = Get-RefName $values

      $result| Should -BeNullOrEmpty
    }
  }

  Context "has no version number and branch ref" {
    It "returns 'branch'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/heads/master';
        developmentVersion = '1.0.0.1'
      }
      $values = Get-Values @params

      $result = Get-RefName $values

      $result | Should -Be 'branch'
    }
  }

  Context "has no version number and non-production tag" {
    It "returns 'tag'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/tags/1.2.3';
        productionRegex = $vXdotXdotX;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.2'
      }
      $values = Get-Values @params

      $result = Get-RefName $values

      $result | Should -Be 'tag'
    }
  }

  Context "has no version number and production tag" {
    It "return 'tag'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/tags/v2.3.0';
        productionRegex = $vXdotXdotX;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.3'
      }
      $values = Get-Values @params

      $result = Get-RefName $values

      $result | Should -Be 'tag'
    }
  }
}