BeforeAll {
  . ./src/vsix-version-functions.ps1

  $name = 'version-type'
  $specified = 'specified'
  $versionNumber = '1.2.3'
}

Describe "Get-Output" {
  Context "No outputs" {
    It "returns ''" {
      $params = @{
        name = $name;
        outputs = @('')
      }

      $value = Get-Output @params

      $value | Should -Be ''
    }
  }

  Context "One output value and '$name' does not exist" {
    It "returns ''" {
      $name = 'version-type'
      $specified = 'specified'
      $params = @{
        name = $name;
        outputs = @(
          "::set-output name=some-name::$specified"
        )
      }

      $value = Get-Output @params

      $value | Should -Be ''
    }
  }

  Context "One output value and '$name' exists" {
    It "returns $specified" {
      $name = 'version-type'
      $specified = 'specified'
      $params = @{
        name = $name;
        outputs = @(
          "::set-output name=version-type::$specified"
        )
      }

      $value = Get-Output @params

      $value | Should -Be $specified
    }
  }

  Context "Two output values and name does not exist" {
    It "returns ''" {
      $params = @{
        name = $name;
        outputs = @(
          "::set-output name=some-name::$specified",
          "::set-output name=version-number::$versionNumber"
        )
      }

      $value = Get-Output @params

      $value | Should -Be ''
    }
  }

  Context "Two output values and name exists (1st output)" {
    It "returns '$specified'" {
      $params = @{
        name = $name;
        outputs = @(
          "::set-output name=version-type::$specified",
          "::set-output name=version-number::$versionNumber"
        )
      }

      $value = Get-Output @params

      $value | Should -Be $specified
    }
  }

  Context "Two output values and name exists (2nd output)" {
    It "returns '$specified'" {
      $params = @{
        name = $name;
        outputs = @(
          "::set-output name=version-number::$versionNumber",
          "::set-output name=version-type::$specified"
        )
      }

      $value = Get-Output @params

      $value | Should -Be $specified
    }
  }

  Context "Three output values and name does not exist" {
    It "returns ''" {
      $params = @{
        name = $name;
        outputs = @(
          "::set-output name=name-one::$specified",
          "::set-output name=name-two::$versionNumber",
          "::set-output name=name-three::some-value"
        )
      }

      $value = Get-Output @params

      $value | Should -Be ''$specified''
    }
  }

  Context "Three output values and name exists (1st output)" {
    It "returns '$specified'" {
      $params = @{
        name = $name;
        outputs = @(
          "::set-output name=version-type::$specified",
          "::set-output name=version-number::$versionNumber",
          "::set-output name=some-name::some-value"
        )
      }

      $value = Get-Output @params

      $value | Should -Be $specified
    }
  }

  Context "Three output values and name exists (2nd output)" {
    It "returns '$specified'" {
      $params = @{
        name = $name;
        outputs = @(
          "::set-output name=version-number::$versionNumber",
          "::set-output name=version-type::$specified",
          "::set-output name=some-name::some-value"
        )
      }

      $value = Get-Output @params

      $value | Should -Be $specified
    }
  }

  Context "Three output values and name exists (3rd output)" {
    It "returns '$specified'" {
      $params = @{
        name = $name;
        outputs = @(
          "::set-output name=version-number::$versionNumber",
          "::set-output name=some-name::some-value",
          "::set-output name=version-type::$specified"
        )
      }

      $value = Get-Output @params

      $value | Should -Be $specified
    }
  }
}