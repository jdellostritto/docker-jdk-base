# Image Testing Guide

This folder contains automated test scripts to validate the `flipfoundry/azulzulu-openjdk-ubuntu24.04-jdk21` Docker image. Two versions are provided: PowerShell and Bash.

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

### **File Structure**

#### **Shebang & Parameter**
```bash
#!/bin/bash
```
Tells the system to execute this file with `/bin/bash` interpreter.

```bash
IMAGE_TAG="${1:-flipfoundry/azulzulu-openjdk-ubuntu24.04-jdk21:1.0.0}"
```
**Syntax Explanation:**
- `${1:-...}` — Parameter expansion with default value
- `$1` — First command-line argument
- `:-` — Operator meaning "use default if unset or null"
- Allows: `bash test-image.sh custom:tag` or just `bash test-image.sh`

#### **Output Formatting**
```bash
echo -e "\033[36mTesting Docker image: $IMAGE_TAG\033[0m"
```
**Syntax Explanation:**
- `echo -e` — Enable interpretation of backslash escapes
- `\033[36m` — ANSI color code for cyan (36m)
- `$IMAGE_TAG` — Variable substitution (expanded within double quotes)
- `\033[0m` — ANSI reset code (back to default)
- **Colors used:**
  - `36m` = Cyan (headers)
  - `33m` = Yellow (test labels)
  - `32m` = Green (OK status)
  - `90m` = Dark gray (output details)

```bash
echo "============================================================"
```
Simple separator line (plain text, no escapes needed).

### **Tests 1-3: Simple Docker Commands**

#### **Test 1: Java Version**
```bash
docker run --rm "$IMAGE_TAG" java -version 2>&1
echo -e "\033[32mOK\033[0m"
```
**Syntax Explanation:**
- `docker run` — Execute a new container
- `--rm` — Automatically remove container after it exits
- `"$IMAGE_TAG"` — Quoted variable (prevents word splitting on spaces)
- `java -version` — Command to execute inside container
- `2>&1` — Redirect stderr (file descriptor 2) to stdout (file descriptor 1)
  - Combines error messages with normal output
  - Shows complete output in one stream

#### **Test 3: User Check - Verify appuser Creation**
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
- `$(...)` — Command substitution; captures command output into variable
- `id appuser` — Displays user details (UID, GID, groups)
- `id -u appuser` — Extracts just the numeric UID
- `if [ condition ]; then ... fi` — Conditional branching in bash
- Verifies the Dockerfile created the non-root user with correct UID 1001

### **Test 4: Heredoc (Multi-line Input)**

```bash
docker run --rm "$IMAGE_TAG" sh -c 'cat > T.java << EOF
public class T{public static void main(String[]a){System.out.println("Hello Zulu JDK 21");}}
EOF
javac T.java
java T' 2>&1
```

**Syntax Explanation:**
- `sh -c 'command'` — Execute shell commands inside container
  - `-c` — Read commands from string argument
  - Single quotes preserve literal content
- `cat > T.java << EOF` — Heredoc syntax for multi-line input
  - `<<` — Read input until marker
  - `EOF` — End-of-file marker (arbitrary word, e.g., `MARKER`, `END`)
  - `> T.java` — Redirect heredoc content to file
- Content between `<<EOF` and `EOF` becomes the input
- No escaping needed inside heredoc
- Semicolons `;` separate multiple commands

### **Test 5-7: Piping and Advanced Operations**

#### **Test 5: Piping with head**
```bash
docker history "$IMAGE_TAG" 2>&1 | head -8
```
**Syntax Explanation:**
- `|` — Pipe operator; send output as input to next command
- `head -8` — Display first 8 lines of input
- Useful for truncating large outputs

#### **Test 6: Simple Image Display**
```bash
docker images "$IMAGE_TAG"
```
Displays image metadata in table format (no special syntax needed).

#### **Test 7: Environment Variables with Semicolon**
```bash
docker run --rm "$IMAGE_TAG" sh -c 'echo JAVA_HOME=$JAVA_HOME; echo LANG=$LANG' 2>&1
```
**Syntax Explanation:**
- Single quotes `'...'` — Literal string (no variable expansion by host bash)
- `$JAVA_HOME` — Shell variable inside container (not expanded by host)
- `;` — Command separator (execute multiple commands sequentially)
- Without `;`, commands must be on separate lines

### **Bash Syntax Reference**

| Syntax | Purpose | Example |
|--------|---------|---------|
| `${1:-default}` | Use arg or default | `${IMAGE:-default:tag}` |
| `$(command)` | Command substitution | `$(docker ps)` |
| `"$var"` | Variable substitution | `"$IMAGE_TAG"` |
| `'literal'` | No expansion | `'$VAR_NOT_EXPANDED'` |
| `2>&1` | Redirect stderr to stdout | `docker run ... 2>&1` |
| `\|` | Pipe output | `docker ps \| head -5` |
| `<< MARKER` | Heredoc (multi-line) | `cat << EOF ... EOF` |
| `;` | Sequential separator | `cmd1; cmd2; cmd3` |
| `\033[XXm` | ANSI color codes | `\033[32m` (green) |
| `-e` flag | Enable escapes in echo | `echo -e "\033[32m"` |

---

## PowerShell Script Breakdown

### **File Structure**

#### **Parameter Definition**
```powershell
param(
    [string]$ImageTag = "flipfoundry/azulzulu-openjdk-ubuntu24.04-jdk21:1.0.0"
)
```
**Syntax Explanation:**
- `param(...)` — Define script parameters
- `[string]` — Type declaration (enforces string type)
- `$ImageTag` — Variable name (note: `$` prefix required in PowerShell)
- `= "default"` — Default value if not provided
- Called as: `.\test-image.ps1 -ImageTag "custom:tag"`

#### **Output Formatting**
```powershell
Write-Host "Testing Docker image: $ImageTag" -ForegroundColor Cyan
```
**Syntax Explanation:**
- `Write-Host` — Output to console (not output stream)
- `-ForegroundColor` — Text color parameter
- `$ImageTag` — Variable substitution (works in double quotes)
- **Colors:** `Cyan`, `Yellow`, `Green`, `Gray`, `Red`

#### **Backtick for Line Continuation**
```powershell
echo -e "\033[36mTesting Docker image: $ImageTag\033[0m"
```
In PowerShell, backtick `` ` `` continues a line:
```powershell
docker run --rm $ImageTag `
    java -version 2>&1
```

### **Tests 1-3: Simple Docker Commands**

#### **Test 1: Direct Output**
```powershell
docker run --rm $ImageTag java -version 2>&1
Write-Host "OK" -ForegroundColor Green
```
**Syntax Explanation:**
- `docker run` — Same as bash
- `--rm` — Same as bash
- `$ImageTag` — Variable (no quotes needed if no spaces)
- `2>&1` — Same redirects as bash
- `Write-Host` — Display text with formatting

#### **Test 3: User Check - Verify appuser Creation**
```powershell
Write-Host "`n[Test 3] User Check (appuser)" -ForegroundColor Yellow
Write-Host "Verifying appuser exists with UID 1001..." -ForegroundColor Gray
docker run --rm $ImageTag id appuser 2>&1
$appuser_id = docker run --rm $ImageTag id -u appuser 2>&1
if ($appuser_id -eq "1001") {
    Write-Host "OK - appuser (UID 1001) created successfully" -ForegroundColor Green
} else {
    Write-Host "FAIL - appuser UID is $appuser_id (expected 1001)" -ForegroundColor Red
}
```
**Syntax Explanation:**
- `$appuser_id = ...` — Assignment operator (stores command output in variable)
- `id appuser` — Docker command to get user details
- `id -u appuser` — Extracts just the numeric UID
- `if (...) { } else { }` — Conditional branching in PowerShell
- `-eq` — Equality operator (same as == in other languages)
- Verifies the Dockerfile created the non-root user with correct UID 1001

### **Test 4: Inline Script Execution**

```powershell
docker run --rm $ImageTag sh -c "cat > T.java << 'EOF'
public class T{public static void main(String[]a){System.out.println(\"OK\");}}
EOF
javac T.java
java T" 2>&1
```

**Syntax Explanation:**
- `sh -c "..."` — Execute shell script (same as bash)
- Double quotes allow variable expansion
- `\"` — Escaped quotes inside double-quoted string
- Heredoc works the same as bash
- Semicolons separate commands

### **Tests 5-7: Advanced Operations**

#### **Test 5: Piping**
```powershell
docker history $ImageTag 2>&1 | Select-Object -First 8
```
**Syntax Explanation:**
- `|` — Pipe operator (same as bash, but different cmdlets)
- `Select-Object -First 8` — PowerShell equivalent of `head -8`
- More verbose than bash but type-safe (works with objects, not just text)

#### **Test 6: Image Display**
```powershell
docker images $ImageTag
```
Same as bash (docker command output is text).

#### **Test 7: Environment with Semicolon**
```powershell
docker run --rm $ImageTag sh -c "echo JAVA_HOME=`$JAVA_HOME;echo LANG=`$LANG" 2>&1
```
**Syntax Explanation:**
- Double quotes allow variable substitution
- `` `$JAVA_HOME `` — Backtick escapes `$` (treats as literal, not PowerShell variable)
- `;` — Command separator (same as bash)

### **PowerShell Syntax Reference**

| Syntax | Purpose | Example |
|--------|---------|---------|
| `param(...)` | Define parameters | `param([string]$Tag = "default")` |
| `$variable` | Variable (prefix required) | `$ImageTag` |
| `$(...) ` | Command substitution | `$(docker ps)` |
| `"string"` | Quoted string (expansion) | `"Image: $ImageTag"` |
| `'literal'` | Literal string (no expansion) | `'$NotExpanded'` |
| `` `$ `` | Escape dollar sign | `` `$Literal `` |
| `-Parameter` | Named parameter | `-ForegroundColor Green` |
| `2>&1` | Redirect stderr to stdout | Same as bash |
| `\|` | Pipe operator | `docker ps \| Select-Object -First 5` |
| `;` | Sequential separator | `cmd1; cmd2; cmd3` |
| `` ` `` | Line continuation | `command `  (backtick at end) |
| `Select-Object` | Filter/select output | `... \| Select-Object -First 10` |

### **Key Differences: Bash vs PowerShell**

| Feature | Bash | PowerShell |
|---------|------|-----------|
| Variable prefix | Optional `$` | Required `$` |
| Command substitution | `$(...)` or `` `...` `` | `$(...) ` |
| Default parameter | `${1:-default}` | `param([string]$arg = "default")` |
| Output command | `echo` | `Write-Host` |
| Pipe filtering | `head`, `tail`, `grep` | `Select-Object`, `Where-Object` |
| Colors | ANSI codes `\033[XXm` | Named colors `-ForegroundColor` |
| String quoting | `'` (literal), `"` (expand) | `'` (literal), `"` (expand) |
| Line continuation | End with `\|` | Backtick `` ` `` at end |

---

## Test Coverage

Both scripts run 7 identical tests:

1. **Java Version** — Verify OpenJDK installation
2. **Javac** — Verify Java compiler availability
3. **User Check (appuser)** — Verify non-root user created with UID 1001
4. **Java Program** — Compile and execute simple program
5. **Image Layers** — Display Docker build layers
6. **Image Size** — Show image metadata and size
7. **Environment** — Verify Java environment variables

---

## Expected Output

All tests should pass with green status. Example final output:
```
Testing Docker image: flipfoundry/azulzulu-openjdk-ubuntu24.04-jdk21:1.0.0
============================================================

[Test 1] Java Version
openjdk version "21.0.9" 2025-10-21 LTS
...
OK

[Test 2] Javac
javac 21.0.9
OK

[Test 3] User Check (appuser)
Verifying appuser exists with UID 1001...
uid=1001(appuser) gid=1001(appgroup) groups=1001(appgroup)
OK - appuser (UID 1001) created successfully

[Test 4] Java Program
Hello Zulu JDK 21
OK

[Test 5] Image Layers
...
OK

[Test 6] Image Size
REPOSITORY   TAG    IMAGE ID      CREATED      SIZE
flipfoundry/azulzulu-openjdk-ubuntu24.04-jdk21   1.0.0   5d35b3f08630   9 minutes ago   423MB
OK

[Test 7] Environment
JAVA_HOME=/usr/lib/jvm/zulu21-ca-amd64
LANG=en_US.UTF-8
OK

============================================================
Testing complete!
```

---

## Customization

Both scripts accept custom image tags:

```bash
# Bash
bash test-image.sh myregistry/custom-image:2.0.0

# PowerShell
powershell -ExecutionPolicy Bypass -File test-image.ps1 -ImageTag "myregistry/custom-image:2.0.0"
```

Modify the default image tag in each script if you prefer a different default.
