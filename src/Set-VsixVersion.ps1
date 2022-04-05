#######################################
#Script Title: Set VSIX Version
#Script File Name: set-vsix-version.ps1 
#Author: Yann Duran
#Date Created: 2022-03-28
#######################################

function Set-VsixVersion {
  param(   
    [string] $versionNumber,
    [string] $gitRef,
    [string] $productionRegex,
    [string] $versionRegex,
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
        Show-InfoMessage " - git-ref             = $(Get-ParameterValue $gitRef)"
        Show-InfoMessage " - production-regex    = $(Get-ParameterValue $productionRegex)"
        Show-InfoMessage " - development-version = $(Get-ParameterValue $developmentVersion)"
        Show-InfoMessage " - manifest-file-path  = $(Get-ParameterValue $manifestFilePath)"
      #endregion inputs

      #region variable values
        $versionToSet = '0.1' #default value
      #endregion variable values
    #endregion start

    #region process
      $versionSpecified = Test-ValidParameter($versionNumber)
      $manifestFileExists = Test-FileExists($manifestFilePath)
      $codeFileExists = Test-FileExists($codeFilePath)

      $valid = Test-RequiredParameters $versionSpecified, $gitRef, $productionRegex, $developmentVersion, $manifestFileExists

      Show-InfoMessage "------"
      Show-InfoMessage "Values"
      Show-InfoMessage "------"
  
      if ($valid -eq $false) {
        New-ArgumentException -message 'Validation failed' -ErrorId ApplicationException
      }

      $versionToSet = Get-VersionToSet `
        -versionNumber $versionNumber `
        -gitRef $gitRef `
        -productionRegex $productionRegex `
        -versionRegex $versionRegex `
        -developmentVersion $developmentVersion
      $valid = Test-NotNullOrEmpty($versionToSet)

      if ($valid -eq $false) {
        New-ArgumentException -message 'No version to set' -ErrorId ApplicationException
      }
    #endregion process
      
    #region end
      if ($valid -eq $true) {
        Set-Output "version-number" $versionToSet
        Show-InfoMessage " - version = $versionToSet"
        
        Show-VersionResults $manifestVersionBefore $manifestVersionAfter $codeFileExists $codeVersionBefore $codeVersionAfter
      }
      
      Show-DatedMessage "Ended at"
    #endregion end
  }
  #region catch
    catch [ArgumentException], [InvalidOperationException] {
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