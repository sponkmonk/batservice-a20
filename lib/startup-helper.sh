# startup-helper.sh - inicializador do serviço
# daqui pra baixo, vai tudo na base do #confia


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

if [ $(id -u) -ne 0 ]; then
  printerr "Privilégios root são necessários!"
  error $E_NOROOT
fi

# FAZ REGISTROS NO DIRETÓRIO APROPRIADO
if [ "$TERMUX_PREFIX" = "" ]; then
  TERMUX_PREFIX="/data/data/com.termux/files/usr"
fi

if [ "$TERMUX_PREFIX" = "$PREFIX" ]; then

  # Gambiarra para pegar o endereço correto da "home"
  TERMUX_HOME="$(cd $PREFIX/../home && pwd)"
  TERMUX_HOME_CACHE="$TERMUX_HOME/.cache"
  SERVICE_CACHE="$TERMUX_HOME_CACHE/$Name"
  backup_perms "$TERMUX_HOME"

  # Necessário para evitar que arquivos root prejudiquem a remoção do aplicativo
  mkdir -p "$SERVICE_CACHE"
  # caso o diretório .cache seja criado agora
  restore_owner "$TERMUX_HOME_CACHE"

  echo "\n" \
    "====== REGISTRO" "$NAME"  "======\n" \
    ""            "$(date)"          "\n" \
    "=================================\n" \
 >> "$SERVICE_CACHE/out.log"

  restore_owner_r "$SERVICE_CACHE"
  exec>> "$SERVICE_CACHE/out.log"

fi

unset TERMUX_PREFIX
