CACHE_FILE="$CACHE/out.log"

_logging=0
log_start () {
  mkdir -p "$CACHE"
  exec>> "$CACHE_FILE"
  _logging=1
}

log_cleanup () {
  [ $_logging -eq 0 ] && return 0

  local size
  size=$(stat -c '%s' "$CACHE_FILE")
  if [ -n "$size" ] && [ $size -ge 30000 ]; then
    sed -i 1,1700d "$CACHE_FILE"
    exec>> "$CACHE_FILE"
  fi
}

[ -n "$MODDIR" ] && log_start
