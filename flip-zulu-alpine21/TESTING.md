# Image Testing Guide - Alpine

This folder contains automated test scripts to validate the `flipfoundry/docker-base-zulu-alpine` Docker image. Two versions are provided: PowerShell and Bash.

## Quick Start

### Bash
```bash
bash test-image.sh
```

With custom image tag:
```bash
bash test-image.sh your-registry/image:tag
```

### PowerShell
```powershell
powershell -ExecutionPolicy Bypass -File test-image.ps1
```

With custom image tag:
```powershell
powershell -ExecutionPolicy Bypass -File test-image.ps1 -ImageTag "your-registry/image:tag"
```

---

## Bash Script Breakdown

### **Parameter & Output Setup**
```bash
#!/bin/bash
IMAGE_TAG="${1:-flipfoundry/docker-base-zulu-alpine:1.0.0}"
```

- `#!/bin/bash` — Shebang for bash interpreter
- `${1:-default}` — Use first argument or default value
- Allows: `bash test-image.sh custom:tag` or just `bash test-image.sh`

### **Tests Overview**

#### **Test 1: Java Version**
```bash
docker run --rm "$IMAGE_TAG" java -version 2>&1
```

**Syntax Explanation:**
- `docker run --rm` — Execute and auto-remove container
- `"$IMAGE_TAG"` — Quoted variable (safe with spaces)
- `java -version` — Command inside container
- `2>&1` — Redirect stderr to stdout (combines all output)

#### **Test 2: Javac (Compiler Check)**
```bash
docker run --rm "$IMAGE_TAG" javac -version 2>&1
```

**Syntax Explanation:**
- `javac -version` — Check Java compiler availability
- Now available (using JDK 21, not JRE)

#### **Test 3: User Check (appuser)**
```bash
docker run --rm "$IMAGE_TAG" id appuser 2>&1
APPUSER_ID=$(docker run --rm "$IMAGE_TAG" id -u appuser 2>&1)
if [ "$APPUSER_ID" = "1001" ]; then
    echo -e "\033[32mOK - appuser (UID 1001) created successfully\033[0m"
else
    echo -e "\033[31mFAIL - appuser UID is $APPUSER_ID (expected 1001)\033[0m"
fi
```

**Syntax Explanation:**
- `$(...)` — Command substitution captures output
- `id appuser` — Shows user info (UID, GID, groups)
- `id -u appuser` — Extract numeric UID only
- `if [ condition ]; then ... else ... fi` — Bash conditional
- `[ "$VAR" = "value" ]` — String equality test
- Verifies non-root user security configuration

#### **Test 4: Java Program**
```bash
docker run --rm "$IMAGE_TAG" sh -c 'cat > T.java << EOF
public class T{public static void main(String[]a){System.out.println("Hello Zulu JDK 21 Alpine");}}
EOF
javac T.java
java T' 2>&1
```

**Syntax Explanation:**
- `<< EOF` — Heredoc for multi-line input
- Content between `<<EOF` and `EOF` becomes file content
- `;` — Command separator (sequential execution)
- `javac T.java` — Compile Java source (now available with JDK)
- `java T` — Execute the compiled class

#### **Test 5-7: Standard Operations**
```bash
docker history "$IMAGE_TAG" 2>&1 | head -8  # Show layers
docker images "$IMAGE_TAG"                   # Show metadata
docker run --rm "$IMAGE_TAG" sh -c "echo JAVA_HOME=\$JAVA_HOME"  # Environment
```

### **Bash Syntax Reference**

| Syntax | Purpose |
|--------|---------|
| `${1:-default}` | Use arg 1 or default |
| `$(command)` | Command substitution |
| `"$var"` | Variable substitution |
| `'literal'` | No expansion |
| `2>&1` | Redirect stderr to stdout |
| `\|` | Pipe output |
| `<< MARKER` | Heredoc multi-line |
| `;` | Sequential separator |
| `\|\|` | OR operator (run if previous fails) |
| `[ condition ]` | Test condition |
| `\033[XXm` | ANSI colors |
| `-e` flag | Enable escapes in echo |

---

## PowerShell Script Breakdown

### **Parameter Definition**
```powershell
param(
    [string]$ImageTag = "flipfoundry/docker-base-zulu-alpine:1.0.0"
)
```

**Syntax Explanation:**
- `param(...)` — Define script parameters
- `[string]` — Type declaration
- `$ImageTag` — Variable with `$` prefix
- Default value if not provided
- Called as: `.\test-image.ps1 -ImageTag "custom:tag"`

### **Output & Commands**

#### **Test 1: Java Version**
```powershell
docker run --rm $ImageTag java -version 2>&1
Write-Host "OK" -ForegroundColor Green
```

**Syntax Explanation:**
- `docker run` — Same as bash
- `$ImageTag` — PowerShell variable (no quotes needed)
- `Write-Host` — Output with formatting
- `-ForegroundColor` — Text color parameter

#### **Test 2: Alpine Size**
```powershell
docker run --rm $ImageTag sh -c "du -sh / 2>/dev/null | head -1" 2>&1
```

Same as bash; PowerShell passes string to docker which executes in shell.

#### **Test 3: User Check**
```powershell
$appuser_id = docker run --rm $ImageTag id -u appuser 2>&1
if ($appuser_id -eq "1001") {
    Write-Host "OK - appuser (UID 1001) created successfully" -ForegroundColor Green
} else {
    Write-Host "FAIL - appuser UID is $appuser_id (expected 1001)" -ForegroundColor Red
}
```

**Syntax Explanation:**
- `$appuser_id = ...` — Assignment (stores command output)
- `if (...) { } else { }` — Conditional branching
- `-eq` — Equality operator
- Same verification as bash

#### **Test 4: Java Program with Error Handling**
```powershell
docker run --rm $ImageTag sh -c "cat > T.java << 'EOF'
...
javac T.java 2>&1 || echo 'Note: javac not available (JRE only, no compiler)'
java T" 2>&1
```

PowerShell passes entire script string to docker, which handles heredoc and `||` operator.

### **PowerShell Syntax Reference**

| Syntax | Purpose |
|--------|---------|
| `param([type]$var = "default")` | Define parameter |
| `$variable` | Variable (prefix required) |
| `$(...) ` | Command substitution |
| `"string"` | Quoted (expansion) |
| `'literal'` | Literal (no expansion) |
| `` `$ `` | Escape dollar sign |
| `-Parameter` | Named parameter |
| `2>&1` | Redirect stderr to stdout |
| `\|` | Pipe operator |
| `;` | Sequential separator |
| `` ` `` | Line continuation (backtick) |
| `if (...) { } else { }` | Conditional |
| `-eq` | Equality |
| `Write-Host` | Output with formatting |

---

## Key Differences: Ubuntu vs Alpine Testing

| Feature | Ubuntu JDK 21 | Alpine JDK 21 |
|---------|---------------|--------------|
| Image base | ubuntu:noble | alpine (minimal) |
| Java version | Zulu 21.0.9 JDK | Zulu 21.0.9 JDK |
| Size | ~423MB | ~150-200MB (smaller) |
| Test 2 | Javac check | Javac check |
| Use case | Development/testing | Lightweight production |

---

## Test Coverage

Both scripts run 7 tests:

1. **Java Version** — Verify JDK 21.0.9 installation
2. **Javac (Compiler)** — Verify Java compiler availability
3. **User Check (appuser)** — Verify non-root user UID 1001
4. **Java Program** — Compile and run Java code
5. **Image Layers** — Display build layers
6. **Image Metadata** — Show image size and info
7. **Environment** — Verify JAVA_HOME and locale

---

## Expected Output

```
Testing Docker image: flipfoundry/docker-base-zulu-alpine:1.0.0
============================================================

[Test 1] Java Version
openjdk version "21.0.9" 2025-10-21 LTS
OpenJDK Runtime Environment Zulu21.46+19-CA (build 21.0.9+10-LTS)
OpenJDK 64-Bit Server VM Zulu21.46+19-CA (build 21.0.9+10-LTS, mixed mode, sharing)
OK

[Test 2] Javac (Compiler)
javac 21.0.9
OK

[Test 3] User Check (appuser)
Verifying appuser exists with UID 1001...
uid=1001(appuser) gid=1001(appgroup) groups=1001(appgroup)
OK - appuser (UID 1001) created successfully

[Test 4] Java Program
Hello Zulu JDK 21 Alpine
OK

[Test 5] Image Layers
ee8a08fad6f8   2 minutes ago    ENV PATH=/usr/lib/jvm/zulu21-jdk/bin:...   0B
...
OK

[Test 6] Image Metadata
REPOSITORY                            TAG    IMAGE ID      CREATED      SIZE
flipfoundry/docker-base-zulu-alpine   1.0.0  ee8a08fad6f8  2 minutes ago 323MB
OK

[Test 7] Environment
JAVA_HOME=/usr/lib/jvm/zulu21-jdk
LANG=en_US.UTF-8
OK

============================================================
Testing complete!
```

---

## Notes

- **JDK 21:** Full Java Development Kit with compiler (javac) - not JRE
- **Alpine + OpenJDK:** Uses OpenJDK 21.0.9 from Alpine repositories (Zulu-compatible)
- **Image size:** 323MB - lightweight compared to Ubuntu (~423MB) while providing full JDK
- **Non-root security:** All tests verify the `appuser` (UID 1001) is properly configured
- **Customization:** Both scripts accept custom image tags for flexibility
