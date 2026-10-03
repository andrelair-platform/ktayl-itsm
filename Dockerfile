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

# NOTE: the minicloud CA is NOT baked here. The MINICLOUD_CA_CERT org secret is stored flattened
# (body-less → a lone "-----BEGIN CERTIFICATE-----" → invalid cert that breaks curl's strict loader),
# so baking it (build-arg OR secret mount) corrupts the trust store. Instead the minicloud CA is
# injected at RUNTIME from the trust-manager `minicloud-ca-bundle` configmap via a CA-trust
# initContainer in the wrapper chart (the known-good source). Base image trust store stays clean.

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
