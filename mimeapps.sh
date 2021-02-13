#!/usr/bin/env bash 
set -e
set -o pipefail
#>&2 echo "RETV:$ROFI_RETV"
export ROFI_RETV
if [[ "$#" -lt 2 ]]
then
   "$HOME/.config/rofi/scripts/mimeapps" "$1"
else
   coproc ( "$HOME/.config/rofi/scripts/mimeapps" "$1" "$2" > /dev/null 2>&1 )
fi
