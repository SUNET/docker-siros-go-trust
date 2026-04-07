# Multi-stage Docker build: go-trust binary for LoTE-based trust evaluation
# Builds go-trust from sirosfoundation/go-trust
FROM golang:1.25-alpine AS builder

RUN apk add --no-cache \
    git \
    build-base \
    libxml2-dev \
    libxslt-dev \
    pkgconfig

WORKDIR /build

RUN git clone https://github.com/sirosfoundation/go-trust.git .

RUN go mod download && \
    CGO_ENABLED=1 GOOS=linux go build -a -trimpath \
    -ldflags="-X main.Version=${VERSION:-dev} -w -s" \
    -o gt ./cmd

# Final runtime stage
FROM alpine:latest

RUN apk add --no-cache \
    ca-certificates \
    bash \
    openssl \
    libxml2 \
    libxslt \
    curl \
    && update-ca-certificates

RUN addgroup -g 1000 appgroup && \
    adduser -D -s /bin/sh -u 1000 -G appgroup gotrust

RUN mkdir -p /app /etc/go-trust && \
    chown -R gotrust:appgroup /app /etc/go-trust

WORKDIR /app

COPY --from=builder /build/gt .
COPY ./config/config.yaml /etc/go-trust/config.yaml
COPY ./pipeline.yaml ./pipeline.yaml
COPY ./start.sh ./start.sh

RUN chmod +x gt start.sh

USER gotrust

EXPOSE 6002

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://127.0.0.1:6002/healthz || exit 1

CMD ["./start.sh"]
