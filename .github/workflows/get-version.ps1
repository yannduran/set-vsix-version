# TODO: 
# - validate `development-version` etc for VSIX comptability/SemVer (ie no metatdata, 1.0.0, 1.2.3 or 1.2.3.4)
# - remove `production-version` and take from tag
# - calculate code file from manifest file instead of providing the path
# - use https://github.com/ebekker/pwsh-github-action-tools

# DONE:
# - return an empty string if version is null

try {
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
      } 
    
      return $(GetTextBetween($value.Replace(' Language=','')))
    }
    
    function GetCodeVersion {
      param([string]$path)
    
      $value = select-string -Path $path -Pattern $codeRegex -AllMatches `
        | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }
    
      if ($value -eq '') {
        return ''
      }
      
      return $(GetTextBetween($value))
    }
    
    function ShowResults {
      param(
      [string] $manifestVersionBefore = '?',
      [string] $manifestVersionAfter = '?', 
      [bool]   $codeFileExists = $true,
      [string] $codeVersionBefore = '?',
      [string] $codeVersionAfter = '?'
      )
    
      LogInfo("-------------")
      LogInfo("Manifest file")
      LogInfo("-------------")
      LogInfo(" - before: $manifestVersionBefore")
      LogInfo(" - after : $manifestVersionAfter")
    
      if ($codeFileExists -eq $true) {
        LogInfo("---------")
        LogInfo("Code file")
        LogInfo("---------")
        LogInfo(" - before: $codeVersionBefore")
        LogInfo(" - after : $codeVersionAfter")
      }
    }  
  #endregion functions
  
  #region start
    LogDate "Started at"  

    #region inputs
      # # version supplied, with manifest
      # $versionNumber = '1.0.0'
      # $developmentVersion = ''
      # $productionVersion = ''
      # $productionRegex = ''
      # $gitRef = ''
      # $manifestFilePath = './.github/workflows/test.vsixmanifest'
      # $codeFilePath = ''

      # version supplied, no manifest file
      $versionNumber = '1.0.0'
      $developmentVersion = ''
      $productionVersion = ''
      $productionRegex = ''
      $gitRef = ''
      $manifestFilePath = ''
      $codeFilePath = './.github/workflows/test.cs'

      # # no version supplied, missing data
      # $versionNumber = ''
      # $developmentVersion = ''
      # $productionVersion = ''
      # $productionRegex = ''
      # $gitRef = ''
      # $manifestFilePath = './.github/workflows/test.vsixmanifest'
      # $codeFilePath = ''

      # # branch
      # $versionNumber = ''
      # $developmentVersion = '1.2.0.1'
      # $productionVersion = '1.3.0' 
      # $productionRegex = '^v[0-9]+.[0-9]+.[0-9]+$'
      # $gitRef = 'refs/heads/master'
      # $manifestFilePath = './.github/workflows/test.vsixmanifest'
      # $codeFilePath = './.github/workflows/test.cs'
      
      # # tag, no production-regex
      # $versionNumber = ''
      # $developmentVersion = '1.2.0.1'
      # $productionVersion = '1.3.0' 
      # $productionRegex = ''
      # $gitRef = 'refs/tags/1.4.0'
      # $manifestFilePath = './.github/workflows/test.vsixmanifest'
      # $codeFilePath = './.github/workflows/test.cs'
      
      # # development tag, with production-regex
      # $versionNumber = ''
      # $developmentVersion = '1.2.0.1'
      # $productionVersion = '1.3.0' 
      # $productionRegex = '^v[0-9]+.[0-9]+.[0-9]+$'
      # $gitRef = 'refs/tags/1.4.0'
      # $manifestFilePath = './.github/workflows/test.vsixmanifest'
      # $codeFilePath = './.github/workflows/test.cs'
           
      # # production tag
      # $versionNumber = ''
      # $developmentVersion = '1.2.0.1'
      # $productionVersion = '1.3.0' 
      # $productionRegex = '^v[0-9]+.[0-9]+.[0-9]+$'
      # $gitRef = 'refs/tags/v1.4.0'
      # $manifestFilePath = './.github/workflows/test.vsixmanifest'
      # $codeFilePath = './.github/workflows/test.cs'
      
      LogInfo "------"
      LogInfo "Inputs"
      LogInfo "------"
      LogInfo " - version-number      = $versionNumber"
      LogInfo " - development-version = $developmentVersion"
      LogInfo " - production-version  = $productionVersion"
      LogInfo " - production-tag      = $productionRegex"
      LogInfo " - git-ref             = $gitRef"
      LogInfo " - manifest-file-path  = $manifestFilePath"
      LogInfo " - code-file-path      = $codeFilePath"
    #endregion inputs

    #region constants
      $dateFormat = 'yyyy-MMM-dd HH:mm:ss'
      $versionSpecified = ($versionNumber -ne '')
      $tags = 'refs/tags/'
      $heads = 'refs/heads/'
      $isBranch = $gitRef.StartsWith($heads)
      $isTag = $gitRef.StartsWith($tags)
      $versionRegex = '([0-9\\.]+)'
      $manifestRegex = 'Version="' + $versionRegex + '" Language=' # do this all inside ""?
      $codeRegex = 'Version = "' + $versionRegex + '"' # do this all inside ""?
      $manifestFileExists = [System.IO.File]::Exists($manifestFilePath)
      $codeFileExists = [System.IO.File]::Exists($codeFilePath)
    #endregion constants

    #region variables
      $valid = $false
      $versionToSet = '0.1'
    #endregion variables
  #endregion start

  #region process
    #region fail fast
      if ($manifestFileExists -eq $false) {
        $message = "A valid 'manifest-file-path' MUST be specified to be able to set the version mumber"

        throw new-object System.ArgumentException $message
      }
          
      $missingInputs = ($versionSpecified -eq $false) `
        -and (($developmentVersion -eq '') -or ($productionVersion -eq '') -or ($productionRegex -eq '') -or ($gitRef -eq ''))

      if ($missingInputs -eq $true) {
        $message = "The 'version-number' was not specified,
       therefore 'development-version', 'production-version', 'production-regex' and 'git-ref'
       are all required"
      
        throw new-object System.ArgumentException $message
      }  
      
      if ($isTag -eq $true -and $productionRegex -eq '') {
        $message = "When pushing a tag, 'production-regex' must be specified"

        throw new-object System.ArgumentException $message
      }
      
      if (!$isBranch -and !$isTag) {
        throw new-object System.InvalidOperationException "'$gitref' is not currently supported"  
      }
    #endregion fail fast
    
    LogInfo "------"
    LogInfo "Values"
    LogInfo "------"

    if ($versionSpecified -eq $true) {
      $valid = $true
      $versionToSet = $versionNumber

      LogInfo " - type    = specified"
    } 
    else {
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
        $isProduction = ($tag -match $productionRegex)
        
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

    if ($versionToSet -ne '') {
      LogInfo " - version = $versionToSet"                    

      #region manifest file
        $manifestVersionBefore = GetManifestVersion($manifestFilePath)
        $manifestReplacement = 'Version="' + $versionToSet + '" Language='

        $content = [string]::join([environment]::newline, (get-content $manifestFilePath))
        $regex = New-Object System.Text.RegularExpressions.Regex $manifestRegex
        $regex.Replace($content, $manifestReplacement) | Out-File $manifestFilePath

        $manifestVersionAfter = GetManifestVersion($manifestFilePath)
      #endregion manfest file

      #region code file
        if ($codeFileExists -eq $true) {
          $codeVersionBefore = GetCodeVersion($codeFilePath)
          $codeReplacement = 'Version = "' + $versionToSet +'"'

          $content = [string]::join([environment]::newline, (get-content $codeFilePath))
          $regex = New-Object System.Text.RegularExpressions.Regex $codeRegex
          $regex.Replace($content, $codeReplacement) | Out-File $codeFilePath
          
          $codeVersionAfter = GetCodeVersion($codeFilePath)
        }
      #endregion
    }
#endregion process

  #region end   
    if ($valid -eq $true) {
      ShowResults $manifestVersionBefore $manifestVersionAfter $codeFileExists $codeVersionBefore $codeVersionAfter
    }

    LogDate "Ended at"
  #endregion end
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
  LogException $_
  LogException $_.ScriptStackTrace
  $valid = $false
}
