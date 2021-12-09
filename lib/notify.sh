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

NO_SERVICE=1
[ -z "$NO_PERMS" ] && . "$PREFIX/lib/batservice/env.rc"

if [ -n "$DATA_FIX" ]; then
  DATA="$DATA_FIX"
  LIB="$LIB_FIX"
fi

NO_PERMS=1
. "$LIB/perms.sh"
. "$LIB/log.sh"
. "$LIB/error.sh"
. "$LIB/config.sh"


send_message () {
  if [ -z "$TERMUX_API" ]; then return 0; fi
  termux-toast "BatService: $1"
}

send_status () {
  local val=$(config_bool_get charging-never-stop)
  if [ "$val" = "true" ]; then
    local btn="ᐅ"
  else
    local btn="□"
  fi

  if [ -z "$TERMUX_API" ]; then
    [ -n "$NO_LOGS" ] && echo "STATUS: $1"
  else
    termux-notification -i batservice --ongoing --alert-once\
      --icon "battery_std" -t "Status do serviço" -c "$1"\
      --button1 "$btn" --button1-action "DATA_FIX=\"$DATA\" LIB_FIX=\"$LIB\" sh $LIB/notify.sh force-charge"\
      --button2 "X" --button2-action "DATA_FIX=\"$DATA\" LIB_FIX=\"$LIB\" sh $LIB/notify.sh quit"
  fi
}

notify_status () {
  if echo "$status" | grep -E '(Charging|Not charging)' >/dev/null; then
    local p="(🔌 $current)"
  else
    local p=""
  fi
  local statustxt="🔋 $percent $p ⚡ $voltage 🌡 $temp"
  send_status "$statustxt"
}

notify_quit () {
  if [ -n "$TERMUX_API" ]; then
    termux-notification-remove batservice
  fi
  exit 0
}

param_filter () {
  local p="$(echo $1 | grep -Eo '(-)?[[:digit:]]+ %')"
  [ -z "$p" ] && return 1
  percent="$p"
  status="$(echo $1 | grep -Eo '\([[:alpha:] ]+\)')"
  current="$(echo $1 | grep -Eo '(-)?[[:digit:]]+ mA')"
  voltage="$(echo $1 | grep -Eo '(-)?[[:digit:]]+ mV')"
  temp="$(echo $1 | grep -Eo '(-)?[[:digit:]]+ .C')"
  return 0
}


if [ -n "$1" ]; then

  if [ "$1" = "--no-logs" ]; then
    NO_LOGS=1
  else case "$1" in
    quit)
      echo 0 > "$EXIT_FILE"
      send_message "O serviço será encerrado"
      ;;

    force-charge)

      val=$(config_bool_get charging-never-stop)
      case "$val" in
        true)
          config_bool_set charging-never-stop false
          val="false"
          ;;
        false|"")
          config_bool_set charging-never-stop true
          val="true"
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


[ -z "$NO_LOGS" ] && log_start

while [ "$stdin" != "==============================" ]; do
  read stdin || exit 0
  echo $stdin
done

while [ 0 ]; do
  read stdin || notify_quit
  [ "$stdin" = "==============================" ] && break

  log_cleanup

  do_print=1
  echo "$stdin" | grep -E '^#' >/dev/null
  if [ $? -eq 0 ]; then
    msg=$(echo "$stdin" | sed -E 's|#upd (.+)|\1|g' | grep -v '#')
    if [ -n "$msg" ]; then
      send_message "$msg"
      echo "ALERTA: $msg"
    fi
    unset msg
    do_print=0
  fi

  echo "$stdin" | grep "ERR: " >/dev/null
  if [ $? -ne 0 ]; then
    param_filter "$stdin"
    [ $? -eq 0 ] && notify_status
  else send_message "$stdin"; fi

  if [ $do_print -eq 1 ]; then echo "$stdin"; fi
done

while [ 0 ]; do
  echo "$stdin"
  read stdin || notify_quit
done
