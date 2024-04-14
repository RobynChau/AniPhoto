FROM quay.io/keycloak/keycloak:latest as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# change these values to point to a running postgres instance
ENV KC_DB=postgres
ENV KC_DB_URL=jdbc:postgresql://ep-late-tree-a1oy2h84.ap-southeast-1.aws.neon.tech/keycloak-vhuynh?sslmode=require
ENV KC_DB_USERNAME=keycloak-vhuynh_owner
ENV KC_DB_PASSWORD=1hqSFDyBLgj3
ENV KC_HOSTNAME_URL="https://keycloak.vohuynh19.info"
ENV KC_HOSTNAME_STRICT_HTTPS="true"
ENV KC_HOSTNAME_STRICT_BACKCHANNEL="true"
ENV KC_PROXY=edge

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]