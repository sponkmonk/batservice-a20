#!/bin/sh

#    BatService v2.1 - battery conservation mode for Galaxy A20
#
#    Copyright (C) 2021 Cledson Ferreira
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.


if [ -z "$NO_PERMS" ]; then
  if [ -f "${0%/*}/lib/magisk-env.rc" ]; then
    MODDIR="${0%/*}"
    . "$MODDIR/lib/magisk-env.rc"
    NO_PERMS=1

  # Termux
  else
    . "$PREFIX/lib/batservice/env.rc"
  fi
fi

. "$LIB/consts.sh"
. "$LIB/perms.sh"
. "$LIB/log.sh"
. "$LIB/error.sh"
. "$LIB/config.sh"
. "$LIB/battery.sh"
. "$LIB/events.sh"


echo "$NAME - conservação de bateria para o Galaxy A20"
echo "Versão $VERSION"
echo

echo "   -*- STATUS DA BATERIA -*-  "
echo "=============================="

[ -r "$EXIT_FILE" ] && rm "$EXIT_FILE"

while [ ! -r "$EXIT_FILE" ]; do

  config_refresh

  events_iter_main
done

echo "=============================="

battery_switch_set default
rm "$EXIT_FILE"

echo "Terminado"
echo "by cleds.upper"
