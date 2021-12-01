#!/system/bin/sh

#    BatService v2.0 - battery conservation mode for Galaxy A20
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


NAME="BATSERVICE"
Name="BatService"
name="batservice"
VERSION="2.0.211130"

if [ -f $PREFIX/bin/termux-notification ]; then
  TERMUX_API=1
fi

if [ "$LIB" = "" ]; then
  LIB="$PREFIX/lib/$name"
fi

. "$LIB/perms.sh"
if [ "$DATA" = "" ]; then
  DATA="$PREFIX/etc/$name"
  backup_owner "$PREFIX"
  mkdir -p "$DATA"
  restore_owner "$PREFIX/etc"
  restore_owner "$DATA"
fi

. "$LIB/error.sh"
. "$LIB/config.sh"
. "$LIB/battery.sh"


echo "$Name - conservação de bateria para o Galaxy A20"
echo "Versão $VERSION"
echo

if [ -r "$EXIT_FILE" ]; then
  rm "$EXIT_FILE"
fi

prev_percent=0
battery_percent
not_charging_set=$DISABLED

echo " -*- STATUS DA BATERIA -*- "
echo " $(date) "
echo "  ============================="

while [ ! -r "$EXIT_FILE" ]; do

  config_refresh

  if [ $prev_percent -ne $percent ]; then
    battery_log
  elif [ "$TERMUX_API" != "" ]; then
    battery_log '# '
  fi

  if ( [ "$status" = "Not charging" ] || [ "$status" = "Discharging" ] ); then

    if ( [ $not_charging_set -eq $ENABLED ] && [ $percent -lt $MIN_PERCENT ] ); then
      echo "ATIVAR carregamento"
      battery_switch_set enable
      not_charging_set=$DISABLED
      echo
      prev_percent=0
      continue
    fi

    sleep $DELAY_REFRESH

  elif [ "$status" = "Charging" ]; then

    if ( [ $not_charging_set -eq $ENABLED ] || [ $percent -ge $MAX_PERCENT ] ); then
      echo "DESATIVAR carregamento"
      battery_switch_set disable
      not_charging_set=$ENABLED
      echo
      prev_percent=0
      continue
    fi

    sleep 6

  fi

  prev_percent=$percent

done

battery_switch_set default
rm "$EXIT_FILE"

echo "Terminado"
echo "by cleds.upper"
