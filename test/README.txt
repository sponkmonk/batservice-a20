Estes arquivos são para testar o programa com as seguintes variáveis de ambiente definidas:
  BWD="$PWD/test/tBWD" # ou qualquer outro endereço simulando o sysfs da bateria)
  LIB="$PWD/lib" # 'lib' é o diretório dentro da raiz do código fonte)
  DATA="$PWD/test/config" # ou qualquer outro diretório onde o programa possa salvar e ler os arquivos exit.err e config.txt)
  CACHE="$PWD/test/cache" # por padrão, o programa notify.sh salva o relatório no diretório $HOME/.cache/BatService

Você pode gerar o diretório tBWD usando o script 'emulador.sh'.
Os outros diretórios, com exceção de 'lib', são dispensáveis.

by cleds.upper
