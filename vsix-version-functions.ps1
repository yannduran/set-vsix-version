#region constants
  $dateFormat = 'yyyy-MMM-dd HH:mm:ss'
  $tags = 'refs/tags/'
  $heads = 'refs/heads/'
#endregion constants

#region functions
  function Get-CodeVersion {
    param(
      [string] $path
      )

    $value = select-string -Path $path -Pattern $codeRegex -AllMatches `
      | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

    if ($value -eq '') {
      return ''
    }
    
    return $(GetTextBetween($value))
  }

  function Get-GitBranch {
    param(
      [string] $gitRef
    )
    if ($gitRef -eq '') { return '' }

    if ($gitRef.StartsWith($heads)) {
      return $gitRef.Replace($heads,'')
    }
    else {
      return ''
    }
  }

  function Get-GitTag {
    param(
      [string] $gitRef
    )
    if ($gitRef -eq '') { return '' }

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
      | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

    if ($value -eq '') {
      return ''
    } 

    return $(GetTextBetween($value.Replace(' Language=','')))
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
        [string] $manifestVersionBefore = '?',
        [string] $manifestVersionAfter = '?', 
        [bool]   $codeFileExists = $false,
        [string] $codeVersionBefore = '?',
        [string] $codeVersionAfter = '?'
      )

      Show-Info("-------------")
      Show-Info("Manifest file")
      Show-Info("-------------")
      Show-Info(" - before: $manifestVersionBefore")
      Show-Info(" - after : $manifestVersionAfter")

      if ($codeFileExists -eq $true) {
        Show-Info("---------")
        Show-Info("Code file")
        Show-Info("---------")
        Show-Info(" - before: $codeVersionBefore")
        Show-Info(" - after : $codeVersionAfter")
      }
    }  
  
    function Test-Argument {
      param(
        [string] $argument
      )
      if (($argument -eq $null) -or ($argument -eq '')) {
        return '<not supplied>'
      }
      else {
        return "'$argument'"
      }
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
  
      function Test-Inputs {
    param(
      [string] $versionNumber, 
      [string] $gitRef, 
      [string] $productionRegex, 
      [string] $developmentVersion
    )
    $inputStatus = $true

    try {
      
    }
    catch {
      
    }

    return $inputStatus
  }
#endregion functions