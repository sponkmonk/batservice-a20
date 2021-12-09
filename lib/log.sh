#    log.sh - redirect output to a file.
#
#    This file is part of BatService.
#
#    BatService is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    BatService is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with BatService.  If not, see <https://www.gnu.org/licenses/>.

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
