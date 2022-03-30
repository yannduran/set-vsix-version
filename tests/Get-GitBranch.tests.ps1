BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Get-GitBranch" {
  Context "supplied gitRef is null" {
    It "throws argument exception" {
      $gitRef = $null

      Get-GitBranch -gitRef $gitRef | Should -Be ''
    }
  }
}

Describe "Get-GitBranch" {
  Context "supplied gitRef is empty" {
    It "throws argument exception" {
      $gitRef = ""

      Get-GitBranch -gitRef $gitRef | Should -Be ''
    }
  }
}

Describe "Get-GitBranch" {
  Context "supplied gitRef is a branch ref" {
    It "returns the branch (master)" {
      $gitRef = "refs/heads/master"

      Get-GitBranch -gitRef $gitRef | Should -Be 'master'
    }
  }
}

Describe "Get-GitBranch" {
  Context "supplied gitRef is not a branch ref" {
    It "returns an empty string" {
      $gitRef = "refs/tags/master"

      Get-GitBranch -gitRef $gitRef | Should -Be ''
    }
  }
}