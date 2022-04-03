#region constant values
  $dateFormat = 'yyyy-MMM-dd HH:mm:ss'
  $tags = 'refs/tags/'
  $heads = 'refs/heads/'
  $vXdotXdotX = "^v[0-9]+.[0-9]+.[0-9]+$"
#endregion constants

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
      $versionNumber = '',
      $gitRef,
      $productionRegex = $vXdotXdotX,
      $developmentVersion = '0.1'
    )
    $versionSpecified = Test-ValidParameter($versionNumber)
  
    if ($versionSpecified -eq $true) {
      Show-InfoMessage " - type    = specified"
      
      return $versionNumber
    } 
    else {
      $branch = Get-GitBranch($gitRef)
      $isBranch = ($branch -ne '')
      
      $tag = Get-GitTag $gitRef
      $isTag = ($tag -ne'')
  
      if ($isTag -eq $true) {
        $isProduction = Test-IsProductionTag $tag $productionRegex
        
        Show-InfoMessage " - tag     = $tag"

        if ($isProduction -eq $true) {
          Show-InfoMessage " - type    = production"
       
          return $tag
        }
        else {
          Show-InfoMessage " - type    = development"
       
          return $developmentVersion
        } 
      }     
 
      if ($isBranch -eq $true) {
        $branch = $gitRef.Replace($heads,'')
        
        Show-InfoMessage " - branch  = $branch"
        Show-InfoMessage " - type    = development"

        return $developmentVersion
      }
    }
  }

  function Show-DatedMessage {
    param(
      [string] $prefix
    )
    
    Write-Host "INFO: ${prefix} $(Get-Date -Format $dateFormat)" -ForegroundColor Magenta
  }

  function Show-ErrorMessage {
    param(
      [string] $message
    )
    
    Write-Host "ERROR: ${message}" -ForegroundColor Yellow
  }  
  
  function Show-ExceptionMessage {
    param(
      [string] $message
    )
    
    Write-Host "EXCEPTION: ${message}" -ForegroundColor Red
  }

  function Show-InfoMessage {
    param(
      [string] $message
    )
    
    Write-Host "INFO: ${message}" -ForegroundColor Magenta  
  }  
 
  function Show-VersionResults {
      param(
        [string] $manifestVersionBefore = '',
        [string] $manifestVersionAfter = '', 
        [bool]   $codeFileExists = $false,
        [string] $codeVersionBefore = '',
        [string] $codeVersionAfter = ''
      )

      #region manifest file
        Show-InfoMessage("-------------")
        Show-InfoMessage("Manifest file")
        Show-InfoMessage("-------------")
        Show-InfoMessage(" - before: $manifestVersionBefore")
        Show-InfoMessage(" - after : $manifestVersionAfter")
      #endregion manifest file

      #region code file
      if ($codeFileExists -eq $true) {
        Show-InfoMessage("---------")
        Show-InfoMessage("Code file")
        Show-InfoMessage("---------")
        Show-InfoMessage(" - before: $codeVersionBefore")
        Show-InfoMessage(" - after : $codeVersionAfter")
       }
      #endregion code file
    }  
  
  function Test-FileExists {
    param(
      [string] $path
    )
    $result = Test-Path $path # [System.IO.File]::Exists($path)

    # switch ($result) {
    #   $true {
    #     Show-InfoMessage " - '$path' was found"
    #   }
    #   $false {
    #     Show-InfoMessage " - '$path' was not found"
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
  
  function Test-ValidManifest {
    param(
      [string] $path
    )
    $missingManifestFile = "A valid 'manifest-file-path' MUST be specified to be able to set the VSIX version"
    $manifestFileExists = Test-FileExists($path)

    if ($manifestFileExists -eq $false) { 
      throw new-object System.ArgumentException $missingManifestFile
    }
    return $manifestFileExists
  }

  function Test-NotNullOrEmpty {
    [OutputType([boolean])]
    param(
      $value
    )
    return (($null -ne $value) -and ($value -ne ''))
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
      throw New-Object System.ArgumentException $message
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

      throw New-Object System.ApplicationException $missingManifestFile
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

      if ($parametersAreValid -eq $true) {
        return $true
      }
      else {
        $missingParameters = `
          "'versionNumber' was not specified, therefore " + `
          "'git-ref', 'production-regex' and 'development-version' " + `
          "are all required"

        throw New-Object System.ArgumentException $missingParameters
      }
    }
  }
#endregion functions