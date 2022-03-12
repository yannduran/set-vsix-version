# Set VSIX Version Number

Sets the supplied VSIX version number in the VSIX manifest and generated code-behind file (if one exists)

## Usage

This action doesn't NOT increment the existing version number for you. If you want a simple version incrementing action, you may find the [timheuer/vsix-version-stamp](https://github.com/timheuer/vsix-version-stamp/blob/main/README.md) action might suffice for your needs.

The main difference between that action and this one is that this action relies on you using some method of calculating the version number to set PRIOR to using the `set-vsix-version` action. This gives you more flexability than simply incrementing the `patch` version.

I wanted to use Server-compatible versions, and Tim's action didn't suit my needs, so I wrote this one.

In this example below, I'm currently using `GitVersion` to generate an appropriate `SemVer` compatible version, but you can use whatever method suits you and your circumstnces.

```yaml
on:
  push:
    branches:
      - master
      - develop

jobs:
  build:
    name: Build VSIX
    runs-on: windows-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set Staging VSIX version
        if: github.ref != 'refs/heads/master' # this step will only run when the branch IS NOT `master`

        uses: yannduran/set-vsix-version@v1
        with:
          version-number: ${{ steps.gitversion.outputs.MajorMinorPatch }}.${{ steps.gitversion.outputs.PreReleaseNumber }}
          vsix-manifest-file: src\vsix\source.extension.vsixmanifest # use your path to the file
          vsix-code-file: src\vsix\source.extension.cs # # use your path to the file

      - name: Set Production VSIX version
        if: github.ref == 'refs/heads/master' # this step will only run when the branch IS `master`

        uses: yannduran/set-vsix-version@v1
        with:
          version-number: ${{ steps.gitversion.outputs.MajorMinorPatch }} # using GitVersion to provide
          vsix-manifest-file: src\vsix\source.extension.vsixmanifest # use your path to the file
          vsix-code-file: src\vsix\source.extension.cs # # use your path to the file
```

In the future I hope to combine the logic for the two methods above into a single step. But I was struggling with the code (so many new concepts to learn all at once) so I decided to just use the two steps and worry about combining them in a future version.

## Inputs

```yaml
version-number:
  description: "Version number to set"
  required: true

vsix-manifest-file:
  description: "Path to VSIX manifest file (source.extension.vsixmanifest)"
  required: true

vsix-code-file:
  description: "Path to generated code file (source.extension.vs)"
  required: false
  default: ""

debug-messages:
  description: "Show debug messages"
  required: false
  default: "false"
```

## Outputs

There are no outputs from this action.

## Secrets

There are no secrets required for this action.
