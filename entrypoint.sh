#!/bin/bash

USER_ID=${LOCAL_USER_ID:-9001}

useradd --shell /bin/bash -u $USER_ID -o -c "" -m user > /dev/null 2>&1
export HOME=/home/user

exec /sbin/su-exec user "$@"