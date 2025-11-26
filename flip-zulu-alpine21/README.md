# flip-zulu-alpine21

Lightweight Alpine-based Docker image with Azul Zulu OpenJDK 11 JRE. The Dockerfile follows security best practices by using a non-root user, pinning versions for reproducibility, and removing unnecessary tools after installation to keep the image lean.

## Usage

Build the image:

```powershell
docker build -t flipfoundry/docker-base-zulu-alpine:1.0.0 .
```

Verify Java is available:

```powershell
docker run --rm flipfoundry/docker-base-zulu-alpine:1.0.0 java -version
```

## Version Pinning

- Base image: `alpine` is pinned by digest to ensure reproducible, tamper-resistant builds.
- JDK: Azul Zulu JRE 11 (lightweight runtime, no compiler) is installed from Azul's Alpine repository.
- Updates: To upgrade, bump the Alpine image digest in the `FROM` line and adjust the package version in the apk install line.