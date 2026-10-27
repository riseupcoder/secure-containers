foot -e podman run --rm -it \
  --read-only \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  --cpus 2 \
  --memory 500M \
  -v $HOME/.containers/.git:/home/user/:rw,Z \
  --userns=keep-id \
  github sh 
