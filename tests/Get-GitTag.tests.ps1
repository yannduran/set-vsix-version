BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Get-GitTag" {
  Context "supplied gitRef is null" {
    It "returns empty string" {
      $gitRef = $null

      Get-GitTag -gitRef $gitRef | Should -Be ''
    }
  }

  Context "supplied gitRef is empty" {
    It "returns empty string" {
      $gitRef = ""

      Get-GitTag -gitRef $gitRef | Should -Be ''
    }
  }

  Context "supplied gitRef is a tag ref" {
    It "returns the tag" {
      $gitRef = "refs/tags/v1.0"

      Get-GitTag -gitRef $gitRef | Should -Be 'v1.0'
    }
  }
 
  Context "supplied gitRef is not a tag ref" {
    It "returns empty string" {
      $gitRef = "refs/heads/master"

      Get-GitTag -gitRef $gitRef | Should -Be ''
    }
  }
}