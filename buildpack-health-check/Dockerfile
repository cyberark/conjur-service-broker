FROM golang:1.22-alpine
MAINTAINER CyberArk Software, Inc.

ENV GOOS=linux \
    GOARCH=amd64 \
    CGO_ENABLED=0

WORKDIR /buildpack-health-check

COPY go.mod go.sum /buildpack-health-check/

RUN go mod download
