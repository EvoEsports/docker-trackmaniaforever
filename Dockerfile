# build trackmania_exporter
FROM python:3.11-alpine3.18 AS exporter-build
WORKDIR /build
COPY trackmania_exporter .
RUN apk upgrade && apk add binutils && pip3 install --root-user-action=ignore prometheus-client pyinstaller && pyinstaller --onefile --console --clean --strip trackmania_exporter.py

# build trackmania forever image
FROM alpine:3.18

ARG GLIBC_VERSION="2.33-r0" \
    TMSERVER_VERSION="2011-02-21" \
    UID="9999" \
    GID="9999" \
    VERSION \
    BUILD_DATE \
    REVISION

LABEL org.opencontainers.image.title="Trackmania Forever Server" \
      org.opencontainers.image.description="Server for the game Trackmania Forever, released in 2008 by Nadeo." \
      org.opencontainers.image.authors="Nicolas Graf <nicolas.graf@evoesports.gg>" \
      org.opencontainers.image.vendor="Evo eSports e.V." \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version=${VERSION} \
      org.opencontainers.image.created=${BUILD_DATE} \
      org.opencontainers.image.revision=${REVISION}

WORKDIR /server

RUN true \
    && set -eux \
    && addgroup -g $GID trackmania \
    && adduser -u $UID -Hh /server -G trackmania -s /sbin/nologin -D trackmania \
    && install -d -o trackmania -g trackmania -m 775 /server \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget -q -O /etc/apk/glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
    && apk upgrade \
    && apk add --force-overwrite --no-cache /etc/apk/glibc.apk xmlstarlet bash unzip curl jq su-exec \
    && curl -so /server/server.zip http://files2.trackmaniaforever.com/TrackmaniaServer_${TMSERVER_VERSION}.zip \
    && unzip -q /server/server.zip \
    && rm -Rf /etc/apk/glibc.apk /server/server.zip /server/RemoteControlExamples /server/TrackmaniaServer.exe /server/*.html /server/manialink_dedicatedserver.txt \
    && mv /server/GameData/Config/dedicated_cfg.txt /server/GameData/Config/dedicated_cfg.default.txt \
    && chown trackmania:trackmania -Rf /server \
    && true

COPY --chmod=0755 template/example-matchsettings.txt /server/GameData/Tracks/MatchSettings/example.txt
COPY --chmod=0755 entrypoint.sh /usr/local/bin/
COPY --chmod=0755 --from=exporter-build /build/dist/trackmania_exporter /usr/local/bin/

USER trackmania

EXPOSE 2350/tcp
EXPOSE 2350/udp
EXPOSE 3450/tcp
EXPOSE 3450/udp
EXPOSE 5000/tcp
EXPOSE 9000/tcp

HEALTHCHECK --interval=5s --timeout=5s --start-period=20s --retries=3 \
    CMD [ "/bin/sh", "-c", "nc -z -v 127.0.0.1 5000 || exit 1" ]

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "./TrackmaniaServer" ]
