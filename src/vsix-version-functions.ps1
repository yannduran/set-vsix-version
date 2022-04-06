#region usings
  using namespace System
  using namespace System.IO
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

  function Get-ParameterValue {
    param(
      [string] $parameter
    )
    if (($parameter -eq $null) -or ($parameter -eq '')) {
      return '<not supplied>'
    }
    else {
      return "'$parameter'"
    }
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

  function Get-VersionToSet {
    param(
      $versionNumber,
      $gitRef,
      $productionRegex,
      $versionRegex,
      $developmentVersion = '0.1'
    )
    $versionSpecified = Test-ValidParameter($versionNumber)
  
    if ($versionSpecified -eq $true) {
      Write-InfoMessage " - type    = specified"
      
      return $versionNumber
    } 

    $branch = Get-GitBranch($gitRef)

    if (Test-NotNullOrEmpty($branch) -eq $true) {
      Write-InfoMessage " - branch  = $branch"
      Write-InfoMessage " - type    = development"

      return $developmentVersion
    }

    $tag = Get-GitTag $gitRef

    if (Test-NotNullOrEmpty($tag) -eq $true) {
      Write-InfoMessage " - tag     = $tag"
      
      $isProduction = Test-IsProductionTag $tag $productionRegex

      if ($isProduction -eq $true) {
        Write-InfoMessage " - type    = production"
      
        $version = Select-VersionNumber -source $tag -regex $versionRegex
        $versionFound = Test-NotNullOrEmpty $version

        if ($versionFound -eq $false){
          $message = "Tag '$tag' does not contain a version number using '$versionRegex'"
          
          New-ArgumentException $message ApplicationException
        }

        return $version
      }

      Write-InfoMessage " - type    = development"
    
      return $developmentVersion
    }     

    New-ArgumentException "Logic error in 'Get-VersionToSet'" ApplicationException
  }

  function New-ArgumentException {
    param(
      $name
    )
    Write-Error -Exception ([ArgumentException]::new("The '$name' parameter was not provided")) -ErrorAction Stop
  }

  function New-FileNotFoundException {
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
 
  function Write-InputValues {
    param(
      $versionNumber, 
      $gitRef, 
      $productionRegex, 
      $versionRegex, 
      $developmentVersion, 
      $manifestFilePath
    )
    Write-InfoMessage "------"
    Write-InfoMessage "Inputs"
    Write-InfoMessage "------"
    Write-InfoMessage " - version-number      = $(Format-ParameterValue $versionNumber)"
    Write-InfoMessage " - git-ref             = $(Format-ParameterValue $gitRef)"
    Write-InfoMessage " - production-regex    = $(Format-ParameterValue $productionRegex)"
    Write-InfoMessage " - version-regex       = $(Format-ParameterValue $versionRegex)"
    Write-InfoMessage " - development-version = $(Format-ParameterValue $developmentVersion)"
    Write-InfoMessage " - manifest-file-path  = $(Format-ParameterValue $manifestFilePath)"
}

  function Write-VersionResults {
      param(
        [string] $manifestVersionBefore = '',
        [string] $manifestVersionAfter = '', 
        [bool]   $codeFileExists = $false,
        [string] $codeVersionBefore = '',
        [string] $codeVersionAfter = ''
      )

      #region manifest file
        Write-InfoMessage("-------------")
        Write-InfoMessage("Manifest file")
        Write-InfoMessage("-------------")
        Write-InfoMessage(" - before: $manifestVersionBefore")
        Write-InfoMessage(" - after : $manifestVersionAfter")
      #endregion manifest file

      #region code file
      if ($codeFileExists -eq $true) {
        Write-InfoMessage("---------")
        Write-InfoMessage("Code file")
        Write-InfoMessage("---------")
        Write-InfoMessage(" - before: $codeVersionBefore")
        Write-InfoMessage(" - after : $codeVersionAfter")
       }
      #endregion code file
    }  
  
  function Test-FileExists {
    param(
      [string] $path
    )
    $result = Test-Path $path

    # switch ($result) {
    #   $true {
    #     Write-InfoMessage " - '$path' was found"
    #   }
    #   $false {
    #     Write-InfoMessage " - '$path' was not found"
    #   }
    #   # Default {}
    # }
  
    return $result
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
      [string] $path
    )
    $missingManifestFile = "A valid 'manifest-file-path' MUST be specified to be able to set the VSIX version"
    $manifestFileExists = Test-FileExists($path)

    if ($manifestFileExists -eq $false) { 
      New-FileNotFoundException $missingManifestFile
    }
    return $manifestFileExists
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
      New-ArgumentException $message
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

    if ($manifestFileExists -eq $false) {
      $missingManifestFile = "A valid 'manifest-file-path' MUST be specified to be able to set the version mumber"

      New-FileNotFoundException -message $missingManifestFile -errorId ArgumentException
    }

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
          "'versionNumber' was not specified, therefore " + `
          "'git-ref', 'production-regex' and 'development-version' " + `
          "are all required"
  
        New-ArgumentException -message $missingParameters -errorId ArgumentException
      }

      return $true
    }
  }
#endregion functions