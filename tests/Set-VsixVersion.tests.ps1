BeforeAll { 
  . ./src/vsix-version-functions.ps1
  . ./src/Set-VsixVersion.ps1
}

Describe "Set-VsixVersion" {
  Context "has version number and manifest file" {
    It "returns null" {
      $versionNumber = '1.2.3'
      $gitRef = ''
      $productionRegex = ''
      $versionRegex = ''
      $developmentVersion = ''
      $manifestFilePath = './tests/test.vsixmanifest'

      $result = Set-VsixVersion `
        -versionNumber $versionNumber `
        -gitRef $gitRef `
        -productionRegex $productionRegex `
        -versionRegex $versionRegex `
        -developmentVersion $developmentVersion `
        -manifestFilePath $manifestFilePath
      
      $result | Should -Be "::set-output name=version-number::$versionNumber"
    }
  }
}
