BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Get-Values" {
  Context "has version number" {
    It "returns refName='', refValue='', versionType='specified', versionValue='1.2.3'" {
      $params = @{
        versionNumber = '1.2.3'
      }
      $values = Get-Values @params

      Get-RefName $values | Should -BeNullOrEmpty
      Get-RefValue $values | Should -BeNullOrEmpty
    }
  }

  Context "has no version number and branch ref (& developmentVersion)" {
    It "returns refName='$branchRefName', refValue='master', versionType='development', versionValue='1.0.0.1'" {
      $params = @{
        versionNumber = '';
        gitRef = 'refs/heads/master';
        developmentVersion = '1.0.0.1'
      }
      $values = Get-Values @params

      Get-RefName $values | Should -Be $branchRefName
      Get-RefValue $values | Should -Be 'master'
    }
  }

  Context "has no version number and non-production tag (& developmentVersion)" {
    It "returns refName=$tagRefName, refValue=1.2.3, versionType=development, versionValue=1.0.0.2" {
      $params = @{
        gitRef = 'refs/tags/1.2.3';
        productionRegex = $vXdotXdotX;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.2'
      }
      $values = Get-Values @params

      Get-RefName $values | Should -Be $tagRefName
      Get-RefValue $values | Should -Be '1.2.3'
    }
  }

  Context "has no version number and production tag (& developmentVersion)" {
    It "refName=$tagRefName, refValue=v2.3.0, versionType=production, versionValue=2.3.0" {
      $params = @{
        gitRef = 'refs/tags/v2.3.0';
        productionRegex = $vXdotXdotX;
        versionRegex = $XdotXdotX;
        developmentVersion = '1.0.0.3'
      }
      $values = Get-Values @params

      Get-RefName $values | Should -Be $tagRefName
      Get-RefValue $values | Should -Be 'v2.3.0'
    }
  }
}