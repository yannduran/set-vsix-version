#region usings
  using namespace System
  using namespace System.IO
  using namespace Collections.Generic
  using namespace Microsoft.PowerShell.Commands
#endregion usings

#region constant values
  $dateFormat = 'yyyy-MMM-dd HH:mm:ss'
  $tags = 'refs/tags/'
  $heads = 'refs/heads/'
  $XdotXdotX = "[0-9]+.[0-9]+.[0-9]"
  $vXdotXdotX = "^v" + $XdotXdotX + "$"
  $versionRegex = '([0-9\\.]+)'
  $manifestRegex = 'Version="' + $versionRegex + '" Language=' # do this all inside ""?
  $codeRegex = 'Version = "' + $versionRegex + '"' # do this all inside ""?
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

  function Get-CodeVersion {
    param(
      [string] $path
    )

    $value = select-string -Path $path -Pattern $codeRegex -AllMatches `
      | ForEach-Object { $_.Matches } `
      | ForEach-Object { $_.Value }

    if ($value -eq '') {
      return ''
    }
    
    return $(GetTextBetween($value))
  }

  function Get-GitBranch {
    param(
      $gitRef
    )
    $valid = Test-ValidParameter($gitRef)

    if ($valid -eq $false) { return '' }

    if ($gitRef.StartsWith($heads)) {
      return $gitRef.Replace($heads,'')
    }
    else {
      return ''
    }
  }
  
  function Get-GitTag {
    param(
      $gitRef
    )
    $valid = Test-ValidParameter($gitRef)

    if ($valid -eq $false) { return '' }

    if ($gitRef.StartsWith($tags)) {
      return $gitRef.Replace($tags,'')
    }
    else {
      return ''
    }
  }

  function Get-ManifestVersion {
    param(
      [string] $path
    )

    $value = select-string -Path $path -Pattern $manifestRegex -AllMatches `
      | ForEach-Object { $_.Matches } `
      | ForEach-Object { $_.Value }

    if ($value -eq '') {
      return ''
    } 

    return $(GetTextBetween($value.Replace(' Language=','')))
  }

  function Get-MaxNameWidth {
    param(
      [array]$params
    )
    $maxWidth = 0

    foreach ($param in $params) {
      $length = $param[0].Length

      if ($length -gt $maxWidth) {
        $maxWidth = $length
      }
    }

    return $maxWidth
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

  function Get-VersionValues {
    param(
      $versionNumber,
      $gitRef,
      $productionRegex,
      $versionRegex,
      $developmentVersion
    )
    $branch = Get-GitBranch $gitRef 
    $isBranch = Test-NotNullOrEmpty $branch
    $tag = Get-GitTag $gitRef
    $isTag = Test-NotNullOrEmpty $tag
    $versionSpecified = Test-ValidParameter $versionNumber
  
    if ($versionSpecified -eq $true) {
      $refType = ''
      $refValue = ''
      $versionType = 'specified'
      $versionToSet = $versionNumber
    } 

    if ($isBranch -eq $true) {
      $refType = 'branch'
      $refValue = $branch
      $versionType = 'development'
      $versionToSet = $developmentVersion
    }

    if ($isTag -eq $true) {
      $refType = 'tag'
      $refValue = $tag

      $isProduction = Test-IsProductionTag $tag $productionRegex
      $isDevelopment = (!$isProduction)

      if ($isProduction -eq $true) {
        $versionType = 'production'
        $versionToSet = Select-VersionNumber -source $tag -regex $versionRegex
      
        $versionExtracted = Test-NotNullOrEmpty $versionToSet

        if ($versionExtracted -eq $false){
          $message = "Tag '$tag' does not contain a version number using '$versionRegex'"
          
          Invoke-ArgumentException $message
        }
      }
        
      if ($isDevelopment -eq $true) {
        $versionType = 'development'
        $versionToSet = $developmentVersion
      }
    }     

    return @{ 
      refType = $refType; 
      refValue = $refValue;
      versionType = $versionType;
      versionValue = $versionToSet;
    }
    # return $versionRef, $refValue, $versionType, $version
    # Invoke-ArgumentException "Logic error in 'Get-VersionToSet'" ApplicationException
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

  function Set-Output {
    param(
      $name,
      $value
    )
    Write-Output "::set-output name=$name::$value"
  }

  function Write-DatedMessage {
    param(
      [string] $prefix
    )
    
    Write-Host "INFO: ${prefix} $(Get-Date -Format $dateFormat)" -ForegroundColor Magenta
  }

  function Write-ErrorMessage {
    param(
      [string] $message
    )
    
    Write-Host "ERROR: ${message}" -ForegroundColor Yellow
  }  
  
  function Write-ExceptionMessage {
    param(
      [string] $message
    )
    Write-Host "EXCEPTION: ${message}" -ForegroundColor Red
  }

  function Write-InfoMessage {
    param(
      [string] $message
    )
    
    Write-Host "INFO: ${message}" -ForegroundColor Magenta  
  }  
 
  function Write-Header {
    param(
      $header,
      $character = '-'
    )
    $length = $header.Length
    $line = ''.PadRight($length, $character) # $character * $length

    Write-InfoMessage $line
    Write-InfoMessage $header
    Write-InfoMessage $line
  }

  function Write-Inputs {
    param(
      $versionNumber, 
      $gitRef, 
      $productionRegex, 
      $versionRegex, 
      $developmentVersion, 
      $manifestFilePath
    )
    $inputs = `
      ('version-number', $versionNumber), `
      ('git-ref', $gitRef), `
      ('production-regex', $productionRegex), `
      ('version-regex', $versionRegex), `
      ('development-version', $developmentVersion), `
      ('manifest-file-path', $manifestFilePath)

    Write-NameValuePairs $inputs
  }

  function Write-NameValuePairs {
    param(
      [array]$params
    )
    $width = Get-MaxNameWidth $params

    foreach ($param in $params) {
      $name = Format-ParameterName $param[0] $width
      $value = Format-ParameterValue $param[1]
      $line = " - $name = " + $value

      Write-InfoMessage $line
    }
  }

  function Write-Values {
    param(
      $refType,
      $refValue,
      $versionType,
      $versionValue
    )
    $values = `
      ($refType, $refValue), `
      ('type', $versionType), `
      ('version', $versionValue)

    Write-NameValuePairs $values
  }

  function Write-ManifestFileResults {
    param(
      [string] $manifestVersionBefore = '',
      [string] $manifestVersionAfter = ''
    )
    Write-InfoMessage(" - before: $manifestVersionBefore")
    Write-InfoMessage(" - after : $manifestVersionAfter")
  }

  function Write-CodeFileResults {
    param(
      [bool]   $codeFileExists = $false,
      [string] $codeVersionBefore = '',
      [string] $codeVersionAfter = ''
    )
    if ($codeFileExists -eq $true) {
      Write-InfoMessage(" - before: $codeVersionBefore")
      Write-InfoMessage(" - after : $codeVersionAfter")
    }
  }

  function Test-IsProductionTag {
    param(
      $tag,
      $regex = ''
    )
    $validTag = Test-ValidParameter $tag
    $validRegex = Test-ValidParameter $regex
    if (($validTag -eq $false) -or ($validRegex -eq $false))
    { 
      return $false 
    }

    return ($tag -match $regex)
  }
  
  function Test-NotNullOrEmpty {
    [OutputType([boolean])]
    param(
      $value
    )
    return (($null -ne $value) -and ($value -ne ''))
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

  function Test-ValidParameter {
    [OutputType([boolean])]
    param(
      $value,
      $message = ''
    )
    if (Test-NotNullOrEmpty $value) {
      return $true
    }

    if ($message -eq '') {
        return $false
    }
    else {
      Invoke-ArgumentException $message
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
      $gitRefValid = Test-ValidParameter $gitRef
      $productionRegexValid = Test-ValidParameter $productionRegex
      $developmentVersionValid = Test-ValidParameter $developmentVersion
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
  
        Invoke-ArgumentException -message $missingParameters -errorId ArgumentException
      }

      return $true
    }
  }
#endregion functions