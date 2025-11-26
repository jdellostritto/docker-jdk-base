# flip-azulzulu-openjdk-ubuntu24.04-jdk21

The Dockerfile follows security best practices by using a non-root user, pinning versions for reproducibility, and removing unnecessary tools after installation to keep the image lean.

## Usage

Build the image:

```powershell
docker build -t flipfoundry/azulzulu-openjdk-ubuntu24.04-jdk21:1.0.0 .
```

Verify Java is available:

```powershell
docker run --rm flipfoundry/azulzulu-openjdk-ubuntu24.04-jdk21:1.0.0 java -version
```

## Version Pinning

- Base image: `ubuntu:noble` is pinned by digest to ensure reproducible, tamper-resistant builds.
- JDK: Azul Zulu JDK 21 is pinned to `21.0.9` via apt preferences and explicit package version.
- Updates: To upgrade, bump the Ubuntu image digest in the `FROM` line and adjust the JDK version in the apt pin and install line.
