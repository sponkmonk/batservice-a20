#    user-configs.sh - configurações do BateriaDroid
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


user_configs () {
  local empty
  empty=$(config_number_get charge-empty)
  [ -n "$empty" ] && U_CHARGE_EMPTY=$empty
  [ $? -ne 0 -a -n "$U_CHARGE_EMPTY" ] && unset U_CHARGE_EMPTY
}
