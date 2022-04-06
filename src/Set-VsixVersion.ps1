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
      Write-DatedMessage "Started at"  

      Write-InputValues `
        $versionNumber `
        $gitRef `
        $productionRegex `
        $versionRegex `
        $developmentVersion `
        $manifestFilePath

      #region variable values
        $versionToSet = '0.1' #default value
      #endregion variable values
    #endregion start

    #region process
      $versionSpecified = Test-ValidParameter($versionNumber)
      $manifestFileExists = Test-FileExists($manifestFilePath)
      $codeFileExists = Test-FileExists($codeFilePath)

      $valid = Test-RequiredParameters $versionSpecified, $gitRef, $productionRegex, $developmentVersion, $manifestFileExists

      Write-InfoMessage "------"
      Write-InfoMessage "Values"
      Write-InfoMessage "------"
  
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
        Write-InfoMessage " - version = $versionToSet"
        
        Write-VersionResults $manifestVersionBefore $manifestVersionAfter $codeFileExists $codeVersionBefore $codeVersionAfter
      }
      
      Write-DatedMessage "Ended at"
    #endregion end
  }
  #region catch
    catch [ArgumentException], [InvalidOperationException] {
      Write-ErrorMessage $_
      $valid = $false
    }
    catch {
      Write-ExceptionMessage $_
      Write-ExceptionMessage $_.ScriptStackTrace
      $valid = $false
    }
  #endregion
  
  finally {
    if ($valid -eq $false) { exit 1 }
  }
}