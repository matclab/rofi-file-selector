#!/usr/bin/env bash 
set -e
set -o pipefail

# Check version of bash for variable indirection 
case $BASH_VERSION in ''|[123].*|4.[012]) rofi -e "ERROR: Bash 4.3+ needed" ; exit 1;; esac

SCRIPTPATH=$(realpath "$(dirname "$0")")

MENU=(home)
d_home=("$HOME")
o_home=( )
FD_OPTIONS=( )

if [[ -f "$SCRIPTPATH/config.sh" ]]
then
   source "$SCRIPTPATH/config.sh"
fi

if [[ ${#MENU[@]} -gt 1 ]]
then
   res=$(printf "%s\n" "${MENU[@]}" | rofi -dmenu)
fi

# declare dirs as being an indirection upon d_$res
declare -n dirs="d_$res"
declare -n files="f_$res"
declare -n options="o_$res"

{ 
   if [[ -n "${files[*]}" ]]
   then
      printf -- '%s\n' "${files[@]}"
   fi
   "$SCRIPTPATH/fd_cache.sh" "${FD_OPTIONS[@]}" "${options[@]}" '.' "${dirs[@]}" 
}\
   | { rofi -theme-str "#window { width: 900;}"  \
    -dmenu -sort -sorting-method fzf -i -p "Choose to open" \
    -mesg "<i>use Ctrl˖d to open parent directory</i>" \
    -kb-remove-char-forward "Delete" \
    -kb-custom-1 "Ctrl+d" \
    -keep-right; echo " $?" ; } | xargs  -d $'\n' "$SCRIPTPATH/chooseexe.sh" 


