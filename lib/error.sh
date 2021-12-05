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


EXIT_FILE="$DATA/exit.err"
# Se o programa encerra de forma inesperada, esse arquivo pode conter um dos códigos de erros das variáveis E_*.

if [ -z "$NO_SERVICE" ]; then
  printf BatService > /proc/$$/comm
  exec< /dev/null
  exec 2>&1
fi

error () {
  if [ $1 -ne 0 ]; then
    backup_owner "$DATA"
    echo $1 > "$EXIT_FILE"
    restore_owner "$EXIT_FILE"
  fi
  exit $1
}

printerr () {
  echo "ERR: $@"
}


E_NOROOT=2

E_NOSWITCH=10
E_WROPTION=11
E_FASWITCH=12
E_WRSWITCH=13

E_NILPARAM=20
E_INVPARAM=21
E_OUTPARAM=22
