#!/system/bin/sh

# Este script apenas empacota o módulo com todos os arquivos necessários

NAME=BatService-A20
VERSION=v2.1.211209

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
