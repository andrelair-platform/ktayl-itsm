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

# minicloud CA via a BuildKit SECRET MOUNT (not a build-arg — build-args flatten the multiline PEM to
# one line → invalid cert; a secret mount preserves it). update-ca-certificates then regenerates a
# clean, canonical trust store (runtime cat/awk/openssl combine kept corrupting it → curl exit 77).
RUN --mount=type=secret,id=ca_cert \
    cp /run/secrets/ca_cert /usr/local/share/ca-certificates/minicloud-ca.crt \
    && update-ca-certificates

# Apache binds 80 via a cap_net_bind_service FILE capability — negated under the cluster's
# no-privilege-escalation policy (no_new_privs), so bind-80 fails. Move to the unprivileged 8080 so
# GLPI runs fully non-root with allowPrivilegeEscalation:false + dropped caps. Service maps 80->8080.
RUN sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf \
    && setcap -r /usr/sbin/apache2 || true
# ^ Strip apache's cap_net_bind_service FILE capability: under no_new_privs (allowPrivilegeEscalation:false)
# the kernel REFUSES to exec a file-capability binary (EPERM, exit 126). On 8080 the cap is unneeded, so
# removing it lets apache exec normally and bind the unprivileged port.

USER www-data
