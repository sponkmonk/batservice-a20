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


# Algumas regras simples para lidar com tarefas:
JOBS_NEXT=0 # Continua a execução das tarefas subsequentes.
JOBS_OK=1   # Ação exige um avanço imediato no loop de eventos.
JOBS_SKIP=2 # As demais tarefas conflitariam com a ação realizada,
            # portanto se faz necessário avançá-las.


MDATA=$(stat -c '%Y' "$0")
restart_on_upd_action () {
  local mdata=$(stat -c '%Y' "$0")
  if [ $? -ne 0 ]; then
    :
  elif [ $mdata -gt $MDATA ]; then
    echo "#msg O serviço foi atualizado! reiniciando..."
    if [ -x "$0" ]; then
      exec "$0"
    else
      exec sh "$0"
    fi
  fi
  return $JOBS_NEXT
}

# Exibe o status da bateria
prev_percent=-1
log_action () {
  if [ $prev_percent -ne $percent ]; then
    battery_log
  # É necessário mostrar o status para atualizar a notificação do
  # Termux. Para sinalizar ao notify.sh que não deve salvar o status,
  # colocamos um hashtag e um espaço
  elif [ -n "$TERMUX_API" ]; then
    battery_log '# '
  fi
  return $JOBS_NEXT
}

# O BatService deve saber e memorizar as suas modificações no sistema,
# isto evita um "samba de conflitos" entre serviços diferentes que
# estão em execução no dispositivo
not_charging_set=$DISABLED

# Verifica se o BatService deve permitir o carregamento completo
never_stop_action () {
  if [ "$NEVER_STOP" = "true" ]; then

    if [ $not_charging_set -eq $ENABLED ]; then
      battery_switch_set enable
      not_charging_set=$DISABLED
      return $JOBS_OK
    fi

    return $JOBS_SKIP
  fi

  return $JOBS_NEXT
}

# Verifica se a carga ultrapassou o limite definido na configuração
capacity_action () {
  if echo "$status" | grep -o 'charging' >/dev/null; then

    if ( [ $not_charging_set -eq $ENABLED ] && [ $percent -lt $MIN_PERCENT ] ); then
      battery_switch_set enable
      not_charging_set=$DISABLED
      return $JOBS_OK
    fi

  elif [ "$status" = "Charging" ]; then

    if ( [ $not_charging_set -eq $ENABLED ] || [ $percent -ge $MAX_PERCENT ] ); then
      battery_switch_set disable
      not_charging_set=$ENABLED
      return $JOBS_OK
    fi

  fi
  return $JOBS_NEXT
}


# Executar todas as tarefas sequencialmente
run_jobs () {
  restart_on_upd_action

  log_action

  never_stop_action
  r=$?
  if [ $r -eq $JOBS_OK ]; then return 1; fi
  if [ $r -eq $JOBS_SKIP ]; then return 0; fi

  capacity_action
  if [ $? -eq $JOBS_OK ]; then return 1; fi

  return 0
}

jobs_main () {
  battery_status_all
  run_jobs
  if [ $? -eq 1 ]; then prev_percent=-1 && return 0; fi

  prev_percent=$percent
  if echo "$status" | grep -o 'charging' >/dev/null; then
    sleep $DELAY_REFRESH
  else
    sleep 6
  fi
  return 0
}
