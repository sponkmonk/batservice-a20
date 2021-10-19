#!/system/bin/sh

# Este script apenas empacota o módulo com todos os arquivos necessários

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

cd out
zip -r BatService-A20-1.2.211018.zip META-INF lib $PAR_DATA module.prop service.sh
mv BatService-A20-1.2.211018.zip ../
cd ..
rm -r out

echo "Finalizado!"
echo "Prossiga a instalação no aplicativo Magisk"
echo "by cleds.upper"
