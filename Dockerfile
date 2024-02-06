# STAGE 1: Build
FROM golang:1.12-alpine AS build

# Install Node and NPM.
RUN apk update && apk upgrade && apk add --no-cache git nodejs bash npm

# Get dependencies for Go part of build
RUN go get -u github.com/jteeuwen/go-bindata/...

WORKDIR /go/src/github.com/kubernetes-up-and-running/kuard

# Copy all sources in
COPY . .

# To be filled by build tools such as buildx
# Sample build command:
# docker buildx build --push --platform linux/amd64,linux/arm64 \
#    --tag antsinmyey3sjohnson/yet-another-kuard-image:1.0.1 \
#    --tag antsinmyey3sjohnson/yet-another-kuard-image:latest \
#    .
ARG TARGETOS TARGETARCH

# This is a set of variables that the build script expects
ENV VERBOSE=0
ENV PKG=github.com/kubernetes-up-and-running/kuard
ENV VERSION=test

# When running on Windows 10, you need to clean up the ^Ms in the script
RUN dos2unix build/build.sh

# Do the build. Script is part of incoming sources.
RUN build/build.sh

# STAGE 2: Runtime
FROM alpine

USER nobody:nobody
COPY --from=build /go/bin/kuard /kuard

CMD [ "/kuard" ]
