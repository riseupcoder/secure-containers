podman run --rm -it \
  --read-only \
  --cap-drop=ALL \
  --security-opt no-new-privileges \
  -v $HOME/.containers/.git:/home/user/:rw,Z \
  --userns=keep-id \
  github sh 
