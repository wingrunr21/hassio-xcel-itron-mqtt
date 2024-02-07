ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG XCEL_ITRON2MQTT_SHA=b89b5fff5cba49401b23ea7652c6439dc7d0922d

# Copy python source from upstream
RUN curl -L https://github.com/zaknye/xcel_itron2mqtt/archive/${XCEL_ITRON2MQTT_SHA}.zip -o /tmp/main.zip && \
  mkdir -p /tmp/xcel_itron2mqtt/ && \
  unzip /tmp/main.zip -j -d /tmp/xcel_itron2mqtt && \
  mv /tmp/xcel_itron2mqtt /opt && \
  rm /opt/xcel_itron2mqtt/run.sh && \ 
  rm -rf /tmp/main.zip && \
  apk del libssl3 libcrypto3 && apk add --no-cache openssl && \
  pip3 install --no-cache-dir \
  --prefer-binary \
  -r /opt/xcel_itron2mqtt/requirements.txt

# Copy root filesystem
COPY rootfs /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
  io.hass.name="${BUILD_NAME}" \
  io.hass.description="${BUILD_DESCRIPTION}" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="addon" \
  io.hass.version=${BUILD_VERSION} \
  org.opencontainers.image.title="${BUILD_NAME}" \
  org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
  org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.url="https://addons.community" \
  org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
  org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
  org.opencontainers.image.created=${BUILD_DATE} \
  org.opencontainers.image.revision=${BUILD_REF} \
  org.opencontainers.image.version=${BUILD_VERSION}
