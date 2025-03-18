#!/bin/sh
echo -ne '\033c\033]0;ServerSandbox\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/ServerSandbox.x86_64" "$@"
