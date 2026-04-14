# Build stage
FROM golang:1.24-alpine AS builder

WORKDIR /app

ENV GOTOOLCHAIN=auto
ENV GODEBUG=preferIPv4Lookups=1
ENV CGO_ENABLED=0

RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o contract-service ./cmd/server

# Final stage
FROM alpine:3.21

RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

COPY --from=builder /app/contract-service .

EXPOSE 3014

CMD ["./contract-service"]
