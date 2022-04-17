BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Get-IsProductionTag" {
  Context "supplied tag is null" {
    It "returns false" {
      $tag = $null

      Get-IsProductionTag -tag $tag | Should -BeFalse
    }
  }

  Context "supplied tag is empty" {
    It "returns false" {
      $tag = ''

      Get-IsProductionTag -tag $tag | Should -BeFalse
    }
  }

  Context "regex is null" {
    It "returns false" {
      $tag = ''
      $regex = $null

      Get-IsProductionTag -tag $tag -regex $regex | Should -BeFalse
    }
  }

  Context "regex is empty" {
    It "returns false" {
      $tag = ''
      $regex = ''
      Get-IsProductionTag -tag $tag -regex $regex | Should -BeFalse
    }
  }

  Context "supplied tag matches regex" {
    It "returns true" {
      $tag = "v1.2.3"
      $regex = $vXdotXdotX

      Get-IsProductionTag -tag $tag -regex $regex | Should -BeTrue
    }
  }

  Context "supplied tag does not match regex" {
    It "returns false" {
      $tag = "1.2.3"
      $regex = $vXdotXdotX

      Get-IsProductionTag -tag $tag -regex $regex | Should -BeFalse
    }
  }

  Context "supplied tag does not match regex" {
    It "returns false" {
      $tag = "1.0"
      $regex = $vXdotXdotX

      Get-IsProductionTag -tag $tag -regex $regex | Should -BeFalse
    }
  }
}