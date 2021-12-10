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


SYSFS_CAPACITY="${BWD}/capacity"
SYSFS_VOLTAGE="${BWD}/voltage_avg"
SYSFS_STATUS="${BWD}/status"
SYSFS_CURRENT="${BWD}/current_avg"
SYSFS_CURRENT_NOW="${BWD}/current_now"
SYSFS_TEMP="${BWD}/temp"

# DISPENSÁVEIS
# charge_now deveria mostrar a carga restante em micro-Ah segundo a
# documentação do Linux; mas no Galaxy A20, charge_counter é este
# arquivo
SYSFS_CHARGE_NOW="${BWD}/charge_counter"
SYSFS_CHARGE_FULL="${BWD}/charge_full"

# Controlador de carga do Galaxy A20 {
SYSFS_SWITCH="${BWD}/hmt_ta_charge"
if [ ! -r "$SYSFS_SWITCH" ]; then
  printerr "Erro: o dispositivo não suporta controle de carga!"
  error $E_NOSWITCH
fi

B_SWITCH_DEFAULT=$(cat "$SYSFS_SWITCH")
# } A20


DELAY_SWITCH=15

_NOT_CHARGING_MIN_MA=-10
_NOT_CHARGING_MAX_MA=10

# Conversões de valores para o peso esperado
_VOLTAGE_ADJ="/ 1000"
_CHARGE_ADJ="/ 1000"
_CURRENT_ADJ="/ 1"
_TEMP_ADJ="/ 10"

battery_switch_set () {
  switch_status=$(cat "$SYSFS_SWITCH")

  local mode

  case $1 in
    get)
      return $switch_status
      ;;
    enable)
      mode=$ENABLED
      echo "ATIVAR carregamento"
      ;;
    disable)
      mode=$DISABLED
      echo "DESATIVAR carregamento"
      ;;
    default)
      mode=$B_SWITCH_DEFAULT
      echo "RECUPERAR estado de carga"
      ;;
    *)
      printerr "Opção '$1' desconhecida!"
      error $E_WROPTION
      ;;
  esac

  if [ $switch_status -ne $mode ]; then
    echo $mode > "$SYSFS_SWITCH"
    echo "Aguarde..."
    sleep $DELAY_SWITCH

    result=$(cat "$SYSFS_SWITCH")
    if [ $result -ne $mode ]; then
      echo $B_SWITCH_DEFAULT > "$SYSFS_SWITCH"
      printerr "Impossível checar estado do controlador!"
      error $E_FASWITCH
    fi

    if [ $mode -eq $DISABLED ]; then
      battery_status
      if [ "$status" = "Charging" ]; then
        echo $B_SWITCH_DEFAULT > "$SYSFS_SWITCH"
        printerr "Controlador de carga INVÁLIDO!"
        error $E_WRSWITCH
      fi
    fi
  fi

  return $mode
}


battery_percent () {
  percent=$(cat "$SYSFS_CAPACITY")
}


battery_status () {
  status=$(cat "$SYSFS_STATUS")

  # corrige o status para "Not charging" quando a corrente varia
  # abaixo de |10| mA
  battery_current_now
  if [ "$status" = "Charging" ] &&\
     [ $current_now -le $_NOT_CHARGING_MAX_MA ] &&\
     [ $current_now -ge $_NOT_CHARGING_MIN_MA ]; then
    status="Not charging"
  fi
}


battery_current_now () {
  current_now=$(cat "$SYSFS_CURRENT_NOW")
  current_now=$(expr $current_now $_CURRENT_ADJ)
}

battery_current () {
  current=$(cat "$SYSFS_CURRENT")
  current=$(expr $current $_CURRENT_ADJ)
}


battery_temp () {
  temp=$(cat "$SYSFS_TEMP")
  temp=$(expr $temp $_TEMP_ADJ)
}


battery_voltage () {
  voltage=$(cat "$SYSFS_VOLTAGE")
  voltage=$(expr $voltage $_VOLTAGE_ADJ)
}

# Atualiza todas as variáveis
battery_status_all () {
  battery_switch_set get
  battery_percent
  battery_status
  battery_current
  battery_temp
  battery_voltage
}


battery_charge_now () {
  charge_now=$(cat "$SYSFS_CHARGE_NOW")
  charge_now=$(expr $charge_now $_CHARGE_ADJ)
}

battery_charge_full () {
  charge_full=$(cat "$SYSFS_CHARGE_FULL")
  charge_full=$(expr $charge_full $_CHARGE_ADJ)
}


# depende de chamadas às funções anteriores
battery_log () {
  local statustxt="$percent % ($status)"
  [ -n "$1" ] && current=$current_now
  statustxt="$statustxt $current mA $voltage mV $temp °C"

  echo "${1}DATA:" $(date +"%d/%m/%Y %Hh%M")
  echo "${1}$statustxt"

  hstatus="ATIVADO"
  if [ $switch_status -ne $ENABLED ]; then
    hstatus="DESATIVADO"
  fi
  echo "${1}Interruptor de carga: $hstatus"

  [ -z "$1" ] && echo
}
