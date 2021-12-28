#    events.sh - BatService's event loop body
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


# Os eventos são executados nesta ordem:

user_events_pre () { :; }
user_tasks () { :; }

user_on_status_change () { :; }

user_on_charge () { :; }
user_on_discharge () { :; }
user_on_idle () { :; }

user_on_temp_increase () { :; }
user_on_temp_decrease () { :; }

[ -r "$DATA/user-events.sh" ] && . "$DATA/user-events.sh"


# Algumas regras simples para lidar com tarefas:
EVENTS_OK=0    # continua o processo dos demais eventos.
EVENTS_SKIP=1  # pula para a próxima iteração.
EVENTS_NEXT=2  # avança a iteração imediatamente.

_EVENTS_NEXT_LIMIT=3

_events_switch_set=$DISABLED


do_charge_stop () {
  if [ $CHARGE_NEVER_STOP -eq $ENABLED ]; then
    if [ $_events_switch_set -eq $ENABLED ]; then
      battery_switch_set enable
      _events_switch_set=$DISABLED
      return $EVENTS_NEXT
    fi
    return $EVENTS_OK
  fi

  case "$status" in
    *charging)
      return $EVENTS_OK
      ;;
  esac

  if [ $_events_switch_set -eq $ENABLED -o $percent -ge $CHARGE_STOP ]; then
    battery_switch_set disable
    echo '#upd carregamento parou'
    _events_switch_set=$ENABLED
    return $EVENTS_NEXT
  fi

  return $EVENTS_OK
}

on_status_change () {
  local r
  user_on_status_change
  r=$?
  [ $r -ne $EVENTS_OK ] && return $r

  case "$status" in
    'Charging')
      on_charge
      r=$?
      ;;
    'Discharging')
      on_discharge
      r=$?
      ;;
    'Not charging')
      on_idle
      r=$?
      ;;
    *)
      return $EVENTS_OK
      ;;
  esac
  [ $r -ne $EVENTS_OK ] && return $r

  return $EVENTS_SKIP
}


on_charge () {
  user_on_charge
  return $?
}

on_discharge () {
  user_on_discharge
  local r=$?
  [ $r -ne $EVENTS_OK ] && return $r

  if [ $_events_switch_set -eq $ENABLED -a \
      $percent -lt $CHARGE_CONTINUE ]; then
    battery_switch_set enable
    _events_switch_set=$DISABLED
    return $EVENTS_NEXT
  fi

  return $EVENTS_OK
}

on_idle () {
  user_on_idle
  return $?
}


on_temp_increase () {
  user_on_temp_increase
  return $?
}

on_temp_decrease () {
  user_on_temp_decrease
  return $?
}


event_iter () {
  local r=$EVENTS_OK

  do_charge_stop
  r=$?
  [ $r -ne $EVENTS_OK ] && return $r

  user_tasks
  r=$?
  [ $r -ne $EVENTS_OK ] && return $r

  if [ "$prev_status" != "$status" ]; then
    on_status_change
    r=$?
  fi
  [ $r -ne $EVENTS_OK ] && return $r

  if [ "$prev_percent" -lt "$percent" ]; then
    on_charge
    r=$?
  elif [ "$prev_percent" -gt "$percent" ]; then
    on_discharge
    r=$?
  fi
  [ $r -ne $EVENTS_OK ] && return $r

  if [ "$prev_temp" -lt "$temp" ]; then
    on_temp_increase
    r=$?
  elif [ "$prev_temp" -gt "$temp" ]; then
    on_temp_decrease
    r=$?
  fi
  [ $r -ne $EVENTS_OK ] && return $r

  if [ "$status" = "Not charging" ]; then
    on_idle
    r=$?
  fi

  return $?
}


# Exibe o status da bateria
do_log () {
  if [ $prev_percent -ne $percent ]; then
    log_cleanup
    battery_log
  # É necessário mostrar o status para atualizar a notificação do
  # Termux. Para sinalizar ao notify.sh que não deve salvar o status,
  # colocamos um símbolo de hashtag.
  elif [ -n "$TERMUX_API" ]; then
    battery_log '# '
  fi
}

_EVENT_LOOP_STARTED=0
_events_next_count=0
events_iter_main () {
  if [ $_EVENT_LOOP_STARTED -eq 0 ]; then
    _EVENT_LOOP_STARTED=1

    battery_status_all
    prev_status="$status"
    prev_percent=$percent
    prev_temp=$temp

    user_events_pre
    battery_log

  else

    battery_status_all
    user_events_pre
    do_log

  fi

  event_iter
  local r=$?

  prev_status="$status"
  prev_percent=$percent
  prev_temp=$temp

  if [ $r -eq $EVENTS_NEXT ]; then
    _events_next_count=$(expr $_events_next_count + 1)
    if [ $_events_next_count -gt $_EVENTS_NEXT_LIMIT ]; then
      printerr "Funções não podem interromper o loop de eventos mais que $_EVENTS_NEXT_LIMIT vezes em sequência."\
      'O programa foi abortado para evitar problemas.'
      error $E_ENCLIMIT
    fi
    return 0

  fi
  _events_next_count=0

  case "$status" in
    Charging)
      sleep 6
      ;;
    *)
      sleep $SRV_DELAY
      ;;
  esac
}
