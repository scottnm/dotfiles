# From: https://nmattia.com/posts/2026-10-19-setting-up-ssh-keys-touch-id/

echo @"
# run once to create identity
sc_auth create-ctk-identity -l ssh-key -k p-256-ne -t bio

# run after a reboot
ssh-add -K -S /usr/lib/ssh-keychain.dylib

# run when you need the public key
ssh-add -L
"@
