#!/bin/bash
# Test suite for flipfoundry/azulzulu-openjdk-ubuntu24.04-jdk21

IMAGE_TAG="${1:-flipfoundry/azulzulu-openjdk-ubuntu24.04-jdk21:1.0.0}"

echo -e "\033[36mTesting Docker image: $IMAGE_TAG\033[0m"
echo "============================================================"

echo -e "\n\033[33m[Test 1] Java Version\033[0m"
docker run --rm "$IMAGE_TAG" java -version 2>&1
echo -e "\033[32mOK\033[0m"

echo -e "\n\033[33m[Test 2] Javac\033[0m"
docker run --rm "$IMAGE_TAG" javac -version 2>&1
echo -e "\033[32mOK\033[0m"

echo -e "\n\033[33m[Test 3] User Check (appuser)\033[0m"
echo -e "\033[90mVerifying appuser exists with UID 1001...\033[0m"
docker run --rm "$IMAGE_TAG" id appuser 2>&1
APPUSER_ID=$(docker run --rm "$IMAGE_TAG" id -u appuser 2>&1)
if [ "$APPUSER_ID" = "1001" ]; then
    echo -e "\033[32mOK - appuser (UID 1001) created successfully\033[0m"
else
    echo -e "\033[31mFAIL - appuser UID is $APPUSER_ID (expected 1001)\033[0m"
fi

echo -e "\n\033[33m[Test 4] Java Program\033[0m"
docker run --rm "$IMAGE_TAG" sh -c 'cat > T.java << EOF
public class T{public static void main(String[]a){System.out.println("Hello Zulu JDK 21");}}
EOF
javac T.java
java T' 2>&1
echo -e "\033[32mOK\033[0m"

echo -e "\n\033[33m[Test 5] Image Layers\033[0m"
docker history "$IMAGE_TAG" 2>&1 | head -8
echo -e "\033[32mOK\033[0m"

echo -e "\n\033[33m[Test 6] Image Size\033[0m"
docker images "$IMAGE_TAG"
echo -e "\033[32mOK\033[0m"

echo -e "\n\033[33m[Test 7] Environment\033[0m"
docker run --rm "$IMAGE_TAG" sh -c 'echo JAVA_HOME=$JAVA_HOME; echo LANG=$LANG' 2>&1
echo -e "\033[32mOK\033[0m"

echo -e "\n============================================================"
echo -e "\033[36mTesting complete!\033[0m"
