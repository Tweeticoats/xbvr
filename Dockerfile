FROM node:12 as build-env

### Install Go ###
ENV GO_VERSION=1.13.15
ARG TARGETPLATFORM
env GOPATH=/root/go-packages
env GOROOT=/root/go
ENV PATH=/root/go/bin:/root/go-packages/bin:$PATH
WORKDIR /root
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH
RUN if [ "$TARGETPLATFORM" = "linux/arm/v6" ]; then curl -fsSL https://dl.google.com/go/go$GO_VERSION.linux-armv6l.tar.gz | tar -xzv ; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then curl -fsSL https://dl.google.com/go/go$GO_VERSION.linux-armv6l.tar.gz  | tar -xzv ; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then curl -fsSL https://dl.google.com/go/go$GO_VERSION.linux-arm64.tar.gz | tar -xzv; elif [ "$TARGETPLATFORM" = "linux/amd64" ]; then  curl -fsSL https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz  | tar -xzv;  fi;

RUN go get -u -v \
        github.com/acroca/go-symbols \
        github.com/cweill/gotests/... \
        github.com/davidrjenni/reftools/cmd/fillstruct \
        github.com/fatih/gomodifytags \
        github.com/haya14busa/goplay/cmd/goplay \
        github.com/josharian/impl \
        github.com/nsf/gocode \
        github.com/ramya-rao-a/go-outline \
        github.com/rogpeppe/godef \
        github.com/uudashr/gopkgs/cmd/gopkgs \
        github.com/zmb3/gogetdoc \
        golang.org/x/lint/golint \
        golang.org/x/tools/cmd/godoc \
        golang.org/x/tools/cmd/gorename \
        golang.org/x/tools/cmd/guru \
        sourcegraph.com/sqs/goreturns \
        github.com/UnnoTed/fileb0x

WORKDIR /app
ADD . /app
RUN cd /app && \
    yarn install  --network-timeout 1000000  && \
    yarn build && \
    go generate && \
    go build -tags='json1' -ldflags '-w' -o xbvr main.go

FROM gcr.io/distroless/base
COPY --from=build-env /app/xbvr /

EXPOSE 9998-9999
VOLUME /root/.config/

ENTRYPOINT ["/xbvr"]
