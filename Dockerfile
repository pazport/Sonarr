# Builds Sonarr from source and runs it.
#
#   docker build -t sonarr .
#   docker run -d -p 8989:8989 -v /path/to/config:/config sonarr

ARG DOTNET_SDK_VERSION=10.0.402

# Frontend
FROM --platform=$BUILDPLATFORM node:24-bookworm-slim AS ui
WORKDIR /src

COPY package.json yarn.lock .yarnrc ./
RUN yarn install --frozen-lockfile --network-timeout 300000

COPY . .
RUN yarn build

# Backend
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:${DOTNET_SDK_VERSION} AS backend
ARG TARGETARCH
WORKDIR /src

COPY . .
RUN case "$TARGETARCH" in \
      amd64) runtime=linux-x64 ;; \
      arm64) runtime=linux-arm64 ;; \
      arm) runtime=linux-arm ;; \
      *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
    esac && \
    dotnet msbuild -restore src/Sonarr.sln \
      -p:SelfContained=true -p:Configuration=Release -p:Platform=Posix \
      -p:RuntimeIdentifiers=$runtime -t:PublishAllRids && \
    mkdir -p /app && \
    cp -r _output/net10.0/$runtime/publish/. /app && \
    cp -r _output/Sonarr.Update/net10.0/$runtime/publish /app/Sonarr.Update && \
    rm -f /app/ServiceInstall.* /app/ServiceUninstall.* /app/Sonarr.Windows.*

COPY --from=ui /src/_output/UI /app/UI

# Runtime
FROM mcr.microsoft.com/dotnet/runtime-deps:10.0

# The base image provides a non-root "app" user ($APP_UID)
RUN mkdir -p /config && chown $APP_UID:$APP_UID /config

COPY --from=backend --chown=$APP_UID:$APP_UID /app /app

USER $APP_UID
EXPOSE 8989
VOLUME /config

ENTRYPOINT ["/app/Sonarr", "-nobrowser", "-data=/config"]
