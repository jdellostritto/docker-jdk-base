FROM alpine@sha256:635f0aa53d99017b38d1a0aa5b2082f7812b03e3cdb299103fe77b5c8a07f1d2
# Make the directory
RUN mkdir -p /usr/app

# Create a user group 'appgroup'
RUN addgroup -g 1001 appgroup
# Create a user
RUN adduser -u 1001 -G appgroup -h /usr/app -D appuser

# Chown all the files to the app user.
RUN chown -R appuser:appgroup /usr/app


ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install necessary packages for Azul Zulu and set up locales
RUN apk add --no-cache \
    fontconfig \
    libretls \
    musl-locales \
    musl-locales-lang \
    tzdata \
    zlib \
    libc6-compat \
    # Add Azul's public key and repository
    && wget -P /etc/apk/keys/ https://cdn.azul.com/public_keys/alpine-signing@azul.com-5d5dc44c.rsa.pub \
    && echo "https://repos.azul.com/zulu/alpine" | tee -a /etc/apk/repositories \
    && apk update \
    # Install Azul Zulu 21 JDK
    && apk add zulu21-jdk \
    && rm -rf /var/cache/apk/*

ENV JAVA_HOME=/usr/lib/jvm/zulu21-jdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"