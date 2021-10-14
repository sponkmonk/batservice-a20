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

CONFIG="$DATA/config.txt"

config_number_get () {
  cat $CONFIG | grep $1 | grep -Eo '[0-9]+'
}

MIN_PERCENT=45
MAX_PERCENT=50
DELAY_REFRESH=60

config_update=0

config_refresh () {
  if [ -r "$CONFIG" ]; then
    changed=$(stat -c "%Y" $CONFIG)
    if [ $changed -le $config_update ]; then
      return 0
    fi

    config_update=$changed
    min=$(config_number_get charging-continue)
    max=$(config_number_get charging-stop)

    if ( [ "$min" = "" ] || [ "$max" = "" ] ); then
      :
    elif ( [ $min -lt 15 ] || [ $max -le $min ] || [ $max -gt 100 ] \
      ); then
      printerr "Arquivo de configuração mal definido!"
    else
      MIN_PERCENT=$min
      MAX_PERCENT=$max
    fi

    unset min
    unset max

    delay=$(config_number_get service-delay-not-charging)
    if [ "$delay" = "" ]; then
      :
    elif ( [ $delay -lt 6] || [ $delay -gt 3600 ] ); then
      printerr "O tempo ocioso deve ser ser digitado em segundos, de 6 a 3600 segundos"
    else
      DELAY_REFRESH=$delay
    fi

    unset delay
  fi
}

