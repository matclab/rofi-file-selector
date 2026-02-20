#!/usr/bin/env bash
###
### fd_cache.sh — Cached file listing using fd
###
### Runs fd with the given arguments and caches the results. On subsequent
### calls with the same arguments, recently modified files are prepended to
### the cached list for immediate display. A full cache rebuild runs in the
### background when the cache is older than one day.
###
### Usage:
###   fd_cache.sh [fd_options...] <pattern> <directories...>
###
### All arguments are forwarded to fd. The cache key is the MD5 hash of
### the full argument string.
###
### Output:
###   File paths, one per line, most recently modified first.
###
### Environment:
###   CACHEDIR   Override cache directory (default: $XDG_CACHE_HOME/fd_cache)
###
set -e

: "${XDG_CACHE_HOME:="$HOME/.cache"}"
: "${CACHEDIR:="$XDG_CACHE_HOME/fd_cache"}"

[[ -d "$CACHEDIR" ]] || mkdir -p "$CACHEDIR"

CACHE="$CACHEDIR"/$(echo "$*" | md5sum | cut -f1 -d' ')
CACHE_DATE="$CACHE".date

old_date=$(cat "$CACHE_DATE" 2>/dev/null || true)
oldepoch_plus_day=$(date -d"$old_date + 1day" +%s 2>/dev/null || echo 0)
epoch=$(date  +%s)
# Use UTC, as fd --follow --hidden --no-ignore . /tmp/essai use UTC 
date -u +'%Y-%m-%d %H:%M:%S' > "$CACHE_DATE"

if [[ -e $CACHE ]]
then
   # Cache exist, append newer file to cache
   mv "$CACHE" "$CACHE".old

   # Output old cache in background for immediate display while new results are computed
   ( cat "$CACHE".old  | choose 1: ) &
   { fd -0 --change-newer-than "$old_date" "$@" | xargs -0 stat -c "%Y %n" 2>/dev/null | sort -r -n ; wait ; } | tee "$CACHE" | choose 1:
   if  [[ $epoch -gt $oldepoch_plus_day ]]
   then
      # rebuild full cache
      ( fd -0 "$@" | xargs -0 stat -c "%Y %n" 2>/dev/null | sort -r -n > "$CACHE" ) &
   else
      # append
      ( cat  "$CACHE".old  >> "$CACHE" ) &
   fi

   
else
   # Create cache
   fd -0 "$@" | xargs -0 stat -c "%Y %n" 2>/dev/null | sort -r -n |tee "$CACHE" | choose 1:
fi


