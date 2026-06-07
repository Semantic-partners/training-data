FROM mcr.microsoft.com/devcontainers/python:1-3.12-bookworm

# Pin tool versions for reproducibility — bump deliberately when needed.
ARG JENA_VERSION=6.1.0
ARG TARQL_VERSION=1.2
ARG TEMURIN_VERSION=21.0.5+11

# Base OS deps. Drop the Yarn apt source from the base image — its signing
# key has expired and breaks apt-get update. We don't need Yarn here.
RUN rm -f /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# Java 21 runtime (Jena 6.x is compiled for Java 21; bookworm only ships 17,
# and bookworm-backports no longer carries openjdk-21). Pull Temurin direct.
RUN curl -fsSL "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jre_x64_linux_hotspot_21.0.5_11.tar.gz" \
        -o /tmp/jre.tar.gz \
    && tar -xzf /tmp/jre.tar.gz -C /opt \
    && mv "/opt/jdk-21.0.5+11-jre" /opt/jre \
    && rm /tmp/jre.tar.gz
ENV JAVA_HOME=/opt/jre
ENV PATH="/opt/jre/bin:${PATH}"

# Apache Jena CLI (riot, sparql, shacl, arq, ...). No Fuseki here —
# GraphDB runs as a sibling service via docker-compose.
RUN curl -fsSL "https://dlcdn.apache.org/jena/binaries/apache-jena-${JENA_VERSION}.tar.gz" \
        -o /tmp/jena.tar.gz \
    && tar -xzf /tmp/jena.tar.gz -C /opt \
    && mv "/opt/apache-jena-${JENA_VERSION}" /opt/jena \
    && rm /tmp/jena.tar.gz

# TARQL — SPARQL over CSV. The released tarball doesn't preserve the
# executable bit on the launcher scripts, so chmod after extracting.
RUN curl -fsSL "https://github.com/tarql/tarql/releases/download/v${TARQL_VERSION}/tarql-${TARQL_VERSION}.tar.gz" \
        -o /tmp/tarql.tar.gz \
    && tar -xzf /tmp/tarql.tar.gz -C /opt \
    && mv "/opt/tarql-${TARQL_VERSION}" /opt/tarql \
    && chmod +x /opt/tarql/bin/* \
    && rm /tmp/tarql.tar.gz

# Apache Jena ships with the right bits set, but belt-and-braces in case
# the same tarball-strip happens.
RUN chmod +x /opt/jena/bin/*

ENV PATH="/opt/jena/bin:/opt/tarql/bin:${PATH}"
ENV JENA_HOME=/opt/jena

# GraphDB endpoint reachable from this container via the compose network
ENV GRAPHDB_URL=http://graphdb:7200

# Python SHACL + mapping + testing tooling
RUN pip install --no-cache-dir \
        rdflib \
        pyshacl \
        morph-kgc \
        mustrd
