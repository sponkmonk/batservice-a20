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


perms_backup () {
  # Em testes, podemos ignorar isto
  if [ -n "$NO_PERMS" ]; then return 0; fi
  _perms_user=$(stat -c "%U" "$1")
  _perms_group=$(stat -c "%G" "$1")
  _perms_modes=$(stat -c "%a" "$1")
}

perms_restore () {
  if [ -n "$NO_PERMS" ]; then return 0; fi
  chown $_perms_user:$_perms_group "$1"
  chmod $_perms_modes "$1"
}

perms_restore_r () {
  if [ -n "$NO_PERMS" ]; then return 0; fi
  chown -R $_perms_user:$_perms_group "$1"
  chmod -R $_perms_modes "$1"
}
