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


EXIT_FILE="/sdcard/batservice.exit"
echo "Encerrando BatService. Isto não deve demorar mais que 1 minuto"
echo "Root é necessário para criar/remover o arquivo de erros da memória interna, mas você pode rejeitar a solicitação se já encerrou o BatService."
su -c "touch $EXIT_FILE &&
  tm=60
  while [ -r $EXIT_FILE ]; do
    tm=\$(expr \$tm - 1)
    if [ \$tm -eq 0 ]; then
      rm $EXIT_FILE
      break
    fi
    sleep 1
  done"

echo "Removendo BatService incondicionalmente..."
rm $HOME/.termux/boot/batservice-boot.sh
rm $PREFIX/bin/batservice.sh
rm $PREFIX/lib/batservice/startup-helper.sh
rmdir $PREFIX/lib/batservice
rm $PREFIX/share/batservice/COPYING
rmdir $PREFIX/share/batservice

echo "Terminado!"
echo "by cleds.upper"
