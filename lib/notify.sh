#!/bin/sh

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


send_message () {
  termux-toast "BatService: $1"
}

if [ -z "$NO_PERMS" ]; then
  . "$PREFIX/lib/batservice/env.rc"
fi

get_charging_never_stop () {
  local val=$(cat "$DATA/config.txt" 2>/dev/null | grep 'charging-never-stop' | grep -Eo '(false|true)')
  if [ "$val" = "" ]; then
    return 2
  elif [ "$val" = "true" ]; then
    return 1
  else
    return 0
  fi
}

send_status () {
  get_charging_never_stop
  if [ $? -eq 1 ]; then
    local btn="▶️"
  else
    local btn="⏹"
  fi
  termux-notification -i batservice --ongoing --alert-once\
    --icon "battery_std" -t "Status do serviço" -c "$1"\
    --button1 "$btn" --button1-action "DATA_FIX=\"$DATA\" sh $LIB/notify.sh force-charge"\
    --button2 "❎" --button2-action "DATA_FIX=\"$DATA\" sh $LIB/notify.sh quit"
}

notify_status () {
  if echo "$status" | grep -E '(Charging|Not charging)' >/dev/null; then
    p="(🔌 $current)"
  else
    p=""
  fi
  statustxt="🔋 $percent $p ⚡ $voltage 🌡 $temp"
  send_status "$statustxt"
}

notify_quit () {
  termux-notification-remove batservice
  exit 0
}


if [ -z "$TERMUX_API" ]; then

  unset send_message
  unset send_status
  unset notify_status
  unset notify_quit

  send_message () { :; }
  send_status () { :; }
  notify_status () { :; }
  notify_quit() { exit 0; }

fi

if [ -n "$1" ]; then
  if [ -n "$DATA_FIX" ]; then DATA="$DATA_FIX"; fi

  if [ "$1" = "--no-logs" ]; then
    NO_LOGS=1
  else case "$1" in
    quit)
      echo 0 > "$DATA/exit.err"
      send_message "O serviço será encerrado"
      ;;

    force-charge)

      get_charging_never_stop
      ival=$?
      val="true"
      case "$ival" in
        1)
          sed -E -i 's|(charging-never-stop) .+|\1 false|g' "$DATA/config.txt"
          val="false"
          ;;
        0)
          sed -E -i 's|(charging-never-stop) .+|\1 true|g' "$DATA/config.txt"
          ;;
        *)
          echo "charging-never-stop true" >> "$DATA/config.txt"
          ;;
      esac

      if [ "$val" = "true" ]; then
        send_message "A bateria carregará completamente"
      else
        send_message "A bateria NÃO carregará completamente"
      fi
      ;;

    *)
      send_message "Comando inválido!"
      echo "ERR: comando inválido!"
      exit 1
      ;;
  esac; exit 0; fi # preguiça de identar

fi


if [ -z "$NO_LOGS" ]; then
  log_cleanup () {
    if [ -r "$CACHE/out.log" ]; then
      if [ $(stat -c "%s" "$CACHE/out.log") -gt 30000 ]; then
        sed -i 1,1700d "$CACHE/out.log"
        exec>> "$CACHE/out.log"
      fi
    fi
  }

  mkdir -p "$CACHE"
  exec>> "$CACHE/out.log"
else
  log_cleanup () { :; }
fi


param_filter () {
  local p=$(echo "$1" | grep -Eo '[[:digit:]]+ %')
  if [ -z "$p" ]; then return 1; fi
  percent=$p
  status=$(echo "$1" | grep -Eo '\([[:alpha:] ]+\)')
  current=$(echo "$1" | grep -Eo '[[:digit:]]+ mA')
  voltage=$(echo "$1" | grep -Eo '[[:digit:]]+ mV')
  temp=$(echo "$1" | grep -Eo '[[:digit:]]+ .C')
  return 0
}

while [ 0 ]; do
  read log_line || notify_quit

  echo "$log_line" | grep -E '^#' >/dev/null
  if [ $? -eq 0 ]; then
    msg=$(echo "$log_line" | sed -E 's|#msg (.+)|\1|g' | grep -v '#')
    if [ -n "$msg" ]; then send_message "$msg" && echo "$msg"; fi
    unset msg
    continue
  fi

  echo "$log_line" | grep "ERR: " >/dev/null
  if ( [ $? -ne 0 ] && [ -n "$TERMUX_API" ] ); then
    param_filter "$log_line"
    if [ $? -eq 0 ]; then notify_status; fi
  elif [ -n "$TERMUX_API" ]; then send_message "$log_line"; fi

  echo "$log_line"
done
