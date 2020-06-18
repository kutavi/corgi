FROM golang:1.14-alpine3.11 as builder
RUN apk update && apk add --no-cache make bash ca-certificates
WORKDIR /opt/corgi
COPY . .
RUN set -xe && \
        make env && \
        make mod vendor static

FROM alpine:3.11
COPY --from=builder /opt/corgi/corgi .
USER nobody
CMD ["./corgi"]
