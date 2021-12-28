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


U_SYSFS_FLOAT_VOLTAGE="/sys/class/power_supply/battery/batt_tune_float_voltage"

# Isto limita o carregamento a 90 %, geralmente.
limit_voltage_action () {
  [ $CHARGE_NEVER_STOP -eq $DISABLED ] && return $EVENTS_OK
  [ "$status" != "Charging" ] && return $EVENTS_OK

  if [ $(cat "$U_SYSFS_FLOAT_VOLTAGE") -eq 4350 ]; then
    echo 4200 > "$U_SYSFS_FLOAT_VOLTAGE"
    echo "#upd carregando até 4,2 V"
  else
    echo "#msg O dispositivo não suporta limitar a tensão de carga!"
  fi
}

user_on_status_change () {
  limit_voltage_action
  return $EVENTS_OK
}
