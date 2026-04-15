# Build stage
FROM golang:1.24 AS builder

WORKDIR /app

ENV GOTOOLCHAIN=local
ENV GODEBUG=preferIPv4Lookups=1
ENV GONOSUMDB=*
ENV GOPROXY=https://proxy.golang.org,direct
ENV CGO_ENABLED=0


COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o contract-service ./cmd/server

# Final stage
FROM alpine:3.21

WORKDIR /app

COPY --from=builder /app/contract-service .

EXPOSE 3014

CMD ["./contract-service"]
