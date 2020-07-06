# syntax=docker/dockerfile:experimental
FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:latest as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN printf "I am running on ${BUILDPLATFORM:-linux/amd64}, building for ${TARGETPLATFORM:-linux/amd64}\n$(uname -a)\n"

ENV WRANGLER_VERSION="1.10.3"

RUN apk --update --no-cache add \
    bash \
    build-base \
    gcc \
    libgcc \
    git \
    rust \
    cargo \
    openssl \
    openssl-dev \
  && rm -rf /tmp/* /var/cache/apk/*

RUN git clone --branch v${WRANGLER_VERSION} https://github.com/cloudflare/wrangler /tmp/wrangler
WORKDIR /tmp/wrangler
RUN cargo build --release

FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:latest

ENV WRANGLER_HOME="/tmp/wrangler"

COPY --from=builder /tmp/wrangler/target/release/wrangler /usr/local/bin/wrangler
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

LABEL maintainer="buildsociety" \
  org.label-schema.name="wrangler" \
  org.label-schema.description="wrangler" \
  org.label-schema.version=$CI_COMMIT_SHORT_SHA \
  org.label-schema.url="https://codedin.wales/buildsociety/wrangler" \
  org.label-schema.vcs-url="https://codedin.wales/buildsociety/wrangler" \
  org.label-schema.vendor="buildsociety" \
  org.label-schema.schema-version="1.0"

RUN apk --update --no-cache add \
    libgcc \
    shadow \
    su-exec \
    bash \
  && rm -rf /tmp/* /var/cache/apk/* \
  && chmod +x /usr/local/bin/entrypoint.sh

RUN wrangler --version

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh", "wrangler" ]
