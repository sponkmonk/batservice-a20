#!/bin/sh

#    install.sh - instalador do BatService
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
install_file lib/perms.sh $PREFIX/lib/batservice/
install_file lib/error.sh $PREFIX/lib/batservice/
install_file lib/config.sh $PREFIX/lib/batservice/
install_file lib/battery.sh $PREFIX/lib/batservice/
install_file lib/notify.sh $PREFIX/lib/batservice/
chmod +x $PREFIX/lib/batservice/notify.sh
install_file lib/env.rc $PREFIX/lib/batservice/
install_file lib/jobs.sh $PREFIX/lib/batservice/
install_file lib/consts.sh $PREFIX/lib/batservice/

boot_file=$(ls $HOME/.termux/boot/batservice-*.sh 2>/dev/null)
expected_boot_file="$HOME/.termux/boot/batservice-termux.sh"
if ( [ -n "$boot_file" ] && [ "$boot_file" != "$expected_boot_file" ] ); then
  echo "ATUALIZE O BOOT DO NOTIFY QUE VOCÊ INSTALOU!"
  echo "Pressione ENTER para continuar..."
  read none
else
  install_file tools/batservice-termux.sh $HOME/.termux/boot/
  chmod +x $HOME/.termux/boot/batservice-termux.sh
fi

install_file COPYING $PREFIX/share/batservice/

echo "Instalando executável"
cp service.sh $PREFIX/bin/batservice.sh
chmod +x $PREFIX/bin/batservice.sh

echo "  Este programa é software livre: isto significa que você "
echo "  pode usar, alterar, redistribuir ou vender (exceto "
echo "  modificações!). Você pode ler os termos da Licença Pública "
echo "  Geral GNU executando: 'less $PREFIX/share/batservice/COPYING'"
echo
echo "Instalação concluída."
echo "Reinicie o sistema Android se o BatService não entrar em execução."
echo "by cleds.upper"
