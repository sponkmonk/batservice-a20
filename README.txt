BATSERVICE

É um simples programa para o Galaxy A20, para aplicativo de terminal (com root!), que conserva a bateria entre 45 e 50 %, o que possibilita usar um "power bank" como se este fosse a própria bateria do dispositivo, prolongando bastante a vida útil da bateria interna do dispositivo.

Isto funciona com praticamente todo carregador capaz de entregar a potência necessária para usar o Galaxy A20, isto é, qualquer fonte com potência igual ou maior que 5 W.


0. ANULAÇÃO DE GARANTIAS

Este programa vem com ABSOLUTAMENTE NENHUMA GARANTIA.
Este é um software livre, e você pode redistribuí-lo sob certas condições; leia o arquivo COPYING para detalhes.

Testei apenas no modelo referido. Se o kernel do seu Android não possuir o arquivo de controle de carga específico (1: veja a variável "Bswitch" no código fonte deste programa), ou o seu dispositivo não está rooteado, o BatService não funcionará.


1. COMO UTILIZAR

No aplicativo de terminal, copie o arquivo para o diretório 'inicial' do aplicativo ("/data/data/URI_DO_TERMINAL/files/").

Por exemplo, se o script estiver em "/sdcard/Documents", você pode mover ele para o aplicativo Termux com o seguinte comando:
  $ mv /sdcard/Documents/batservice.sh ~/

Dê permissões de execução:
  $ cd ~/ # garante que você está na home do Termux
  $ chmod +x batservice.sh

Se estiver usando o Termux, reinicie em uma sessão 'failsafe', já que o serviço será executado fora do ambiente seguro do aplicativo, e adquira privilégios root:
  $ su

OBS.: é possível abrir uma sessão failsafe também pelo menu lateral do aplicativo, segurando o botão "NEW SESSION".

Então basta executar o script:
  # ./batservice.sh

Com a bateria acima de 50 %, pode levar 1 minuto para o script desativar o carregamento da bateria. Você pode checar isso pela corrente em mA, que pode variar em até |10| mA. Caso ainda esteja carregando, encerre e desinstale o programa com as instruções nas seções abaixo.


2. COMO ENCERRAR O SCRIPT

Existem várias formas de encerrar este programa.

Para leigos (isto é: pessoas que não entendem nada do código do script), o ideal é criar um arquivo nomeado "batservice.exit" no diretório padrão "/sdcard" (MESMO QUE O APP DE TERMINAL TENHA SIDO ASS@SSINADO PELO GERENCIADOR DE MEMÓRIA!). Até 1 minuto, o programa identifica o arquivo, remove e encerra. Este método chato é recomendado pois o script recupera a configuração anterior a ele.

Para usuários avançados, que sabem o que estão fazendo, basta encerrar o programa com CTRL+C, ou usar o comando kill. Você pode redefinir o valor padrão no arquivo de controle de carga (1).

NOTA: normalmente, reconectar o cabo já é o suficiente para recuperar a configuração padrão.


3. PARA DESINSTALAR

Primeiramente, encerre o script seguindo a seção anterior.

Finalmente, remova o script com o comando 'rm':
  # rm batservice.sh

E saia do terminal:
  # exit
  $ exit


4. ALTERANDO PERCENTUAIS
Os valores padrões são ideais para a conservação da vida útil da bateria, segundo artigos disponíveis em <https://batteryuniversity.com>.

Mas você pode definir quaisquer limites entre 15 e 100% passando esses valores como argumentos para o programa:
  # ./batservice.sh [MÍNIMO] [MÁXIMO]


5. TESTANDO/ALTERANDO CÓDIGO
Você criar uma cópia dos arquivos presentes no endereço "/sys/class/power_supply/battery" em "qualquer/endereço". Para isso, defina a variável de ambiente BWD com esse endereço:
  $ export BWD="qualquer/endereço"

Se estiver no Linux, exporte também o endereço para o arquivo de código de erros/encerramento:
  $ export EXIT_FILE="qualquer/erro"

Desta forma, é possível executar o script em modo de usuário sem causar alterações em arquivos de sistema.


PROBLEMAS?

Você deve entrar em contato comigo pela rede social Mastodon. Recebo muito spam no meu e-mail e possivelmente vou ignorar qualquer mensagem de estranhes que eu tenha recebido por lá.

Mastodon: @cledson_cavalcanti@mastodon.technology

by cleds.upper
