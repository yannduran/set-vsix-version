BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

# Context "debug test" {
#   It "returns null" {
#     $refType = 'branch'
#     $refValue = 'master'
#     $versionType = 'development'
#     $versionValue = '1.0.0.1'

#     $result = Write-Values `
#       $refType `
#       $refValue `
#       $versionType `
#       $versionValue 

#     $result | Should -Be $null
#   }
# }

# Context "debug test" {
#   It "returns null" {
#     $refType = 'branch'
#     $refValue = 'master'
#     $versionType = 'development'
#     $versionValue = '1.0.0.1'

#     $result = Write-Values `
#       $refType `
#       $refValue `
#       $versionType `
#       $versionValue 

#     $result | Should -Be $null
#   }
# }

Context "debug test" {
  It "returns null" {
    $refType = 'branch'
    $refValue = 'master'
    $versionType = 'development'
    $versionValue = '1.0.0.1'

    $result = Write-Values `
      $refType `
      $refValue `
      $versionType `
      $versionValue 

    $result | Should -Be $null
  }
}