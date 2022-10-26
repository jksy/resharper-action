# DOT_NET_VERSION need put here to be able to use it in FROM
ARG DOT_NET_VERSION

FROM golang:1.14 AS builder

WORKDIR /build
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w"
RUN ls -lh

# put the resharper binary in a scratch container
FROM mcr.microsoft.com/dotnet/sdk:${DOT_NET_VERSION}
ARG RESHARPER_CLI_VERSION

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
  && dpkg -i packages-microsoft-prod.deb \
  && rm -f packages-microsoft-prod.deb \
  && apt-get update \
  && apt-get install -y dotnet-sdk-6.0 \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/share/dotnet/sdk/NuGetFallbackFolder

WORKDIR /resharper
RUN \
  curl -o resharper.zip -L "https://download.jetbrains.com/resharper/dotUltimate.$RESHARPER_CLI_VERSION/JetBrains.ReSharper.CommandLineTools.$RESHARPER_CLI_VERSION.zip" \
  && unzip resharper.zip \
  && rm resharper.zip \
  && rm -rf macos-x64
ENV PATH="/resharper:${PATH}"

# this is the same as the base image
WORKDIR /

COPY --from=builder /build/resharper-action /usr/bin
CMD resharper-action
