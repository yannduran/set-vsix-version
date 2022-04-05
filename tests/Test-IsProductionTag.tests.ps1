BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-IsProductionTag" {
  Context "supplied tag is null" {
    It "returns false" {
      $tag = $null

      Test-IsProductionTag -tag $tag | Should -BeFalse
    }
  }

  Context "supplied tag is empty" {
    It "returns false" {
      $tag = ''

      Test-IsProductionTag -tag $tag | Should -BeFalse
    }
  }

  Context "regex is null" {
    It "returns false" {
      $tag = ''
      $regex = $null

      Test-IsProductionTag -tag $tag -regex $regex | Should -BeFalse
    }
  }

  Context "regex is empty" {
    It "returns false" {
      $tag = ''
      $regex = ''
      Test-IsProductionTag -tag $tag -regex $regex | Should -BeFalse
    }
  }

  Context "supplied tag matches regex" {
    It "returns true" {
      $tag = "v1.2.3"
      $regex = $vXdotXdotX

      Test-IsProductionTag -tag $tag -regex $regex | Should -BeTrue
    }
  }

  Context "supplied tag does not match regex" {
    It "returns false" {
      $tag = "1.2.3"
      $regex = $vXdotXdotX

      Test-IsProductionTag -tag $tag -regex $regex | Should -BeFalse
    }
  }

  Context "supplied tag does not match regex" {
    It "returns false" {
      $tag = "1.0"
      $regex = $vXdotXdotX

      Test-IsProductionTag -tag $tag -regex $regex | Should -BeFalse
    }
  }
}