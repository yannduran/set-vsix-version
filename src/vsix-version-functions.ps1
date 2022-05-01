#region usings
  using namespace System
  using namespace System.IO
  using namespace System.IO.Path
  using namespace System.Text.RegularExpressions
  using namespace Collections.Generic
  using namespace Microsoft.PowerShell.Commands
#endregion usings

#region constant values
  $dateFormat = 'yyyy-MMM-dd HH:mm:ss'
  $tags = 'refs/tags/'
  $heads = 'refs/heads/'

  $XdotXdotX = "[0-9]+.[0-9]+.[0-9]"
  $productionVersionRegex = "^v" + $XdotXdotX + "$"

  $versionRegex = '([0-9\\.]+)'
  $manifestFileRegex = 'Version="' + $versionRegex + '" Language='
  $codeFileRegex = 'Version = "' + $versionRegex + '"'

  $testsFolder = './tests/'

  $manifestFilePath = $testsFolder + 'test.vsixmanifest'
  $manifestFileBackup = $manifestFilePath + '.bak'
  $codeFilePath = [System.IO.Path]::ChangeExtension($manifestFilePath, '.cs')
  $codeFileBackup = $codeFilePath + '.bak'

  $versionTypeString = 'type'
  $versionNameString = 'version'

  $specifiedVersionString = 'specified'
  $developmentVersionString = 'development'
  $productionVersionString = 'production'

  $branchRefName = 'branch'
  $tagRefName = 'tag'

#endregion constant values

#region functions
  function Format-ParameterName {
    param(
      [string] $name,
      [int] $width
    )
    return $name.PadRight($width)
  }

  function Format-ParameterValue {
    param(
      [string] $parameter
    )
    if (($parameter -eq $null) -or ($parameter -eq '')) {
      return '<not supplied>'
    }

    return "'$parameter'"
  }

  function Format-ParameterPair {
    param(
      [string] $name,
      [string] $value,
      [int] $width
    )
    $formattedName = Format-ParameterName $name $width
    $formattedValue = Format-ParameterValue $value

    return " - $($formattedName) = $($formattedValue)"
  }

  function Get-CodeFilePath {
    param(
      $manifestFilePath
      )
    $result = [System.IO.Path]::ChangeExtension($manifestFilePath, '.cs')

    return $result
  }

  function Get-CodeFileVersion {
    param(
      [string] $path,
      [string] $regex
    )

    $value = select-string -Path $path -Pattern $regex |
      ForEach-Object { $_.Matches } |
      ForEach-Object { $_.Value }

    $valid = Get-IsNotNullOrEmpty $value
    if ($valid -eq $false) {
      return ''
    }

    return $(Get-TextBetween($value))
  }

  function Get-GitBranch {
    param(
      $gitRef
    )
    $valid = Get-IsNotNullOrEmpty($gitRef)
    if ($valid -eq $false) { return '' }

    $valid = ($gitRef.StartsWith($heads))
    if ($valid -eq $true) {
      return $gitRef.Replace($heads,'')
    }

    return ''
  }

  function Get-GitTag {
    param(
      $gitRef
    )
    $valid = Get-IsNotNullOrEmpty($gitRef)

    if ($valid -eq $false) { return '' }

    if ($gitRef.StartsWith($tags)) {
      return $gitRef.Replace($tags,'')
    }
    else {
      return ''
    }
  }

  function Get-IsNullOrEmpty {
    [OutputType([boolean])]
    param(
      $value
    )
    return (($null -eq $value) -or ($value -eq ''))
  }

  function Get-IsNotNullOrEmpty {
    [OutputType([boolean])]
    param(
      $value,
      $message = ''
    )
    $result = !(Get-IsNullOrEmpty($value))

    if ($result -eq $true) {
      return $true
    }

    if ($message -eq '') {
        return $false
    }
    else {
      Invoke-ArgumentException $message
    }
  }

  function Get-IsProductionTag {
    param(
      $tag,
      $regex = ''
    )
    $validTag = Get-IsNotNullOrEmpty $tag
    $validRegex = Get-IsNotNullOrEmpty $regex
    if (($validTag -eq $false) -or ($validRegex -eq $false))
    {
      return $false
    }

    return ($tag -match $regex)
  }

  function Get-ManifestFileVersion {
    param(
      [string] $path,
      [string] $regex
      )

    $value = select-string -Path $path -Pattern $regex |
      ForEach-Object { $_.Matches } |
      ForEach-Object { $_.Value }
    $valid = Get-IsNotNullOrEmpty $value

    if ($valid -eq $false) {
      return ''
    }

    $version = Get-TextBetween($value.Replace(' Language=',''))

    return $version
  }

  function Get-MaxNameWidth {
    param(
      [array]$params
    )
    $maxWidth = 0

    foreach ($param in $params) {
      $text = $param[0]
      $length = $text.Length

      if ($length -gt $maxWidth) {
        $maxWidth = $length
      }
    }

    return $maxWidth
  }

  function Get-Output {
    param(
      $name,
      $outputs
    )
    $nameValue = "::set-output name=$name::"
    $nameLength = $nameValue.Length
    $value = ''

    foreach($output in $outputs){
      $index = $output.IndexOf($nameValue)

      if ($index -ne -1){
        $value = $output.Substring($index + $nameLength)
        break;
      }
    }

    return $value
  }

  function Get-RefName {
    param(
      $values
    )

    return $values[0][0]
  }

  function Get-RefValue {
    param(
      $values
    )

    return $values[0][1]
  }

  function Get-TextBetween {
  # https://powershellone.wordpress.com/2021/02/24/using-powershell-and-regex-to-extract-text-between-delimiters/

    param(
      [string] $Text,
      [char]   $delimeter = '"'
    )
    $pattern = "(?<=\$delimeter).+?(?=\$delimeter)"

    return [regex]::Matches($Text, $pattern).Value
  }

  function Get-Values {
    param(
      $versionNumber = '',
      $gitRef = '',
      $productionRegex = '',
      $versionRegex = '',
      $developmentVersion = ''
    )
    $isSpecified = Get-IsNotNullOrEmpty $versionNumber

    if ($isSpecified -eq $true) {
      $refName = ''
      $refValue = ''
      $versionTypeValue = 'specified'
      $versionToSet = $versionNumber
    }
    else {
      $branch = Get-GitBranch $gitRef
      $isBranch = Get-IsNotNullOrEmpty $branch
      $tag = Get-GitTag $gitRef
      $isTag = Get-IsNotNullOrEmpty $tag

      if ($isBranch -eq $true) {
        $refName = $branchRefName
        $refValue = $branch
        $versionTypeValue = 'development'
        $versionToSet = $developmentVersion
      }

      if ($isTag -eq $true) {
        $refName = $tagRefName
        $refValue = $tag

        $isProduction = Get-IsProductionTag $tag $productionRegex
        $isDevelopment = (!$isProduction)

        if ($isProduction -eq $true) {
          $versionTypeValue = 'production'
          $versionToSet = Select-VersionNumber -source $tag -regex $versionRegex

          $versionExtracted = Get-IsNotNullOrEmpty $versionToSet

          if ($versionExtracted -eq $false){
            $message = "Tag '$tag' does not contain a version number using '$versionRegex'"

            Invoke-ArgumentException $message
          }
        }

        if ($isDevelopment -eq $true) {
          $versionTypeValue = 'development'
          $versionToSet = $developmentVersion
        }
      }
    }
    # $valid = Get-IsNotNullOrEmpty $versionToSet

    if (Get-IsNullOrEmpty $versionToSet) {
      Invoke-Exception '$versionToSet has no value!'
    }

    $values = `
      ($refName, $refValue), `
      ($versionTypeString, $versionTypeValue), `
      ($versionNameString, $versionToSet)

    return $values
  }

  function Get-VersionTypeName {
    param(
      $values
    )

    return $values[1][0]
  }

  function Get-VersionTypeValue {
    param(
      $values
    )

    return $values[1][1]
  }

  function Get-VersionName {
    param(
      $values
    )

    return $values[2][0]
  }

  function Get-VersionValue {
    param(
      $values
    )

    return $values[2][1]
  }

  function Select-VersionNumber {
    param(
      $source,
      $regex
    )
    $numericVersion = $source | Select-String -Pattern $regex

    try {
      $versionNumber = $numericVersion.Matches[0].Value
    }
    catch {
      return ''
    }

    return $versionNumber
  }

  function Invoke-Exception {
    param(
      $message
    )
    Write-Error -Exception ([ArgumentException]::new($message)) -ErrorAction Stop
  }

  function Invoke-ArgumentException {
    param(
      $name
    )
    Write-Error -Exception ([ArgumentException]::new("The '$name' parameter was not provided")) -ErrorAction Stop
  }

  function Invoke-FileNotFoundException {
    param(
      $path
    )
    Write-Error -Exception ([FileNotFoundException]::new("The file '$path' was not found")) -ErrorAction Stop
  }

  function Set-CodeFileVersion {
    param(
      $codeFilePath,
      $codeFileRegex,
      $versionRegex,
      $versionToSet
    )
    $versionBefore = Get-CodeFileVersion $codeFilePath $codeFileRegex $versionRegex

    $content = [string]::join([environment]::newline, (get-content $codeFilePath))
    $regex = New-Object Regex $codeFileRegex

    $newVersion = 'Version = "' + $versionToSet + '"'
    $regex.Replace($content, $newVersion) | Out-File $codeFilePath

    $versionAfter = Get-CodeFileVersion $codeFilePath $codeFileRegex $versionRegex

    return (
      ('before', $versionBefore),
      ('after', $versionAfter)
    )
  }

  function Set-ManifestFileVersion {
    param(
      $manifestFilePath,
      $manifestFileRegex,
      $versionToSet
    )
    $versionBefore = Get-ManifestFileVersion $manifestFilePath $manifestFileRegex

    $content = [string]::join([environment]::newline, (get-content $manifestFilePath))
    $regex = New-Object Regex $manifestFileRegex

    $newVersion = 'Version="' + $versionToSet + '" Language='
    $regex.Replace($content, $newVersion) | Out-File $manifestFilePath

    $versionAfter = Get-ManifestFileVersion $manifestFilePath $manifestFileRegex

    return (
      ('before', $versionBefore),
      ('after', $versionAfter)
    )
  }

  function Set-Output {
    param(
      $name,
      $value
    )
    Write-Output "::set-output name=$name::$value"
  }

  function Write-CodeFileResults {
    param(
      [array]$params,
      [boolean] $quiet = $false
    )

    if ($codeFileExists -eq $true) {
        Write-NameValuePairs $params -quiet $quiet
      }
    }

  function Write-DatedMessage {
    param(
      [string] $prefix,
      [boolean] $quiet = $false
    )

    if ($quiet -eq $false) {
      Write-Host "INFO: ${prefix} $(Get-Date -Format $dateFormat)" -ForegroundColor Magenta
    }
  }

  function Write-ErrorMessage {
    param(
      [string] $message,
      [boolean] $quiet = $false
    )

    if ($quiet -eq $false) {
      Write-Host "ERROR: ${message}" -ForegroundColor Yellow
    }
  }

  function Write-ExceptionMessage {
    param(
      [string] $message,
      [boolean] $quiet = $false
    )

    if ($quiet -eq $false) {
      Write-Host "EXCEPTION: ${message}" -ForegroundColor Red
    }
  }

  function Write-InfoMessage {
    param(
      [string] $message,
      [boolean] $quiet = $false
    )

    if ($quiet -eq $false) {
      Write-Host "INFO: ${message}" -ForegroundColor Magenta
    }
  }

  function Write-Header {
    param(
      $header,
      $character = '-',
      [boolean] $quiet = $false
    )

    $length = $header.Length
    $line = ''.PadRight($length, $character) # $character * $length

    Write-InfoMessage $line -quiet $quiet
    Write-InfoMessage $header -quiet $quiet
    Write-InfoMessage $line -quiet $quiet
  }

  function Write-Inputs {
    param(
      $versionNumber,
      $gitRef,
      $productionRegex,
      $versionRegex,
      $developmentVersion,
      $manifestFilePath,
      [boolean] $quiet = $false
    )

    $inputs = `
      ('version-number', $versionNumber), `
      ('git-ref', $gitRef), `
      ('production-regex', $productionRegex), `
      ('version-regex', $versionRegex), `
      ('development-version', $developmentVersion), `
      ('manifest-file-path', $manifestFilePath)

    Write-NameValuePairs $inputs -quiet $quiet
  }

  function Write-ManifestFileResults {
    param(
      [array]$params,
      [boolean] $quiet = $false
    )

    Write-NameValuePairs $params -quiet $quiet
  }

  function Write-NameValuePairs {
    param(
      [array]$params,
      [boolean] $quiet = $false
    )

    $width = Get-MaxNameWidth $params

    foreach ($param in $params) {
      $text = $param[0]
      $value = $param[1]

      if (Get-IsNotNullOrEmpty $text -eq $true) {
        $name = Format-ParameterName $text $width
        $value = Format-ParameterValue $value
        $line = " - $name = " + $value

        Write-InfoMessage $line -quiet $quiet
      }
    }
  }

  function Write-Values {
    # this should now take $values directly
    param(
      $refType,
      $refValue,
      $versionType,
      $versionValue,
      [boolean] $quiet = $false
    )

    $values = `
      ($refType, $refValue), `
      ('type', $versionType), `
      ('version', $versionValue)

    Write-NameValuePairs $values -quiet $quiet
  }

  function Test-ManifestFileExists {
    param(
      [boolean] $manifestFileExists
    )
    if ($manifestFileExists -eq $false) {
      $missingManifestFile = "A valid 'manifest-file-path' MUST be specified to be able to set the VSIX version"
      Invoke-FileNotFoundException $missingManifestFile
    }
  }

  function Test-RequiredParameters {
    param(
      $versionSpecified,
      $gitRef,
      $productionRegex,
      $developmentVersion,
      $manifestFileExists
    )

    Test-ManifestFileExists $manifestFileExists

    if ($versionSpecified -eq $true) {
      return $manifestFileExists
    }
    else {
      $gitRefValid = Get-IsNotNullOrEmpty $gitRef
      $productionRegexValid = Get-IsNotNullOrEmpty $productionRegex
      $developmentVersionValid = Get-IsNotNullOrEmpty $developmentVersion
      $parametersAreValid = ( `
        ($gitRefValid -eq $true) -and `
        ($productionRegexValid -eq $true) -and `
        ($developmentVersionValid -eq $true) `
      )

      if ($parametersAreValid -eq $false) {
        $missingParameters = `
          "'version-number' was not specified, therefore " + `
          "'git-ref', 'production-regex' and 'development-version' " + `
          "are all required"

        Invoke-Exception -message $missingParameters
      }

      return $true
    }
  }
#endregion functions