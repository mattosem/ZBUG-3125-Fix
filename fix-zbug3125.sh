#!/bin/bash

ZIMBRA_USER="zimbra"
CONF_FILE="/opt/zimbra/conf/nginx/includes/nginx.conf.mail.imaps"
TMP_FILE="/tmp/nginx.conf.mail.imaps.fixed"
TMP_BLOCK="/tmp/mx_block.conf"
MX_DOMAIN="mail.example.com"  # <-- replace with your affected domain

if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

echo "[*] Backing up the original file..."
cp "$CONF_FILE" "${CONF_FILE}.bak"

echo "[*] Extracting and removing the block for $MX_DOMAIN..."

sudo -u "$ZIMBRA_USER" awk -v domain="$MX_DOMAIN" -v tmpblk="$TMP_BLOCK" '
BEGIN {
    inblock = 0;
    found = 0;
    block = "";
}
/^\s*server\s*$/ {
    inblock = 1;
    block = $0 "\n";
    next;
}
inblock && /^\s*{\s*$/ {
    block = block $0 "\n";
    next;
}
inblock {
    block = block $0 "\n";
    if (index($0, domain)) {
        found = 1;
    }
    if ($0 ~ /^\s*}\s*$/) {
        if (found == 1) {
            print block > tmpblk;
        } else {
            print block;
        }
        inblock = 0;
        found = 0;
        block = "";
    }
    next;
}
!inblock {
    print $0;
}
' "$CONF_FILE" > "$TMP_FILE"

if [[ ! -s "$TMP_BLOCK" ]]; then
  echo "Error: block for $MX_DOMAIN not found."
  exit 2
fi

echo "[*] Writing the new file with $MX_DOMAIN block at the top..."
cat "$TMP_BLOCK" "$TMP_FILE" > "$CONF_FILE"
chown "$ZIMBRA_USER:$ZIMBRA_USER" "$CONF_FILE"

echo "[*] Reloading Zimbra proxy..."
sudo -u "$ZIMBRA_USER" /opt/zimbra/bin/zmproxyctl reload

echo "[✓] Done!"
