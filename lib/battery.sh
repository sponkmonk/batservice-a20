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


if [ "$BWD" = "" ]; then
  BWD="/sys/class/power_supply/battery"
fi

Bpercent="${BWD}/capacity"
Bvoltage="${BWD}/voltage_now"
Bstatus="${BWD}/status"
Bcurrent="${BWD}/current_now"
Btemp="${BWD}/temp"

# Controlador de carga do Galaxy A20 {
Bswitch="${BWD}/hmt_ta_charge"
if [ ! -r "$Bswitch" ]; then
  printerr "Erro: o dispositivo não suporta controle de carga!"
  error $E_NOSWITCH
fi

DEFAULT=$(cat "$Bswitch")
ENABLED=1
DISABLED=0

# } A20


DELAY_SWITCH=15

RATIONALE_MAMIN=-5
RATIONALE_MAMAX=5

battery_switch_set () {
  switch_status=$(cat "$Bswitch")

  case $1 in
    get)
      return $switch_status
      ;;
    enable)
      mode=$ENABLED
      ;;
    disable)
      mode=$DISABLED
      ;;
    default)
      mode=$DEFAULT
      ;;
    *)
      exit $E_WROPTION
      ;;
  esac

  if [ $switch_status -ne $mode ]; then
    echo $mode > "$Bswitch"
    echo "Aguarde..."
    sleep $DELAY_SWITCH

    result=$(cat "$Bswitch")
    if [ $result -ne $mode ]; then
      echo $DEFAULT > "$Bswitch"
      error $E_FASWITCH
    fi

    if [ $mode -eq $DISABLED ]; then
      battery_status
      if [ "$status" = "Charging" ]; then
        echo $DEFAULT > "$Bswitch"
        error $E_WRSWITCH
      fi
    fi
  fi

  return $mode
}


battery_percent () {
  percent=$(cat "$Bpercent")
}


battery_status () {
  status=$(cat "$Bstatus")


  # corrige o status para "Not charging" quando a corrente varia abaixo de |10| mA
  battery_current
  if ( [ "$status" = "Charging" ] && [ $current -le $RATIONALE_MAMAX ] && [ $current -ge $RATIONALE_MAMIN ] ); then
    status="Not charging"
  fi
}


battery_current () {
  current=$(cat "$Bcurrent")
  if [ $current -ge  10000 ]; then
    current=$(expr $current / 1000)
  fi
}


battery_temp () {
  temp=$(cat "Btemp")
  temp=$(expr $temp / 10)
}


battery_voltage () {
  voltage=$(cat "$Bvoltage")
  voltage=$(expr $voltage / 1000)
}


# depende de chamadas às funções anteriores
battery_log () {
  echo " -*- STATUS DA BATERIA -*- "
  echo "$percent % ($status)"
  echo "$current mA"
  echo "$voltage mV"
  echo "$temp °C"

  hstatus="ATIVADO"
  if [ $switch_status -ne $ENABLED ]; then
    hstatus="DESATIVADO"
  fi
  echo "Interruptor de carga: $hstatus"
  echo
}
