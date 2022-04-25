BeforeAll {
  . ./src/vsix-version-functions.ps1
}

Describe "Get-Values" {
  Context "has version number" {
    It "returns refName='', refValue='', versionType='specified', versionValue='1.2.3'" {

      Get-RefName $values | Should -BeNullOrEmpty
    }
  }

    It "returns refName='$branchRefName', refValue='master', versionType='development', versionValue='1.0.0.1'" {

      Get-RefName $values | Should -Be $branchRefName
    }
  }

    It "returns refName=$tagRefName, refValue=1.2.3, versionType=development, versionValue=1.0.0.2" {

      Get-RefName $values | Should -Be $tagRefName
    }
  }

    It "refName=$tagRefName, refValue=v2.3.0, versionType=production, versionValue=2.3.0" {

      Get-RefName $values | Should -Be $tagRefName
    }
  }
}