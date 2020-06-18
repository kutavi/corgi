FROM golang:1.14-alpine3.11 as builder
RUN apk update && apk add --no-cache make bash ca-certificates
WORKDIR /opt/corgi
COPY . .
RUN set -xe && \
        make env && \
        make mod vendor static

#FROM scratch
#COPY --from=builder /etc/ssl/certs/ /etc/ssl/certs
FROM alpine:3.11
RUN apk add --no-cache ca-certificates
COPY --from=builder /opt/corgi/corgi .
USER nobody
CMD ["./corgi"]
