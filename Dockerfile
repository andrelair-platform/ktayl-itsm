# Custom GLPI image for the ktayl-solution ITSM (board #16, ITSM-01/S001).
# FROM the official non-root glpi/glpi (runs as www-data — no Gatekeeper exemption needed) +
# the minicloud CA so GLPI's PHP/curl trusts the INTERNAL OIDC back-channel (auth.devandre.sbs
# resolves via split-horizon DNS to the minicloud-CA-signed ingress — see S002/SSO).
# ITIL marketplace plugins + the OIDC SSO plugin are added in later stories; this image = base +
# security patch + CA trust (the custom-image justification per docs/deployment-architecture.md).
FROM glpi/glpi:10.0.28

USER root

RUN apt-get update && apt-get upgrade -y --no-install-recommends \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# minicloud CA injected at build time via --build-arg (CI passes the MINICLOUD_CA_CERT secret).
# Raw PEM — never committed, never base64-decoded. GLPI (PHP) uses the OS trust store.
ARG CA_CERT
RUN printf '%s\n' "${CA_CERT}" > /usr/local/share/ca-certificates/minicloud-ca.crt \
    && update-ca-certificates \
    && test "$(wc -l < /usr/local/share/ca-certificates/minicloud-ca.crt)" -gt 1

USER www-data
