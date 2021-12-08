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


if [ -r "$DATA/user-configs" ]; then
  . "$DATA/user-configs.sh"
else
  user_configs () { :; }
fi

CONFIG="$DATA/config.txt"

config_valid_param () {
  if echo $1 | grep -Ev '^[[:alpha:]\-]+$' >/dev/null; then
    printerr "config_number_set: o nome da variável deve conter somente letras e traços (-); recebeu: $1"
    error $E_INVPARAM
  fi
}

config_number_get () {
  if [ -r "$CONFIG" ]; then
    cat "$CONFIG" | grep $1 | grep -Eo '[[:digit:]]+'
    return 0
  fi
  return 1
}

config_number_set () {
  config_valid_param $1
  local inval=$(echo $2 | grep -Ev '^[[:digit:]]+$')
  if [ -n "$inval" ]; then
    printerr "config_number_set: o valor deve ser um número; recebeu: $2"
    error $E_INVPARAM
  fi

  local val=$(config_number_get $1)
  if [ -z "$val" ]; then
    echo $1 $2 >> "$CONFIG"
    return $?
  fi
  sed -Ei "s|($1) [[:digit:]]+|\1 $2|g" "$CONFIG"
  return $?
}

config_bool_get () {
  if [ -r "$CONFIG" ]; then
    cat "$CONFIG" | grep $1 | grep -Eo '(true|false)'
    return 0
  fi
  return 1
}

config_bool_set () {
  config_valid_param $1
  local inval=$(echo $2 | grep -Ev '^(true|false)$')
  if [ -n "$inval" ]; then
    printerr "config_number_set: o valor deve ser um booleano (true|false); recebeu: $2"
    error $E_INVPARAM
  fi

  local val=$(config_bool_get $1)
  if [ -z "$val" ]; then
    echo $1 $2 >> "$CONFIG"
    return $?
  fi
  sed -Ei "s/($1) (true|false)/\1 $2/g" "$CONFIG"
}

config_string_get () {
  if [ -r "$CONFIG" ]; then
    cat "$CONFIG" | grep $1 | sed -E "s/$1 (.+)/\1/g"
    return 0
  fi
  return 1
}

# Strings multilinha não são suportadas
config_string_set () {
  config_valid_param $1

  local val="$(config_string_get $1)"
  if [ -z "$val" ]; then
    echo $1 "$2" >> "$CONFIG"
    return $?
  fi
  sed -Ei "s/($1) .+/\1 $2/g" "$CONFIG"
}


MIN_PERCENT=45
MAX_PERCENT=50

if [ -z "$TERMUX_API" ]; then
  DELAY_REFRESH=60
else
  DELAY_REFRESH=10
fi

NEVER_STOP="false"

config_update=0

config_refresh () {
  if [ -r "$CONFIG" ]; then
    local changed=$(stat -c "%Y" "$CONFIG")
    if [ $changed -le $config_update ]; then
      return 0
    fi

    config_update=$changed

    local min
    local max
    min=$(config_number_get charging-continue)
    max=$(config_number_get charging-stop)

    if ( [ -z "$min" ] || [ -z "$max" ] ); then
      :
    elif ( [ $min -lt 15 ] || [ $max -le $min ] || [ $max -gt 100 ] \
      ); then
      printerr "Arquivo de configuração mal definido!"
    else
      MIN_PERCENT=$min
      MAX_PERCENT=$max
    fi

    local delay
    delay=$(config_number_get service-delay-not-charging)
    if [ -z "$delay" ]; then
      :
    elif ( [ $delay -lt 6 ] || [ $delay -gt 60 ] ); then
      printerr "O tempo ocioso deve ser ser digitado em segundos, de 6 a 60 segundos"
    else
      DELAY_REFRESH=$delay
    fi

    local never_stop
    never_stop=$(config_bool_get charging-never-stop)
    if [ -z "$never_stop" ]; then
      :
    else
      NEVER_STOP="$never_stop"
    fi

    user_configs
  fi
}
