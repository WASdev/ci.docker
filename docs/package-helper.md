
# package-helper.sh

`package-helper.sh` is a build-time helper script used in multi-stage Dockerfiles to install RPM packages in a UBI Minimal builder image and selectively copy only the resulting binaries and shared libraries into a target WebSphere Liberty image on UBI Micro.

It is located at `/liberty/helpers/build/package-helper.sh` inside the WebSphere Liberty image and is intended to be run at build time.

## Usage

```
package-helper.sh --install <pkg> [<pkg> ...]
package-helper.sh --copy [<from-dir>]
```

The two modes are designed to be run in sequence across two stages of a multi-stage Dockerfile: `--install` runs in the UBI Minimal builder stage and `--copy` runs in the Liberty UBI Micro application stage.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PKG_DIR` | `/tmp/pkg-files` | Staging directory used to pass collected files from the UBI Minimal builder to the Liberty UBI Micro application stage. |
| `VERBOSE` | _(unset)_ | Set to `true` to enable output. All output is suppressed by default. |

## Modes

### `--install <pkg> [<pkg> ...]`

Runs in the **UBI Minimal builder** stage. Installs the requested packages and automatically includes any packages pulled in as dependencies. It then collects the installed binaries and shared libraries, and stages them under `PKG_DIR` (defaults to `/tmp/pkg-files`) ready to be copied into the WebSphere Liberty application image on UBI Micro. The staging directory can be overridden by setting `PKG_DIR`, for example:

```
PKG_DIR=/tmp/my-pkg-files package-helper.sh --install procps-ng
```

### `--copy [<from-dir>]`

Runs in the **Liberty UBI Micro application** stage. Copies the staged files from `from-dir` (defaults to `/tmp/pkg-files`) into the root filesystem, skipping any file that already exists in the target image. After copying, it reports counts of copied and skipped files and removes the staging directory. The source directory can be overridden, for example:

```
package-helper.sh --copy /tmp/my-pkg-files
```

## Example Dockerfile (using `kernel-java25-openj9-ubi-micro`)

```dockerfile
FROM icr.io/appcafe/websphere-liberty:kernel-java25-openj9-ubi-micro AS helper

FROM registry.access.redhat.com/ubi10/ubi-minimal:latest AS builder

# Set to `true` to enable output
# ARG VERBOSE=true

# Copy helper script to minimal builder
# And install requested packages
COPY --from=helper /liberty/helpers/build/package-helper.sh /tmp/package-helper.sh
RUN /tmp/package-helper.sh --install procps-ng net-tools ncurses hostname

FROM icr.io/appcafe/websphere-liberty:kernel-java25-openj9-ubi-micro

# Set to `true` to enable output
# ARG VERBOSE=true
...

# Copy packages from UBI Minimal builder
COPY --from=builder /tmp/pkg-files /tmp/pkg-files
USER 0
RUN /liberty/helpers/build/package-helper.sh --copy
USER 1001
```

## Example Dockerfile with custom staging directory and VERBOSE enabled (using `kernel-java17-openj9-ubi-micro`)

```dockerfile
FROM icr.io/appcafe/websphere-liberty:kernel-java17-openj9-ubi-micro AS helper

FROM registry.access.redhat.com/ubi10/ubi-minimal:latest AS builder

# Enabled output
ARG VERBOSE=true

# Copy helper script to minimal builder
# And install requested packages into a custom staging directory
COPY --from=helper /liberty/helpers/build/package-helper.sh /tmp/package-helper.sh
RUN PKG_DIR=/tmp/my-pkg-files /tmp/package-helper.sh --install procps-ng net-tools ncurses hostname

FROM icr.io/appcafe/websphere-liberty:kernel-java17-openj9-ubi-micro

# Enabled output
ARG VERBOSE=true
...

# Copy packages from UBI Minimal builder using custom staging directory
COPY --from=builder /tmp/my-pkg-files /tmp/my-pkg-files
USER 0
RUN /liberty/helpers/build/package-helper.sh --copy /tmp/my-pkg-files
USER 1001
```