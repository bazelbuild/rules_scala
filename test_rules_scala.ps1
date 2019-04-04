Set-StrictMode -Version latest
$ErrorActionPreference = 'Stop'

bazel test //test:HelloLib
