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

error () {
  if [ $1 -ne 0 ]; then
    echo $1 > "$EXIT_FILE"
  fi
  abort "Err: $1"
}

printerr () {
  echo "$@" >&2
}


E_NOROOT=1
E_NOSWITCH=2

E_WROPTION=10
E_FASWITCH=11
E_WRSWITCH=12

E_NILPARAM=20
E_INVPARAM=21
E_OUTPARAM=22
