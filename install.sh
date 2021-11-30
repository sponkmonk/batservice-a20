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
  echo "O BatService não pode ser instalado no Termux em modo root!"
  exit 1
fi

install_file() {
  if [ ! -d "$2" ]; then
    mkdir -p "$2"
    e=$?
    if [ $e -ne 0 ]; then
      echo "Não foi possível criar o diretório \"$2\"!"
      exit $e
    fi
  fi

  echo "Copiando \"$1\" em \"$2\"..."
  cp "$1" "$2"
  e=$?
  if [ $e -ne 0 ]; then
    echo "Falha ao copiar!"
    exit $e
  fi
}

echo "Instalando BatService..."
install_file batservice.sh $PREFIX/bin/
chmod +x $PREFIX/bin/batservice.sh

install_file lib/startup-helper.sh $PREFIX/lib/batservice/
install_file lib/perms.sh $PREFIX/lib/batservice/
install_file lib/error.sh $PREFIX/lib/batservice/
install_file lib/config.sh $PREFIX/lib/batservice/
install_file lib/battery.sh $PREFIX/lib/batservice/
install_file lib/notify.sh $PREFIX/lib/batservice/
chmod +x $PREFIX/lib/batservice/notify.sh

install_file tools/batservice-termux.sh $HOME/.termux/boot/
chmod +x $HOME/.termux/boot/batservice-termux.sh

install_file COPYING $PREFIX/share/batservice/

echo "Instalação concluída."
echo "Reinicie o sistema Android se o BatService não entrar em execução."
echo "by cleds.upper"
