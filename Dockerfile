# Build stage
FROM golang:1.24 AS builder

WORKDIR /app

ENV GOTOOLCHAIN=auto
ENV GODEBUG=preferIPv4Lookups=1
ENV CGO_ENABLED=0


COPY go.mod go.sum ./
RUN --mount=type=cache,target=/root/go/pkg/mod go mod download

COPY . .

RUN --mount=type=cache,target=/root/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o contract-service ./cmd/server

# Final stage
FROM alpine:3.21

RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

COPY --from=builder /app/contract-service .

EXPOSE 3014

CMD ["./contract-service"]
