podman run --rm -it \
  --network=none \
  --read-only \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  --userns=keep-id \
  extract-rar sh
