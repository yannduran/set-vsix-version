BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

# Context "debug test" {

#   It "returns null" {
    # $versionNumber = '1.2.3'
    # $gitRef = 'refs/heads/master'
    # $productionRegex = ''
    # $versionRegex = ''
    # $developmentVersion = '1.0.0.1'
    # $manifestFilePath = ''

    # $result = Write-Inputs `
    #   $versionNumber `
    #   $gitRef `
    #   $productionRegex `
    #   $versionRegex `
    #   $developmentVersion `
    #   $manifestFilePath

#     $result | Should -Be $null
#   }
# }