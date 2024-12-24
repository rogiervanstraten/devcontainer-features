# Development Container Features

A collection of simple and reusable Development Container Features. Quickly add languages, tools, or CLIs to your development container.

## About

Development Container Features are self-contained units of installation code and configuration designed to extend development containers. Features work atop a wide range of base container images and help bridge the gap when a CLI, language, or tool is missing from your container image.

Learn more about Development Container Features at [containers.dev](https://containers.dev).

## Usage

To use a Feature from this repository, add the desired Features to your `devcontainer.json`. Each Feature in this repository has a dedicated `README.md` describing how to use it and the options it supports.

### Example

The example below shows how to use the `zls` Feature from this repository.

```json
{
  "name": "my-project-devcontainer",
  "image": "mcr.microsoft.com/devcontainers/base:bookworm",
  "features": {
    "ghcr.io/devcontainers-extra/features/zig:1": {
      "version": "0.13.0"
    },
    "ghcr.io/rogiervanstraten/devcontainer-features/zls:1": {}
  }
}
```

Features follow semantic versioning. You can pin to a specific version using the appropriate label:

- `:latest` (default if omitted)
- `:1` (major version)
- `:1.0` (minor version)
- `:1.0.0` (patch version)

### Build a Dev Container with Features

Use the [devcontainer CLI](https://code.visualstudio.com/docs/devcontainers/cli) to build and test your container:

```bash
git clone <your-project-repo>
devcontainer build --workspace-folder <path-to-your-project>
```

## Repository Structure

```
.
├── README.md
├── src
│   ├── zls
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
├── test
│   ├── zls
│   │   └── test.sh
```

- **src/**: Contains subfolders for each Feature. Each subfolder includes:
  - `devcontainer-feature.json`: Metadata about the Feature.
  - `install.sh`: Installation script for the Feature.
- **test/**: Contains tests for each Feature, mirroring the `src/` directory structure.
