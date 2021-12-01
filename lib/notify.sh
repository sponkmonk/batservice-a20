#!/system/bin/sh

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

termux-notification -h > /dev/null 2>&1
e=$?
if [ $e -ne 0 ]; then

  notify_status () { :; }
  notify_quit() { exit 0; }

else

  notify_status () {
    if ( [ "$status" = "Not charging" ] || [ "$status" = "Charging" ] ); then
      p=" (🔌 $current mA)"
    else
      p=""
    fi
    statustxt="🔋 $percent %$p ⚡ $voltage mV 🌡 $temp °C"

    termux-notification -i batservice -t "Serviço da Bateria" -c "$statustxt" --ongoing
  }

  notify_quit () {
    termux-notification-remove batservice
    exit 0
  }

fi

if [ "$CACHE" = "" ]; then
  CACHE="$HOME/.cache/BatService"
fi
mkdir -p "$CACHE"
exec>> "$CACHE/out.log"

log_cleanup () {
  if [ -r "$CACHE/out.log" ]; then

    if [ $(stat -c "%s" "$CACHE/out.log") -gt 30000 ]; then
      sed -i 1,1700d "$CACHE/out.log"
      exec>> "$CACHE/out.log"
    fi
  fi
}


while [ 0 ]; do
  read log_line || notify_quit

  echo "$log_line" | grep "ERR: " >/dev/null
  if ( [ $? -ne 0 ] && [ $e -eq 0 ] ); then

    _status=$(echo "$log_line" | grep -Eo '[A-Z][a-z]+( [a-z]+)*ging')
    if [ $? -eq 0 ]; then status=$_status; fi
    _percent=$(echo "$log_line" | grep -Eo '[0-9]+ %')
    if [ $? -eq 0 ]; then percent=$_percent; fi
    _current=$(echo "$log_line" | grep -Eo '-{0,1}[0-9]+ mA')
    if [ $? -eq 0 ]; then current=$_current; fi
    _voltage=$(echo "$log_line" | grep -Eo '[0-9]+ mV')
    if [ $? -eq 0 ]; then voltage=$_voltage; fi
    _temp=$(echo "$log_line" | grep -Eo '[0-9]+ .C')
    if [ $? -eq 0 ]; then
      temp=$_temp
      notify_status
    fi

  fi

  echo "$log_line" | grep -E '^# ' >/dev/null
  if [ $? -eq 0 ]; then
    :
  else
    echo "$log_line"
  fi
done
