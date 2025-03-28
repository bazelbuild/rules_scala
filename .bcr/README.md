# Bazel Central Registry publication

The [.github/workflows/publish-to-bcr.yml](
../.github/workflows/publish-to-bcr.yml) reusable GitHub workflow uses these
configuration files for publishing Bazel modules to the [Bazel Central Registry
(BCR)](https://registry.bazel.build/). This workflow also produces attestations
required by the [Supply chain Levels for Software Artifacts
(SLSA)](https://slsa.dev/) framework for secure supply chain provenance.

[bazel-contrib/publish-to-bcr](https://github.com/bazel-contrib/publish-to-bcr)
documentation:

- [Publish to BCR workflow setup (from bazel-contrib/publish-to-bcr@fb1dc68)](
    https://github.com/bazel-contrib/publish-to-bcr/blob/fb1dc6802c3c999e17ad7afce9474a90bd89e132/README.md#setup)
- [.bcr/ templates](
    https://github.com/bazel-contrib/publish-to-bcr/tree/main/templates)
- [.github/workflows/publish.yaml reusable workflow](
    https://github.com/bazel-contrib/publish-to-bcr/blob/main/.github/workflows/publish.yaml)

Related documentation:

- [bazelbuild/bazel-central-registry](
    https://github.com/bazelbuild/bazel-central-registry)
- [SLSA: Provenance](https://slsa.dev/spec/v1.0/provenance)
- [in-toto](https://in-toto.io/)
- [GitHub Actions](https://docs.github.com/actions)
- [Security for GitHub Actions](
    https://docs.github.com/en/actions/security-for-github-actions)
- [Security for GitHub Actions: Using artifact attestations](
    https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations)
- [actions/attest-build-provenance](
    https://github.com/actions/attest-build-provenance)
- [in-toto/attestation](https://github.com/in-toto/attestation)
- [slsa-framework/slsa-verifier](
    https://github.com/slsa-framework/slsa-verifier)

---

Originally based on the examples from aspect-build/rules_lint#498 and
aspect-build/rules_lint#501. See also:

- bazelbuild/bazel-central-registry#4060
- bazelbuild/bazel-central-registry#4146
- slsa-framework/slsa-verifier#840
