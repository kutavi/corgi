FROM golang:1.15.6-alpine3.12 as builder
RUN apk update && apk add --no-cache make bash ca-certificates
WORKDIR /opt/corgi
COPY . .
RUN set -xe && \
        make env && \
        make build

#FROM scratch
#COPY --from=builder /etc/ssl/certs/ /etc/ssl/certs
FROM alpine:3.12
RUN apk add --no-cache ca-certificates
COPY --from=builder /opt/corgi/corgi .
USER nobody
CMD ["./corgi"]
