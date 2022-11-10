# DOT_NET_VERSION need put here to be able to use it in FROM
# ARG DOT_NET_VERSION

FROM golang:1.14 AS builder

WORKDIR /build
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w"
RUN ls -lh


# put the resharper binary in a scratch container
FROM mcr.microsoft.com/dotnet/sdk:6.0-jammy-amd64
ARG RESHARPER_CLI_VERSION

WORKDIR /root
RUN echo 'export PATH="~/.dotnet/tools:$PATH"' >> .bashrc
ENV PATH ~/.dotnet/tools:$PATH

# install jb cli(include inspectcode)
RUN dotnet --info
RUN dotnet tool install JetBrains.ReSharper.GlobalTools --global --version $RESHARPER_CLI_VERSION

COPY --from=builder /build/resharper-action /usr/bin
CMD resharper-action
# CMD dotnet exec
