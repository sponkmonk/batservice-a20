#!/data/data/com.termux/files/usr/bin/sh

#    BatService v1.0 - battery conservation mode for Galaxy A20
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
VERSION="1.0.211010"

if [ "$SERVICE_LIB" = "" ]; then
  SERVICE_LIB="$PREFIX/lib/batservice"
fi

# Se este arquivo existir, o programa encerra
if [ "$EXIT_FILE" = "" ]; then
  EXIT_FILE="/sdcard/batservice.exit"
fi
# Se o programa encerrar de forma inesperada, este arquivo pode conter um dos códigos de erros das variáveis E_*.

if [ "$BWD" = "" ]; then
  BWD="/sys/class/power_supply/battery"
fi

error () {
  if [ $1 -ne 0 ]; then
    echo $1 > "$EXIT_FILE"
  fi
  exit $1
}

printerr () {
  echo "$@" >&2
}

# Obrigações da GPLv3

if ( [ "$1" = "-v" ] || [ "$1" = "--version" ] ); then
  echo "$Name versão $VERSION - modo de conversão de bateria para o Galaxy A20."
  echo "\n"\
    "Copyright (C) 2021 Cledson Ferreira\n"\
    "Este programa vem com ABSOLUTAMENTE NENHUMA GARANTIA.\n"\
    "Este é um software livre, e você pode redistribuí-lo\n"\
    "sob certas condições; execute '$0 --license' para detalhes.\n"

  error 0

elif [ "$1" = "--license" ]; then
  cat "$PREFIX/share/batservice/COPYING" 2> /dev/null
  if [ $? -ne 0 ]; then
    echo "Instalação corrompida!"
    echo "Acesse <https://www.gnu.org/licenses/gpl-3.0.txt> para ler a licença."
  fi
  error 0
fi

E_NOROOT=1
E_UNKERROR=2
E_NOSWITCH=3

if ( [ "$NO_SERVICE" = "" ] && [ -r "$SERVICE_LIB/startup-helper.sh" ] ); then

  . "$SERVICE_LIB/startup-helper.sh"
  unset SERVICE_LIB

  if [ $already -eq 0 ]; then
    error $E_UNKERROR
  fi

  unset already

fi


echo "$Name - conservação de bateria para o Galaxy A20"
echo
echo "AVISO: use este programa por sua conta e risco! não me responsabilize se o seu aparelho entrar no modo de avião e sair voando até ir de encontro com a parede de livre e espontânea vontade."
echo
echo "Iniciando em 5, 4, 3..."
echo
sleep 5

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

E_WROPTION=10
E_FASWITCH=11
E_WRSWITCH=12

E_NILPARAM=20
E_INVPARAM=21
E_OUTPARAM=22

RATIONALE_MAMIN=-5
RATIONALE_MAMAX=5

charge_switch () {
  switch_status=$(cat "$Bswitch")

  if [ "$1" = "get" ]; then
    return $switch_status
  elif [ "$1" = "enable" ]; then
    mode=$ENABLED
  elif [ "$1" = "disable" ]; then
    mode=$DISABLED
  else
    exit $E_WROPTION
  fi

  if [ $switch_status -ne $mode ]; then
    echo $mode > "$Bswitch"
    echo "Aguarde..."
    sleep $DELAY_SWITCH

    result=$(cat "$Bswitch")
    if [ $result -ne $mode ]; then
      echo $switch_status > "$Bswitch"
      error $E_FASWITCH
    fi

    if [ $mode -eq $DISABLED ]; then
      current=$(cat "$Bcurrent")
      if ! ( [ $current -ge $RATIONALE_MAMIN ] && [ $current -le $RATIONALE_MAMAX ] ); then
        echo $switch_status > "$Bswitch"
        error $E_WRSWITCH
      fi
    fi
  fi

  return $mode
}


log_battery () {
  echo " -*- STATUS DA BATERIA -*- "
  echo "$percent %"
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


valid_numbers () {
  if ( [ "$1" = "" ] || [ "$2" = "" ] ); then
    echo "Você está brincando, né? :|"
    return $E_NILPARAM
  fi

  pi=0
  for p in "$@"; do
    if [ $pi -eq 2 ]; then
      break
    fi
    pi=$(expr $pi + 1)

    case $p in
      *[!0-9]*)
        printerr "Erro: parâmetro $pi inválido: $p"
        return $E_INVPARAM
        ;;
      *)
        ;;
    esac
  done

  return 0
}


MIN_PERCENT=45
MAX_PERCENT=50

if [ "$2" != "" ]; then
  valid_numbers "$1" "$2"
  valid_res=$?
  if [ $valid_res -eq $E_NILPARAM ]; then
    echo "Parâmetros nulos ignorados"
    valid_res=0

  elif [ $valid_res -eq $E_INVPARAM ]; then
    printerr "Os parâmetros devem ser passados conforme o exemplo:"
    printerr "$0 $MIN_PERCENT $MAX_PERCENT"
    error $E_INVPARAM

  elif ( [ $1 -ge 15 ] && [ $1 -lt $2 ]\
        && [ $2 -le 100 ] ); then
    MIN_PERCENT=$1
    MAX_PERCENT=$2

  else
    printerr "Erro: percentuais fora dos limites!"
    printerr "Mínimo >= 15 (mínimo = $1)"
    printerr "Máximo <= 100 (máximo = $2)"
    error $E_OUTPARAM
  fi

  unset valid_res
fi


DELAY_REFRESH=60



if [ -r "$EXIT_FILE" ]; then
  rm "$EXIT_FILE"
fi

while [ ! -r "$EXIT_FILE" ]; do

  percent=$(cat "$Bpercent")
  current=$(cat "$Bcurrent")
  voltage=$(expr $(cat "$Bvoltage") / 1000)
  status=$(cat "$Bstatus")
  temp=$(expr $(cat "$Btemp") / 10)

  charge_switch get
  switch_status=$?

  log_battery

  if [ $switch_status -eq $DISABLED ]; then

    if [ $percent -lt $MIN_PERCENT ]; then
      echo "ATIVAR carregamento"
      echo
      charge_switch enable
      continue
    fi

  else

    if ( [ $percent -ge $MAX_PERCENT ] && [ "$status" = "Charging" ] ); then
      echo "DESATIVAR carregamento"
      echo
      charge_switch disable
      continue
    fi

  fi

  sleep $DELAY_REFRESH

done

echo $DEFAULT > "$Bswitch"
rm "$EXIT_FILE"


echo "Terminado"
echo "by cleds.upper"
