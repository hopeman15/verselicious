# Verselicious 🍇

[![Verselicious 🍇](https://github.com/hopeman15/verselicious/actions/workflows/main.yml/badge.svg)](https://github.com/hopeman15/verselicious/actions/workflows/main.yml)
[![codecov](https://codecov.io/gh/hopeman15/verselicious/graph/badge.svg?token=BHW3H8MU7C)](https://codecov.io/gh/hopeman15/verselicious)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
[![License](https://img.shields.io/dub/l/vibe-d.svg)](LICENSE)

GitHub Action to automate semantic versioning with labels 🏷️

Add a `major`, `minor`, or `patch` label to a pull request and Verselicious will bump the version, create a git tag, and publish a GitHub release when the PR is merged.

## Quick Start

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: hopeman15/verselicious@v0.2.1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

That's it. Label your PR with `major`, `minor`, or `patch`, merge it, and a release will be created automatically. The action detects the associated pull request from the merge commit automatically.

## How It Works

1. Detects the pull request associated with the push commit
2. Reads the labels on that pull request
3. Determines the bump type (`major`, `minor`, or `patch`)
4. Finds the latest semver tag in the repository (defaults to `0.0.0` if none exist)
5. Bumps the version accordingly
6. Creates a GitHub release with the new tag and auto-generated release notes

If no pull request is found or no versioning label is present, the action logs a message and exits without creating a release.

## Inputs

| Input | Description | Required | Default |
| --- | --- | --- | --- |
| `github_token` | GitHub token for API access. Use a PAT if tag creation needs to trigger downstream workflows. | Yes | — |
| `major_label` | Label name that triggers a major version bump. | No | `major` |
| `minor_label` | Label name that triggers a minor version bump. | No | `minor` |
| `patch_label` | Label name that triggers a patch version bump. | No | `patch` |
| `tag_prefix` | Prefix for version tags (e.g., `v` to produce `v1.0.0`). | No | `""` |
| `target_branch` | Branch to target for the release. | No | `main` |
| `generate_notes` | Whether to auto-generate release notes. | No | `true` |

## Outputs

| Output | Description | Example |
| --- | --- | --- |
| `new-version` | The new version after bumping. | `1.1.0` |
| `previous-version` | The version before bumping. | `1.0.0` |
| `tag` | The full tag that was created. | `v1.1.0` |
| `release-url` | URL of the created GitHub release. | `https://github.com/…/releases/tag/v1.1.0` |

## Examples

### Using a tag prefix

```yaml
- uses: hopeman15/verselicious@v0
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    tag_prefix: 'v'
```

This produces tags like `v1.0.0`, `v1.1.0`, etc.

### Custom label names

```yaml
- uses: hopeman15/verselicious@v0
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    major_label: 'release: major'
    minor_label: 'release: minor'
    patch_label: 'release: patch'
```

### Using outputs in subsequent steps

```yaml
- uses: hopeman15/verselicious@v0
  id: version
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}

- run: echo "Released ${{ steps.version.outputs.tag }}"
```

### Triggering downstream workflows

The default `GITHUB_TOKEN` does not trigger other workflows when creating tags. If you need tag creation to kick off a downstream workflow (e.g., a publish pipeline), use a Personal Access Token (PAT) instead:

```yaml
- uses: hopeman15/verselicious@v0
  with:
    github_token: ${{ secrets.PAT }}
```

## Token permissions

Verselicious creates a GitHub Release, which also creates the underlying tag. Whichever token you pass via `github_token` must be allowed to write releases to the target repository. A `404 Not Found` from `POST /repos/{owner}/{repo}/releases` almost always means the token lacks those permissions — GitHub deliberately returns 404 instead of 403 to avoid leaking repository existence.

Use whichever option matches your token type:

- **`secrets.GITHUB_TOKEN`** — the workflow must declare `permissions: contents: write`:

  ```yaml
  permissions:
    contents: write
  ```

- **Classic personal access token** — the token needs the `repo` scope (or `public_repo` if only public repositories are targeted).

- **Fine-grained personal access token** — the token needs the **Contents: Read and write** repository permission, and the token must be granted access to the target repository.
