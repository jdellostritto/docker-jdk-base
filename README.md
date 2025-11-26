# Docker JDK Base Images

Minimal, production-ready Docker base images with Azul Zulu JDK 21 for containerized Java applications.

## Images

### Ubuntu 24.04 with Azul Zulu JDK 21

- **Directory:** `flip-azulzulu-openjdk-ubuntu24.04-jdk21`
- **Tag:** `jdellostritto/docker-jdk-base:ubuntu-jdk21-latest`
- **Base:** Ubuntu 24.04 (Noble)
- **Use Case:** Standard Linux distributions, broader package availability

### Alpine with Azul Zulu JDK 21

- **Directory:** `flip-zulu-alpine21`
- **Tag:** `jdellostritto/docker-jdk-base:alpine-jdk21-latest`
- **Base:** Alpine Linux
- **Use Case:** Minimal footprint, faster builds, smaller image sizes

## Conventions

- **Non-root user:** `appuser` (UID 1001)
- **User group:** `appgroup` (GID 1001)
- **Application directory:** `/usr/app` (owned by appuser:appgroup)
- **Java home:** `/usr/lib/jvm/zulu21-ca-amd64` (Ubuntu) / `/usr/lib/jvm/zulu21-jdk` (Alpine)
- **Locale:** `en_US.UTF-8`

## Benefits

✅ **Security** - Non-root user prevents privilege escalation  
✅ **Consistency** - Standardized base across all Java applications  
✅ **Choice** - Ubuntu for compatibility, Alpine for minimal size  
✅ **Performance** - Pre-optimized with locale support  
✅ **Reliability** - Pinned Zulu JDK 21 versions for reproducible builds  
✅ **Lightweight** - Only essential packages included  

## Building

Build all images:
```bash
make build
```

Build specific image:
```bash
make build-ubuntu    # Ubuntu 24.04 image
make build-alpine    # Alpine image
```

Clean up images:
```bash
make clean
```

## Usage

Use as a base image in your Dockerfile:

```dockerfile
# Ubuntu option
FROM jdellostritto/docker-jdk-base:ubuntu-jdk21-latest

# Alpine option
FROM jdellostritto/docker-jdk-base:alpine-jdk21-latest

COPY --chown=appuser:appgroup app.jar /usr/app/
WORKDIR /usr/app
USER appuser
ENTRYPOINT ["java", "-jar", "app.jar"]
```
