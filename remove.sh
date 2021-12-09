#!/bin/sh

#    remove.sh - desinstalador do BatService
#
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

echo "Removendo BatService e todos os arquivos dependentes..."
rm $HOME/.termux/boot/batservice-*.sh
rm $PREFIX/bin/batservice.sh

rm $PREFIX/lib/batservice/perms.sh
rm $PREFIX/lib/batservice/error.sh
rm $PREFIX/lib/batservice/config.sh
rm $PREFIX/lib/batservice/battery.sh
rm $PREFIX/lib/batservice/notify*
rm $PREFIX/lib/batservice/env.rc
rm $PREFIX/lib/batservice/jobs.sh
rm $PREFIX/lib/batservice/consts.sh
rmdir $PREFIX/lib/batservice

rm $PREFIX/share/batservice/COPYING
rmdir $PREFIX/share/batservice

echo "Remover configuração e cache?"
echo "Isto também removerá tarefas programadas por você! [y/N]"
read sel
if [ "$sel" = "y" ] || [ "$sel" = "Y" ]; then
  rm $PREFIX/etc/batservice/config.txt
  rm $PREFIX/etc/batservice/user-configs.sh
  rm $PREFIX/etc/batservice/user-jobs.sh
  rmdir $PREFIX/etc/batservice
  rm $HOME/.cache/BatService/out.log
  rmdir $HOME/.cache/BatService
else
  echo "Você pode remover manualmente um dos seguintes arquivos:"
  echo "CONFIG: $PREFIX/etc/batservice/config.txt"
  echo "CACHE: $HOME/.cache/BatService/out.log"
fi

echo "Terminado!"
echo "by cleds.upper"
