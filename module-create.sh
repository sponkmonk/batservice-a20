#!/bin/sh

#    module-create.sh - this script generates a BatService module package
#    for Magisk.
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

. lib/consts.sh

echo "Criando pacote Magisk..."

mkdir -p out/META-INF/com/google/android
cp tools/module-installer.sh out/META-INF/com/google/android/update-binary
echo "#MAGISK" > out/META-INF/com/google/android/updater-script

cp COPYING out/
cp module.prop out/
cp service.sh out/
cp -r lib out/lib
if [ -d "./data" ]; then
  cp -r data out/data
  PAR_DATA="data"
else
  PAR_DATA=""
fi

echo "Removendo arquivos desnecessários..."
rm out/lib/env.rc
rm out/lib/notify.sh

cd out
zip -r $NAME-$VERSION-Magisk.zip META-INF lib $PAR_DATA module.prop service.sh
mv $NAME-$VERSION-Magisk.zip ../
cd ..
rm -r out

echo "Terminado!"
echo "Prossiga a instalação no aplicativo Magisk"
echo "by cleds.upper"
