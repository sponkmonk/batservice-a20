#!/bin/sh
echo "Isto é um emulador de bateria para teste do BatService"

default_values() {
  mkdir -p tBWD
  echo -104 > tBWD/current_now
  echo -100 > tBWD/current_avg
  echo 3780000 > tBWD/voltage_avg
  echo 290 > tBWD/temp
  echo Discharging > tBWD/status
  echo 40 > tBWD/capacity
  echo 1 > tBWD/hmt_ta_charge
}

# ** OBTER FATOR DE MULTIPLICAÇÃO DA TENSÃO **
#   v = v0+P*f
#   3850 = v0+50*f
#   4200 = v0+100*f
# f = (4200-3850)/(100-50)
# => f = 7
# v0 = 4200-7*100
# => v0 = 3500
# => v = P*7 + 3500

# EXEMPLO DE USO: discharge_to 10
discharge_to () {
  echo "Descarregando para $1 %"

  echo -1000 > tBWD/current_now
  echo -1000 > tBWD/current_avg
  echo Discharging > tBWD/status
  echo 1 > tBWD/hmt_ta_charge

  p=$(cat tBWD/capacity)
  while [ $p -gt $1 ]; do
    p=$(expr $p - 1)
    echo $p > tBWD/capacity
    expr 3500000 + 7000 \* $p > tBWD/voltage_avg
    sleep 6
  done
  echo -1 > tBWD/current_now
  echo 500 > tBWD/current_avg
  echo "Concluído"
}

charge_to () {
  echo "Carregando para $1 %"

  echo 1000 > tBWD/current_now
  echo 1000 > tBWD/current_avg
  echo Charging > tBWD/status

  p=$(cat tBWD/capacity)
  while [ $p -lt $1 ]; do
    if [ $(cat tBWD/hmt_ta_charge) -eq 0 ]; then
      echo 0 > tBWD/current_now
      echo 0 > tBWD/current_avg
      while [ $(cat tBWD/hmt_ta_charge) -ne 1 ]; do sleep 6; done
      echo 1000 > tBWD/current_now
      echo 1000 > tBWD/current_avg
    fi
    p=$(expr $p + 1)
    echo $p > tBWD/capacity
    expr 3500000 + 7000 \* $p > tBWD/voltage_avg
    sleep 6
  done
  echo "Concluído"
}

echo "MENU"
sel="d"
while [ "$sel" != "e" ]; do
  echo "Definir (p)adrões; emular (d)escarga ou (r)ecarga; ou (e)ncerrar"
  read sel

  case $sel in
    d)
      echo "Descarregar até [APENAS NÚMERO NATURAL!]:"
      read p && (echo $p | grep -Eo "^[0-9]+$")
      if [ $? -ne 0 ]; then exit 3; fi
      discharge_to $p
      ;;

    r)
      echo "Recarregar até [APENAS NÚMERO NATURAL!]:"
      read p && (echo $p | grep -Eo "^[0-9]+$")
      if [ $? -ne 0 ]; then exit 3; fi
      charge_to $p
      ;;
    p)
      default_values
      ;;
  esac
done
