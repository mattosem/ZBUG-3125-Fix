# fix-zbug3125

Workaround script for **Zimbra Bug 3125** — an issue affecting SNI (Server Name Indication) setups.

---

## Background: Zimbra Bug 3125

As documented in Zimbra’s "Multiple SSL Certificates, Server Name Indication (SNI) for HTTPS" wiki, Bug 3125 impacts environments where some domains use Virtual Hosts while others don’t, under SNI. The symptom: non‑SNI clients (or load balancer FQDNs) receive the first server block certificate, causing certificate mismatch and errors for clients like Apple’s Mail. ([wiki.zimbra.com](https://wiki.zimbra.com/wiki/Multiple_SSL_Certificates%2C_Server_Name_Indication_%28SNI%29_for_HTTPS?utm_source=chatgpt.com))

**Immediate cause:** NGINX (used by Zimbra proxy) places the non‑SNI domain block at the top of  
`nginx.conf.mail.imaps` / `nginx.conf.web.https`, and uses that block for all non‑SNI requests, irrespective of which domain they target.

**Workaround:** Move the non‑SNI block to the top **manually**, then reload `zmproxyctl`, so that non‑SNI clients receive the intended (PublicServiceHostname) certificate.

---

## Script `fix-zbug3125.sh`

- Backs up the original config (`.bak`)
- Extracts the server block for a specified domain
- Removes it and prepends it to the top
- Fixes ownership and reloads the Zimbra proxy

**Important:** Run as `root`. Set `MX_DOMAIN="your.mail.domain"` before running.

---

## What's inside this repo

```
fix-zbug3125.sh          # The fix script
README.md                # This file
LICENSE                  # GPL v3, see below
```

---

## Usage

```bash
chmod +x fix-zbug3125.sh
sudo ./fix-zbug3125.sh
```

---

## Updates and Contributions

This project is released under **GNU GPL v3**:

- Completely free to use, modify, and distribute.
- If you share improvements or modifications, they must remain licensed under GPL v3.
- I ask that you kindly share your contributions with me—it's in the spirit of open collaboration.

---

## Credits

No accolades needed—use freely. If you improve it, feel free to contribute back. 😉

Happy bug-fixing!
