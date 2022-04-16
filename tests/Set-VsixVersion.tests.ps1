BeforeAll {
  . ./src/vsix-version-functions.ps1
  . ./src/Set-VsixVersion.ps1

  $versionNumber = '1.2.3'
}

Describe "Set-VsixVersion" {
 BeforeEach {
    Copy-Item $manifestFilePath $manifestFileBackup

    if (Test-Path $codeFilePath) {
      Copy-Item $codeFilePath $codeFileBackup
    }
 }

  Context "has version number and manifest file" {
    It "returns version-number output" {
      $params = @{
        versionNumber = $versionNumber
        gitRef = ''
        productionRegex = ''
        versionRegex = ''
        developmentVersion = ''
        manifestFilePath = $manifestFilePath
      }

      $result = Set-VsixVersion @params

      $result | Should -Be "::set-output name=version-number::$versionNumber" `
        -Because "the output variable should be set"

      $params = @{
        path = $manifestFilePath
        regex = $manifestFileRegex
      }

      $result = Get-ManifestFileVersion @params

      $result | Should -Be $versionNumber `
        -Because "the manifest file version should be set"

      $params = @{
        path = $codeFilePath
        regex = $codeFileRegex
      }

      $result = Get-CodeFileVersion @params

      $result | Should -Be $versionNumber `
        -Because "the code file version should be set"
    }
  }

  AfterEach {
    Copy-Item $manifestFileBackup $manifestFilePath

    if (Test-Path $codeFileBackup) {
      Copy-Item $codeFileBackup $codeFilePath
    }
  }
}

AfterAll {
  Remove-Item $manifestFileBackup
  Remove-Item $codeFileBackup
}