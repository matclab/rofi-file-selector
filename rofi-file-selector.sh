#!/bin/bash
case $BASH_VERSION in ''|[123].*|4.[012]) echo "ERROR: Bash 4.3+ needed" >&2; exit 1;; esac

MENU=(home)
d_home=("$HOME")

if [[ -f config.sh ]]
then
   source config.sh
fi

if [[ ${#MENU[@]} -gt 1 ]]
then
   res=$(printf "%s\n" "${MENU[@]}" | rofi -dmenu)
fi

# decalre dirs as being an indirection upon d_$res
declare -n dirs="d_$res"
declare -n files="f_$res"

{ 
   printf -- '%s\n' "${files[@]}"
   "$HOME/bin/fd_cache.sh" --follow --hidden --no-ignore '.' "${dirs[@]}" 
}\
   | { rofi -threads 0 -theme-str "#window { width: 900;}"  \
    -dmenu -sort -sorting-method fzf -i -p "Choose to open" \
    -mesg "<i>use Ctrl˖d to open parent directory</i>" \
    -kb-remove-char-forward: "Delete" \
    -kb-custom-1 "Ctrl+d" \
    -keep-right; echo " $?" ; } | xargs  -d $'\n' "$HOME/.config/rofi/scripts/chooseexe.sh" 


