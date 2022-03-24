# TODO: 
# - validate `development-version` etc for VSIX comptability/SemVer (ie no metatdata, 1.0.0, 1.2.3 or 1.2.3.4)
# - remove `production-version` and take from tag
# - transfer to action
# - use https://github.com/ebekker/pwsh-github-action-tools
# - return an empty string if version is null (done?)

#region functions
function LogInfo {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$message
    )
  
  Write-Host "INFO: ${message}" -ForegroundColor Magenta
}

function LogError {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]
    $message
    )
  
  Write-Host "ERROR: ${message}" -ForegroundColor Yellow
}

function LogException {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$message
    )
  
  Write-Host "EXCEPTION: ${message}" -ForegroundColor Red
}

function LogException {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$message
    )
  
  Write-Host "EXCEPTION: ${message}" -ForegroundColor Red
}

function LogDate {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$prefix
    )
  
  Write-Host "INFO: ${prefix} $(Get-Date -Format $dateFormat)" -ForegroundColor Magenta
}

function GetTextBetween {
  # https://powershellone.wordpress.com/2021/02/24/using-powershell-and-regex-to-extract-text-between-delimiters/

  [CmdletBinding()]
  param( 
    [Parameter(Mandatory, ValueFromPipeline = $true, Position = 0)]   
    [string]$Text,
    [Parameter(Position = 1)] 
    [char]$delimeter = '"'
  )
  $pattern = "(?<=\$delimeter).+?(?=\$delimeter)"

  return [regex]::Matches($Text, $pattern).Value
}

function GetManifestVersion {
  param([string]$path)

  $value = select-string -Path $path -Pattern $manifestRegex -AllMatches `
    | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

  if ($value -eq '') {
    return ''
  } else {
    return $value.Replace(' Language=','')
  }
}

function GetCodeVersion {
  param([string]$path)
  $value = select-string -Path $path -Pattern $codeRegex -AllMatches `
    | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

  if ($value -eq '') {
    return ''
  } else {
    return $value
  }
}

function ShowResults {
  param(
  [string] $manifestVersionBefore = '?',
  [string] $manifestVersionAfter = '?', 
  [bool]   $codeFilePathExists = $true,
  [string] $codeVersionBefore = '?',
  [string] $codeVersionAfter = '?'
  )

  LogInfo("-------------")
  LogInfo("Manifest file")
  LogInfo("-------------")
  LogInfo(" - before: $manifestVersionBefore")
  LogInfo(" - after : $manifestVersionAfter")

  if ($codeFilePathExists -eq $true) {
    LogInfo("---------")
    LogInfo("Code file")
    LogInfo("---------")
    LogInfo(" - before: $codeVersionBefore")
    LogInfo(" - after : $codeVersionAfter")
  }
}  
#endregion

#region init
  LogDate "Started at"  

  #region inputs
  # # version supplied
  # $versionNumber = '1.0.0'
  # $developmentVersion = ''
  # $productionVersion = ''
  # $productionTag = ''
  # $gitRef = ''
  # $manifestFilePath = 
  # $codeFilePath = './.github/workflows/test.cs'

  # # branch with missing data
  # $versionNumber = ''
  # $developmentVersion = ''
  # $productionVersion = ''
  # $productionTag = ''
  # $gitRef = 'refs/heads/master'
  # $manifestFilePath = './.github/workflows/test.vsixmanifest'
  # $codeFilePath = './.github/workflows/test.cs'

  # # branch with data
  # $versionNumber = ''
  # $developmentVersion = '1.2.0.1'
  # $productionVersion = '1.3.0' 
  # $productionTag = '^v[0-9]+.[0-9]+.[0-9]+$'
  # $gitRef = 'refs/heads/master'
  # $manifestFilePath = './.github/workflows/test.vsixmanifest'
  # $codeFilePath = './.github/workflows/test.cs'
  
  # # non-production tag
  # $versionNumber = ''
  # $developmentVersion = '1.2.0.1'
  # $productionVersion = '1.3.0' 
  # $productionTag = '^v[0-9]+.[0-9]+.[0-9]+$'
  # $gitRef = 'refs/tags/1.4.0'
  # $manifestFilePath = './.github/workflows/test.vsixmanifest'
  # $codeFilePath = './.github/workflows/test.cs'
  
  # production tag
  $versionNumber = ''
  $developmentVersion = '1.2.0.1'
  $productionVersion = '1.3.0' 
  $productionTag = '^v[0-9]+.[0-9]+.[0-9]+$'
  $gitRef = 'refs/tags/v1.4.0'
  $manifestFilePath = './.github/workflows/test.vsixmanifest'
  $codeFilePath = './.github/workflows/test.cs'
  
  # # unsupported gitref
  # $versionNumber = ''
  # $developmentVersion = '1.2.0.1'
  # $productionVersion = '1.3.0' 
  # $productionTag = '^v[0-9]+.[0-9]+.[0-9]+$'
  # $gitRef = 'refs/pr/v1.4.0'
  # $manifestFilePath = './.github/workflows/test.vsixmanifest'
  # $codeFilePath = './.github/workflows/test.cs'
  
  LogInfo "------"
  LogInfo "Inputs"
  LogInfo "------"

  if ($versionSpecified -eq $true) { 
    LogInfo " - version-number      = $versionNumber" 
  }
  else { 
    LogInfo " - version-number      = ''"
  }

  LogInfo " - development-version = $developmentVersion"
  LogInfo " - production-version  = $productionVersion"
  LogInfo " - production-tag      = $productionTag"
  LogInfo " - git-ref             = $gitRef"
  LogInfo " - manifest-file-path  = $manifestFilePath"
  LogInfo " - code-file-path      = $codeFilePath"
  #endregion

  #region constants
    $dateFormat = 'yyyy-MMM-dd HH:mm:ss'
    $tags = 'refs/tags/'
    $heads = 'refs/heads/'
    $versionRegex = '([0-9\\.]+)'
    $manifestRegex = 'Version="' + $versionRegex + '" Language=' # do this all inside ""?
    $codeRegex = 'Version = "' + $versionRegex + '"' # do this all inside ""?
    $versionSpecified = ($versionNumber -ne '')
    $isBranch = $gitRef.StartsWith($heads)
    $isTag = $gitRef.StartsWith($tags)
  #endregion

  #region variables
  $valid = $false
  $versionToSet = '0.1'
  #endregion
#endregion

#region process
  try {
    LogInfo "------"
    LogInfo "Values"
    LogInfo "------"

    if ($versionSpecified -eq $true) {
      $valid = $true
      $versionToSet = $versionNumber

      LogInfo " - type    =   specified"
    }
    else {
      $valid = ($developmentVersion -ne '') -and ($productionVersion -ne '') -and ($gitRef -ne '')

      if ($valid -eq $false) {
        $message = "Input 'version-number' was not specified
        Therefore 'development-version', 'production-version' and 'git-ref'
        inputs are all required"
  
        throw new-object System.ArgumentException $message
      }  

      if (!$isBranch -and !$isTag) {
        throw new-object System.InvalidOperationException "'$gitref' is not currently supported"  
      }
  
      # use a switch here?
  
      if ($isBranch) {
        $valid = $true
        $versionToSet = $developmentVersion
        $branch = $gitRef.Replace($heads,'')
  
        LogInfo " - branch  = $branch"
        LogInfo " - type    = development"
      }
  
      if ($isTag) {
        $valid = $true
        $tag = $gitRef.Replace($tags,'')
        $isProduction = ($tag -match $productionTag)
        
        LogInfo " - tag     = $tag"

        if ($isProduction -eq $true) {
          LogInfo " - type    = production"
          $versionToSet = $productionVersion
        }
        else {
          LogInfo " - type    = development"
          $versionToSet = $developmentVersion
        } 
      }
    }  
  }
  catch [System.ArgumentException] {
    LogError $_
    $valid = $false
  }
  catch [System.InvalidOperationException] {
    LogError $_
    $valid = $false
  }
  catch {
    LogException "An unexpected error occurred: $_"
    LogException $_.ScriptStackTrace
    $valid = $false
  }
#endregion

#region end
  if ($valid -eq $true) {
    LogInfo " - version = $versionToSet"                    

    $manifestVersionBefore = $(GetTextBetween(GetManifestVersion($manifestFilePath)))
    $manifestReplacement = 'Version="' + $versionToSet + '" Language='
    $content = [string]::join([environment]::newline, (get-content $manifestFilePath))
    $regex = New-Object System.Text.RegularExpressions.Regex $manifestRegex
    $regex.Replace($content, $manifestReplacement) | Out-File $manifestFilePath
    $manifestVersionAfter = $(GetTextBetween(GetManifestVersion($manifestFilePath)))

    $codeFilePathExists = [System.IO.File]::Exists($codeFilePath)

    if ($codeFilePathExists -eq $true)
    {
      $codeVersionBefore = $(GetTextBetween(GetCodeVersion($codeFilePath)))
      $codeReplacement = 'Version = "' + $versionToSet +'"'
      $content = [string]::join([environment]::newline, (get-content $codeFilePath))
      $regex = New-Object System.Text.RegularExpressions.Regex $codeRegex
      $regex.Replace($content, $codeReplacement) | Out-File $codeFilePath
      $codeVersionAfter =$(GetTextBetween(GetCodeVersion($codeFilePath)))
    }

    ShowResults $manifestVersionBefore $manifestVersionAfter $codeFilePathExists $codeVersionBefore $codeVersionAfter
  }

  LogDate "Ended at"
#endregion