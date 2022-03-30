BeforeAll { 
  . ./src/vsix-version-functions.ps1
}

Describe "Test-IsProductionTag" {
  Context "supplied tag is null" {
    It "returns false" {
      $tag = $null

      Test-IsProductionTag -tag $tag | Should -Be $false
      #  -productionRegex $regex
    }
  }
}

Describe "Test-IsProductionTag" {
  Context "supplied tag is empty" {
    It "returns false" {
      $tag = ""

      Test-IsProductionTag -tag $tag | Should -Be $false
    }
  }
}

Describe "Test-IsProductionTag" {
  Context "supplied tag matches regex" {
    It "returns true" {
      $tag = "v1.0.0"
      $regex = $productionRegex

      Test-IsProductionTag -tag $tag -regex $regex | Should -Be $true
    }
  }
}

Describe "Test-IsProductionTag" {
  Context "supplied tag does not match regex" {
    It "returns false" {
      $tag = "1.0"
      $regex = $productionRegex

      Test-IsProductionTag -tag $tag -regex $regex | Should -Be $false
    }
  }
}