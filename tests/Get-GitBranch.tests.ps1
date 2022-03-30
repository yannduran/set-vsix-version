BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Get-GitBranch" {
  Context "supplied gitRef is null" {
    It "throws argument exception" {
      $githubRef = $null

      Get-GitBranch -githubRef $githubRef | Should -Be ''
    }
  }
}

Describe "Get-GitBranch" {
  Context "supplied githubRef is empty" {
    It "throws argument exception" {
      $githubRef = ""

      Get-GitBranch -githubRef $githubRef | Should -Be ''
    }
  }
}

Describe "Get-GitBranch" {
  Context "supplied githubRef is a branch ref" {
    It "returns the branch (master)" {
      $githubRef = "refs/heads/master"

      Get-GitBranch -githubRef $githubRef | Should -Be 'master'
    }
  }
}

Describe "Get-GitBranch" {
  Context "supplied githubRef is not a branch ref" {
    It "returns the branch (master)" {
      $githubRef = "refs/tags/master"

      Get-GitBranch -githubRef $githubRef | Should -Be ''
    }
  }
}