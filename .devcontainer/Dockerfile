FROM mcr.microsoft.com/devcontainers/python:1-3.12-bookworm

# Pin tool versions for reproducibility — bump deliberately when needed.
ARG JENA_VERSION=6.1.0
ARG FUSEKI_VERSION=6.1.0
ARG TARQL_VERSION=1.2

# Java runtime (needed by Jena, Fuseki, TARQL) + curl for downloads.
# Drop the Yarn apt source from the base image — its signing key has expired
# and breaks apt-get update. We don't need Yarn here.
RUN rm -f /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        default-jre-headless \
        ca-certificates \
        curl \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# Apache Jena CLI (riot, sparql, shacl, arq, ...)
RUN curl -fsSL "https://dlcdn.apache.org/jena/binaries/apache-jena-${JENA_VERSION}.tar.gz" \
        -o /tmp/jena.tar.gz \
    && tar -xzf /tmp/jena.tar.gz -C /opt \
    && mv "/opt/apache-jena-${JENA_VERSION}" /opt/jena \
    && rm /tmp/jena.tar.gz

# Apache Jena Fuseki (SPARQL server)
RUN curl -fsSL "https://dlcdn.apache.org/jena/binaries/apache-jena-fuseki-${FUSEKI_VERSION}.tar.gz" \
        -o /tmp/fuseki.tar.gz \
    && tar -xzf /tmp/fuseki.tar.gz -C /opt \
    && mv "/opt/apache-jena-fuseki-${FUSEKI_VERSION}" /opt/fuseki \
    && rm /tmp/fuseki.tar.gz

# TARQL — SPARQL over CSV
RUN curl -fsSL "https://github.com/tarql/tarql/releases/download/v${TARQL_VERSION}/tarql-${TARQL_VERSION}.tar.gz" \
        -o /tmp/tarql.tar.gz \
    && tar -xzf /tmp/tarql.tar.gz -C /opt \
    && mv "/opt/tarql-${TARQL_VERSION}" /opt/tarql \
    && rm /tmp/tarql.tar.gz

ENV PATH="/opt/jena/bin:/opt/fuseki:/opt/tarql/bin:${PATH}"
ENV JENA_HOME=/opt/jena
ENV FUSEKI_HOME=/opt/fuseki
ENV FUSEKI_BASE=/workspaces/training-data/.fuseki

# Python SHACL + mapping + testing tooling
RUN pip install --no-cache-dir \
        rdflib \
        pyshacl \
        morph-kgc \
        mustrd
