#!/usr/bin/env pwsh

Set-StrictMode -Version latest
$ErrorActionPreference = 'Stop'

$env:JAVA_HOME='c:\\java8'

function bazel() {
    Write-Output ">> bazel $args"
    $global:lastexitcode = 0
    $backupErrorActionPreference = $script:ErrorActionPreference
    $script:ErrorActionPreference = "Continue"
    & bazel.exe @args 2>&1 | %{ "$_" }
    $script:ErrorActionPreference = $backupErrorActionPreference
    if ($global:lastexitcode -ne 0 -And $args[0] -ne "shutdown") {
        Write-Output "<< bazel $args (failed, exit code: $global:lastexitcode)"
        throw ("Bazel returned non-zero exit code: $global:lastexitcode")
    }
    Write-Output "<< bazel $args (ok)"
}

bazel build //test/...
bazel shutdown

bazel test `
    //test:HelloLibTest `
    //test:HelloLibTestSuite_test_suite_HelloLibTest.scala `
    //test:HelloLibTestSuite_test_suite_HelloLibTest2.scala `
    //test:TestFilterTests `
    //test:no_sig `
    //test/aspect:aspect_test `
    //test/aspect:scala_test `
    //test/proto:test_blacklisted_proto `
    //test/src/main/scala/scalarules/test/resource_jars:resource_jars `
    //test/src/main/scala/scalarules/test/twitter_scrooge/...
