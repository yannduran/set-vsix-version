#######################################
#Script Title: Set VSIX Version
#Script File Name: set-vsix-version.ps1 
#Author: Yann Duran
#Date Created: 2022-03-28
#######################################

param(   
  [string] $versionNumber,
  [string] $githubRef,
  [string] $productionRegex,
  [string] $developmentVersion,
  [string] $manifestFilePath,
  [string] $codeFilePath
)
$valid = $false

try {
  #region start
    Show-DatedMessage "Started at"  

    #region inputs
      Show-InfoMessage "------"
      Show-InfoMessage "Inputs"
      Show-InfoMessage "------"
      Show-InfoMessage " - version-number      = $versionNumber" 
      Show-InfoMessage " - development-version = $developmentVersion"
      Show-InfoMessage " - production-version  = $productionVersion"
      Show-InfoMessage " - production-regex    = $productionRegex"
      Show-InfoMessage " - git-ref             = $githubRef"
      Show-InfoMessage " - manifest-file-path  = $manifestFilePath"
      Show-InfoMessage " - code-file-path      = $codeFilePath"
    #endregion inputs

    #region constant values      
      $versionRegex = '([0-9\\.]+)'
      $manifestRegex = 'Version="' + $versionRegex + '" Language=' # do this all inside ""?
      $codeRegex = 'Version = "' + $versionRegex + '"' # do this all inside ""?
      $invalidInputs = "'version-number' was not specified, therefore "
        + "'github-ref', 'production-regex' and 'development-version' "
        + "are all required"
      $missingManifestFile = "A valid 'manifest-file-path' MUST be specified to be able to set the version"
    #endregion constant values

    #region variable values
      $versionToSet = '0.1' #default value
    #endregion variable values
  #endregion start

  #region process
    $valid = Test-Inputs $versionNumber, $githubRef, $productionRegex, $developmentVersion
    if ($valid -eq $false) { Show-ErrorMessage $invalidInputs }
    
    $valid = Confirm-FileExists($manifestFilePath)
    if ($valid -eq $false) { Show-ErrorMessage $missingManifestFile }

    $branch = Get-GitBranch(githubRef)
    $tag = Get-GitTag(githubRef)
    $codeFileExists = Confirm-FileExists($codeFilePath)
    $versionSpecified = ($versionNumber -ne '')

    #temporary
    $versionToSet = $versionNumber
  #endregion process

  #region end
    if ($valid -eq $true) {
      Write-Output "::set-output name=version-number::$versionToSet"

      Show-VersionResults $manifestVersionBefore $manifestVersionAfter $codeFileExists $codeVersionBefore $codeVersionAfter
    }

    Show-DatedMessage "Ended at"
  #endregion end
}
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
finally {
  if ($valid -eq $false) { exit 1 }
}