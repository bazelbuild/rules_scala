# Bazel Central Registry publication

[.github/workflows/publish-to-bcr.yml](../.github/workflows/publish-to-bcr.yml)
uses these files to configure the [Publish to BCR](
https://github.com/bazel-contrib/publish-to-bcr) workflow for publishing to the
[Bazel Central Registry (BCR)](https://registry.bazel.build/).

- [Publish to BCR workflow setup](
    https://github.com/bazel-contrib/publish-to-bcr?tab=readme-ov-file#setup)
- [.bcr/ templates](
    https://github.com/bazel-contrib/publish-to-bcr/tree/main/templates)
- [.github/workflows/publish.yaml reusable workflow](
    https://github.com/bazel-contrib/publish-to-bcr/blob/main/.github/workflows/publish.yaml)

Notice that the setup instructions suggest saving the Personal Access Token as
`PUBLISH_TOKEN`. We save it as `BCR_PUBLISH_TOKEN` instead, as inspired by
aspect-build/rules_lint#529, to make this value more self documenting.

## Provenance attestations

This workflow also produces attestations required by the [Supply chain Levels
for Software Artifacts (SLSA)](https://slsa.dev/) framework for secure supply
chain provenance.

Examples:

<!-- Replace these with rules_scala examples once they're available. -->
- [aspect-build/rules_lint v1.3.4 release and publish run with attestations](
    https://github.com/aspect-build/rules_lint/actions/runs/14410869652/attempts/1)
- [aspect-build/rules_lint v1.3.4 attestations](
    https://github.com/aspect-build/rules_lint/attestations/6280291)
- [aspect-build/rules_lint attestations](
    https://github.com/aspect-build/rules_lint/attestations)

## Related documentation

- [bazelbuild/bazel-central-registry](
    https://github.com/bazelbuild/bazel-central-registry)
- [SLSA: Provenance](https://slsa.dev/spec/v1.0/provenance)
- [in-toto](https://in-toto.io/)
- [GitHub Actions](https://docs.github.com/actions)
  - [Security for GitHub Actions](
      https://docs.github.com/en/actions/security-for-github-actions)
    - [Using secrets in a workflow](
          https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions#using-secrets-in-a-workflow)
    - [Using artifact attestations](
          https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations)
  - [Writing Workflows](
      https://docs.github.com/en/actions/writing-workflows)
    - [Accessing contextual information about workflow runs: 'secrets' context](
          https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs#secrets-context)
    - [Workflow syntax for GitHub Action: 'on.workflow_call.secrets'](
          https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#onworkflow_callsecrets)
  - [Sharing automations](https://docs.github.com/en/actions/sharing-automations)
    - [Passing inputs and secrets to a reusable workflow](
          https://docs.github.com/en/actions/sharing-automations/reusing-workflows#passing-inputs-and-secrets-to-a-reusable-workflow)
- [actions/attest-build-provenance](
    https://github.com/actions/attest-build-provenance)
- [in-toto/attestation](https://github.com/in-toto/attestation)
- [slsa-framework/slsa-verifier](
    https://github.com/slsa-framework/slsa-verifier)

## Inspiration

Originally based on the examples from aspect-build/rules_lint#498 and
aspect-build/rules_lint#501. See also:

- bazelbuild/bazel-central-registry#4060
- bazelbuild/bazel-central-registry#4146
- slsa-framework/slsa-verifier#840
