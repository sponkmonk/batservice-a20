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


backup_owner () {
  # Em testes, podemos ignorar isto
  if [ "$NO_PERMS" != "" ]; then return 0; fi
  user=$(stat -c "%U" "$1")
  group=$(stat -c "%G" "$1")
  modes=$(stat -c "%a" "$1")
}

restore_owner () {
  if [ "$NO_PERMS" != "" ]; then return 0; fi
  chown $user:$group "$1"
  chmod $modes "$1"
}

restore_owner_r () {
  if [ "$NO_PERMS" != "" ]; then return 0; fi
  chown -R $user:$group "$1"
  chmod -R $modes "$1"
}
