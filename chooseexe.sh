#!/usr/bin/env bash
###
### chooseexe.sh — Dispatch action on the selected file
###
### Called by rofi-file-selector.sh after the user selects a file.
### Routes to different actions based on the rofi return code.
###
### Usage:
###   chooseexe.sh <file> <rofi_retv>
###
### Arguments:
###   <file>        Full path of the selected file
###   <rofi_retv>   Rofi return code (0=open, 10=Ctrl+d, 11=Ctrl+c)
###
### Actions:
###   retv=0    Open file with mimeapps (application chooser)
###   retv=10   Open parent directory with mimeapps
###   retv=11   Copy file path to clipboard (via xsel)
###   <2 args   Do nothing
###
### Environment:
###   _ROFI    Override rofi binary (for testing)
###   _XSEL    Override xsel binary (for testing)
###
set -e
set -o pipefail

SCRIPTPATH=$(realpath "$(dirname "$0")")

: "${_ROFI:=rofi}"
: "${_XSEL:=xsel}"

echo "$@"

if [[ "$#" -ge 2 ]]
then
   ROFI_RETV="$2"
   if [[ $ROFI_RETV -eq 10 ]] # Ctrl+d: open parent directory
   then
      "$_ROFI" -show mimeopen -kb-custom-1 "Ctrl+plus" -modi "mimeopen:$SCRIPTPATH/mimeapps.sh \"$(dirname "$1")\" "
   elif [[ $ROFI_RETV -eq 11 ]] # Ctrl+c: copy filename to clipboard
   then
      echo "$1" | "$_XSEL" -i -b; "$_XSEL" -b | "$_XSEL" -p -i; "$_XSEL" -k
   else # Default: open file with mimeapps
      "$_ROFI" -show mimeopen -kb-custom-1 "Ctrl+plus" -modi "mimeopen:$SCRIPTPATH/mimeapps.sh \"$1\" "
   fi
fi
