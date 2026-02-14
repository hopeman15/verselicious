# verselicious

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

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
      - uses: actions/checkout@v4
      - uses: hopeman15/verselicious@v0
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

That's it. Label your PR with `major`, `minor`, or `patch`, merge it, and a release will be created automatically. The action detects the associated pull request from the merge commit automatically.

## How It Works

1. Detects the pull request associated with the push commit
2. Reads the labels on that pull request
3. Determines the bump type (`major`, `minor`, or `patch`)
4. Finds the latest semver tag in the repository (defaults to `0.0.0` if none exist)
5. Bumps the version accordingly
6. Creates a GitHub release with the new tag and auto-generated release notes

If no pull request is found or no versioning label is present, the action skips silently.

## Inputs

| Input | Description | Required | Default |
| --- | --- | --- | --- |
| `github-token` | GitHub token for API access. Use a PAT if tag creation needs to trigger downstream workflows. | Yes | — |
| `major-label` | Label name that triggers a major version bump. | No | `major` |
| `minor-label` | Label name that triggers a minor version bump. | No | `minor` |
| `patch-label` | Label name that triggers a patch version bump. | No | `patch` |
| `tag-prefix` | Prefix for version tags (e.g., `v` to produce `v1.0.0`). | No | `""` |
| `target-branch` | Branch to target for the release. | No | `main` |
| `generate-notes` | Whether to auto-generate release notes. | No | `true` |

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
    github-token: ${{ secrets.GITHUB_TOKEN }}
    tag-prefix: 'v'
```

This produces tags like `v1.0.0`, `v1.1.0`, etc.

### Custom label names

```yaml
- uses: hopeman15/verselicious@v0
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    major-label: 'release: major'
    minor-label: 'release: minor'
    patch-label: 'release: patch'
```

### Using outputs in subsequent steps

```yaml
- uses: hopeman15/verselicious@v0
  id: version
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}

- run: echo "Released ${{ steps.version.outputs.tag }}"
```

### Triggering downstream workflows

The default `GITHUB_TOKEN` does not trigger other workflows when creating tags. If you need tag creation to kick off a downstream workflow (e.g., a publish pipeline), use a Personal Access Token (PAT) instead:

```yaml
- uses: hopeman15/verselicious@v0
  with:
    github-token: ${{ secrets.PAT }}
```

## License

[MIT](LICENSE)
