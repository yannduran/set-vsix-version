BeforeAll {
  . ./src/vsix-version-functions.ps1
}

# instead of returning null, return actual lines so they can be tested

Describe "Write-Values" {
  Context "has version" {
    It "returns null" {
      $params = @{
        versionNumber = '1.2.3'
      }
      $values = Get-Values @params

      $result = Write-Values @values -quiet $true

      $result | Should -BeNullOrEmpty
    }
  }

  Context "has no version number and branch ref (& developmentVersion)" {
    It "returns null" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/heads/master';
        developmentVersion = '1.0.0.1'
      }
      $values = Get-Values @params

      $result = Write-Values $values -quiet $true

      $result | Should -BeNullOrEmpty
    }
  }

  Context "has no version number and non-production tag (& developmentVersion)" {
    It "returns null" {
      $params = @{
        gitRef = 'refs/tags/1.2.3';
        productionRegex = $productionVersionRegex;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.2'
      }
      $values = Get-Values @params

      $result = Write-Values $values -quiet $true

      $result | Should -BeNullOrEmpty
    }
  }

  Context "has no version number and production tag (& developmentVersion)" {
    It "refType=tag, refValue=v2.3.0, versionType=production, versionValue=2.3.0" {
      $params = @{
        gitRef = 'refs/tags/v2.3.0';
        productionRegex = $productionVersionRegex;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.3'
      }
      $values = Get-Values @params

      $result = Write-Values $values -quiet $true

      $result | Should -BeNullOrEmpty
    }
  }
}