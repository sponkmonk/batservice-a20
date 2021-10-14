#!/data/data/com.termux/files/usr/bin/sh

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

if [ $(id -u) -eq 0 ]; then
  echo "O BatService é instalado normalmente sem root, e deve ser removido também desta forma"
  exit 1
fi


EXIT_FILE="$PREFIX/etc/batservice/exit.err"
if [ ! -r "EXIT_FILE" ]; then
  echo "Encerrando BatService. Isto não deve demorar mais que 1 minuto"
  touch $EXIT_FILE
  tm=60
  while [ -r $EXIT_FILE ]; do
    if [ $tm -eq 0 ]; then
      rm $EXIT_FILE
      break
    fi
    tm=$(expr $tm - 1)
    sleep 1
  done
fi

echo "Removendo BatService incondicionalmente..."
rm $HOME/.termux/boot/batservice-termux.sh
rm $PREFIX/bin/batservice.sh
rm -r $PREFIX/lib/batservice
rm -r $PREFIX/share/batservice
rm -r $PREFIX/etc/batservice

echo "Terminado!"
echo "by cleds.upper"
