#!/system/bin/sh

echo "BatService - conservação de bateria para o Galaxy A20"
echo
echo "AVISO: use este script por sua conta e risco! não me responsabilize se o seu aparelho entrar no modo de avião e sair voando até ir de encontro com a parede de livre e espontânea vontade."
echo
echo "Iniciando em 15, 14, 13..."
sleep 15

# Se este arquivo existir, o programa encerra
if [ "$EXIT_FILE" = "" ]; then
  EXIT_FILE="/sdcard/bat.exit"
fi
# Se o programa encerrar de forma inesperada, este arquivo pode conter um dos códigos de erros das variáveis E_*.

if [ "$BWD" = "" ]; then
  BWD="/sys/class/power_supply/battery"
fi
Bpercent="${BWD}/capacity"
Bvoltage="${BWD}/voltage_now"
Bstatus="${BWD}/status"
Bcurrent="${BWD}/current_now"

# Controlador de carga do Galaxy A20 {
Bswitch="${BWD}/hmt_ta_charge"

DEFAULT=$(cat "$Bswitch")
ENABLED=1
DISABLED=0

# } A20


DELAY_SWITCH=15

E_WROPTION=10
E_FASWITCH=11
E_WRSWITCH=12

RATIONALE_MAMIN=-5
RATIONALE_MAMAX=5

function charge_switch {
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
    sleep $DELAY_SWITCH

    result=$(cat "$Bswitch")
    if [ $result -ne $mode ]; then
      echo $switch_status > "$Bswitch"
      echo $E_FASWITCH > "$EXIT_FILE"
      exit $E_FASWITCH
    fi

    if [ $mode -eq $DISABLED ]; then
      current=$(cat "$Bcurrent")
      if ! ( [ $current -ge $RATIONALE_MAMIN ] && [ $current -le $RATIONALE_MAMAX ] ); then
        echo $switch_status > "$Bswitch"
        echo $E_WRSWITCH > "$EXIT_FILE"
        exit $E_WRSWITCH
      fi
    fi
  fi

  return $mode
}


function log_battery {
  echo " -*- BATTERY STATUS -*- "
  echo "$percent % ($status)"
  echo "$current mA"
  echo "$voltage mV"

  hstatus="ENABLED"
  if [ $switch_status -ne $ENABLED ]; then
    hstatus="DISABLED"
  fi
  echo "Charge switch: $hstatus"
  echo
}


MIN_PERCENT=45
MAX_PERCENT=50

DELAY_REFRESH=60

while [ ! -r "$EXIT_FILE" ]; do
  percent=$(cat "$Bpercent")
  current=$(cat "$Bcurrent")
  (( voltage=$(cat "$Bvoltage")/1000 ))
  status=$(cat "$Bstatus")

  charge_switch get
  switch_status=$?

  log_battery

  if [ $switch_status -eq $DISABLED ]; then

    if [ $percent -lt $MIN_PERCENT ]; then
      echo "ENABLE charging"
      echo
      charge_switch enable
      continue
    fi

  else

    if ( [ $percent -ge $MAX_PERCENT ] && [ "$status" = "Charging" ] ); then
      echo "DISABLE charging"
      echo
      charge_switch disable
      continue
    fi

  fi

  sleep $DELAY_REFRESH

done

echo $DEFAULT > "$Bswitch"
rm "$EXIT_FILE"

echo "by cleds.upper"
