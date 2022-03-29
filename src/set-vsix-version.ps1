#######################################
#Script Title: Set VSIX Version
#Script File Name: set-vsix-version.ps1 
#Author: Yann Duran
#Date Created: 2022-03-28
#######################################

function Set-VsixVersion {
  param(   
    [string] $versionNumber,
    [string] $githubRef,
    [string] $productionRegex,
    [string] $developmentVersion,
    [string] $manifestFilePath
  )

  . ./src/vsix-version-functions.ps1

  $valid = $false

  try {
    #region start
      Show-DatedMessage "Started at"  

      #region inputs
        Show-InfoMessage "------"
        Show-InfoMessage "Inputs"
        Show-InfoMessage "------"
        Show-InfoMessage " - version-number      = $(Get-ParameterValue $versionNumber)"
        Show-InfoMessage " - github-ref          = $(Get-ParameterValue $githubRef)"
        Show-InfoMessage " - production-regex    = $(Get-ParameterValue $productionRegex)"
        Show-InfoMessage " - development-version = $(Get-ParameterValue $developmentVersion)"
        Show-InfoMessage " - manifest-file-path  = $(Get-ParameterValue $manifestFilePath)"
      #endregion inputs

      #region constant values      
        $versionRegex = '([0-9\\.]+)'
        $manifestRegex = 'Version="' + $versionRegex + '" Language=' # do this all inside ""?
        $codeRegex = 'Version = "' + $versionRegex + '"' # do this all inside ""?
      #endregion constant values

      #region variable values
        $versionToSet = '0.1' #default value
      #endregion variable values
    #endregion start

    #region process
      $manifestFileExists = Test-FileExists($manifestFilePath)

      $versionSpecified = ($versionNumber -ne '')
      $branch = Get-GitBranch($githubRef)
      $tag = Get-GitTag($githubRef)
      $codeFileExists = Test-FileExists($codeFilePath)

      # $valid = Test-Inputs $versionSpecified, $githubRef, $productionRegex, $developmentVersion, $manifestFilePath
      # if ($valid -eq $false) { Show-ErrorMessage $invalidInputs }
      
      #temporary
      $versionToSet = $versionNumber

      #endregion process
      
      #region end
      if ($valid -eq $true) {
        Write-Output "::set-output name=version-number::$versionToSet"
        
        Show-VersionResults $manifestVersionBefore $manifestVersionAfter $codeFileExists $codeVersionBefore $codeVersionAfter
      }
      
      Show-DatedMessage "Ended at"
      return $versionToSet
    #endregion end
  }
  #region catch
    catch [System.ArgumentException] {
      Show-ErrorMessage $_
      $valid = $false
    }
    catch [System.InvalidOperationException] {
      Show-ErrorMessage $_
      $valid = $false
    }
    catch {
      Show-ExceptionMessage $_
      Show-ExceptionMessage $_.ScriptStackTrace
      $valid = $false
    }
  #endregion
  
  finally {
    if ($valid -eq $false) { exit 1 }
  }
}