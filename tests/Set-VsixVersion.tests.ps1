BeforeAll {
  . ./src/vsix-version-functions.ps1
  . ./src/Set-VsixVersion.ps1

  $specifiedVersion = '1.2.3'
}

Describe "Set-VsixVersion" {
  BeforeEach {
    Copy-Item $manifestFilePath $manifestFileBackup

    if (Test-Path $codeFilePath) {
      Copy-Item $codeFilePath $codeFileBackup
    }
  }

  It "returns outputs version-type & version-number" {
    $params = @{
      versionNumber = $specifiedVersion
      manifestFilePath = $manifestFilePath
    }
    $expected = @(
      "::set-output name=version-type::specified",
      "::set-output name=version-number::$specifiedVersion"
    )

    $result = Set-VsixVersion @params -quiet $true

    $result | Should -Be $expected `
      -Because "two output variables should be set"
  }

  It "sets manifest file version" {
    $params = @{
      versionNumber = $specifiedVersion
      manifestFilePath = $manifestFilePath
    }

    $output = Set-VsixVersion @params -quiet $true
    $manifestFileVersion = Get-ManifestFileVersion $manifestFilePath $manifestFileRegex

    $manifestFileVersion | Should -Be $specifiedVersion `
      -Because "the manifest file version should be set"
  }

  It "sets code file version" {
    $params = @{
      versionNumber = $specifiedVersion
      manifestFilePath = $manifestFilePath
      codeFilePath = $codeFilePath
    }

    $output = Set-VsixVersion @params -quiet $true
    $codeFileVersion = Get-CodeFileVersion $codeFilePath $codeFileRegex

    $codeFileVersion | Should -Be $specifiedVersion `
      -Because "the code file version should be set"
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