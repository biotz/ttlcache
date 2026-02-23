# base =========================================================================
FROM debian:trixie-slim AS base

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# dev ==========================================================================
FROM base AS dev

# hadolint ignore=DL3022
COPY --from=eclipse-temurin:21-jdk $JAVA_HOME $JAVA_HOME

ENV CLJ_KONDO_VERSION=2026.01.19
ENV BINARIES_INSTALL_PATH=/usr/local/bin

RUN set -eux; \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    leiningen=2.10.0-5 \
    ca-certificates=20250419 \
    runit=2.2.0-3 \
    unzip=6.0-29 \
    curl=8.14.1-2+deb13u2 && \
    useradd --home-dir /home/hop --create-home --shell /bin/bash --user-group hop && \
    curl -sL -o /tmp/install-clj-kondo "https://raw.githubusercontent.com/clj-kondo/clj-kondo/master/script/install-clj-kondo" && \
    chmod 755 /tmp/install-clj-kondo && \
    ./tmp/install-clj-kondo --version "${CLJ_KONDO_VERSION}" --dir "${BINARIES_INSTALL_PATH}" && \
    apt-get -y purge curl unzip && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY docker/run-as-user.sh "${BINARIES_INSTALL_PATH}"

WORKDIR /app

ENTRYPOINT ["run-as-user.sh"]
