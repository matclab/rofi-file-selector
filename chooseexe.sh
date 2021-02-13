#!/bin/bash 

# Expect file + ROFI_RETV code
echo "$@"

if [[ "$#" -ge 2 ]]
then
   ROFI_RETV="$2"
   if [[ $ROFI_RETV -eq 10 ]]
   then
      rofi -show mimeopen -kb-custom-1 "Ctrl+plus" -modi "mimeopen:$HOME/.config/rofi/scripts/mimeapps.sh \"$(dirname "$1")\" " 
   else
      rofi -show mimeopen -kb-custom-1 "Ctrl+plus" -modi "mimeopen:$HOME/.config/rofi/scripts/mimeapps.sh \"$1\" " 
   fi
fi
