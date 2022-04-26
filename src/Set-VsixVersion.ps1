﻿#######################################
#Script Title: Set VSIX Version
#Script File Name: set-vsix-version.ps1
#Author: Yann Duran
#Date Created: 2022-03-28
#######################################

function Set-VsixVersion {
  param(
    [string]  $versionNumber = '',
    [string]  $gitRef = '',
    [string]  $productionRegex = '',
    [string]  $versionRegex = '',
    [string]  $developmentVersion = '',
    [string]  $manifestFilePath = '',
    [boolean] $quiet = $false
  )

  # . ./src/vsix-version-functions.ps1

  $valid = $false

  try {
    #region start
      Write-DatedMessage "Started at" -quiet $quiet

      #region variable values
        $versionType = ''
        $versionToSet = '0.1' #default value
      #endregion variable values

      #region inputs
        Write-Header 'Inputs' -quiet $quiet
        Write-Inputs `
          $versionNumber `
          $gitRef `
          $productionRegex `
          $versionRegex `
          $developmentVersion `
          $manifestFilePath `
          -quiet $quiet
      #endregion inputs
    #endregion start

    #region process
      $versionSpecified = Get-IsNotNullOrEmpty $versionNumber
      $manifestFileExists = Test-Path $manifestFilePath
      $codeFileExists = Test-Path $codeFilePath

      $valid = Test-RequiredParameters `
        -versionSpecified $versionSpecified, `
        -gitRef $gitRef, `
        -productionRegex $productionRegex, `
        -developmentVersion $developmentVersion, `
        -manifestFileExists $manifestFileExists

      # if ($valid -eq $false) {
      #   Invoke-ArgumentException -message 'Validation failed'
      # }

      Write-Header 'Values' -quiet $quiet

      $params = @{
        versionNumber = $versionNumber;
        gitRef = $gitRef;
        productionRegex = $productionRegex;
        versionRegex = $versionRegex;
        developmentVersion = $developmentVersion
      }

      Get-Values $params | Write-Values @values -quiet $quiet

      $valid = Get-IsNotNullOrEmpty($versionToSet)
      if ($valid -eq $false) { Invoke-ArgumentException -message 'No version to set' }

      $manifestResults = Set-ManifestFileVersion `
        -manifestFilePath $manifestFilePath `
        -manifestFileRegex $manifestFileRegex `
        -versionRegex $versionRegex `
        -versionToSet $versionToSet

        if ($codeFileExists -eq $true) {
          $codeResults = Set-CodeFileVersion `
            -codeFilePath $codeFilePath `
            -codeFileRegex $codeFileRegex `
            -versionRegex $versionRegex `
            -versionToSet $versionToSet
        }
    #endregion process

    #region end
      if ($valid -eq $true) {
        #region manifest file
          Write-Header 'Manifest File' -quiet $quiet
          Write-ManifestFileResults $manifestResults -quiet $quiet
        #endregion manifest file

        if ($codeFileExists -eq $true) {
          Write-Header 'Code File' -quiet $quiet
          Write-CodeFileResults $codeResults -quiet $quiet
        }

        Set-Output "version-type" $versionType -quiet $quiet
        Set-Output "version-number" $versionToSet -quiet $quiet
      }

      Write-DatedMessage "Ended at" -quiet $quiet
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