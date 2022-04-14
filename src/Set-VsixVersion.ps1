#######################################
#Script Title: Set VSIX Version
#Script File Name: set-vsix-version.ps1
#Author: Yann Duran
#Date Created: 2022-03-28
#######################################

function Set-VsixVersion {
  param(
    [string] $versionNumber = '',
    [string] $gitRef = '',
    [string] $productionRegex = '',
    [string] $versionRegex = '',
    [string] $developmentVersion = '',
    [string] $manifestFilePath = ''
  )

  . ./src/vsix-version-functions.ps1

  $valid = $false

  try {
    #region start
      Write-DatedMessage "Started at"

      #region variable values
        $versionToSet = '0.1' #default value
      #endregion variable values

      #region inputs
        Write-Header 'Inputs'
        Write-Inputs `
          $versionNumber `
          $gitRef `
          $productionRegex `
          $versionRegex `
          $developmentVersion `
          $manifestFilePath
      #endregion inputs
    #endregion start

    #region process
      $versionSpecified = Test-ValidParameter $versionNumber
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

      Write-Header 'Values'

      $values = Get-Values `
        -versionNumber $versionNumber `
        -gitRef $gitRef `
        -productionRegex $productionRegex `
        -versionRegex $versionRegex `
        -developmentVersion $developmentVersion

      $refType = $values.refType
      $refValue = $values.refValue
      $versionType = $values.versionType
      $versionToSet = $values.versionValue

      Write-Values `
        -refType $refType `
        -refValue $refValue `
        -versionType $versionType `
        -versionValue $versionToSet

      $valid = Test-NotNullOrEmpty($versionToSet)
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
          Write-Header 'Manifest File'
          Write-ManifestFileResults $manifestResults
        #endregion manifest file

        if ($codeFileExists -eq $true) {
          Write-Header 'Code File'
          Write-CodeFileResults $codeResults
        }

        Set-Output "version-number" $versionToSet
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