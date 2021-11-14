BATSERVICE (MAGISK PORT)

Este é um simples módulo Magisk¹ para o Galaxy A20, que conserva a bateria entre 45 e 50 %, o que possibilita usar um "power bank" como se este fosse a própria bateria do dispositivo, prolongando bastante a vida útil da bateria interna do dispositivo.

Isto funciona com praticamente todo carregador capaz de entregar a potência necessária para usar o Galaxy A20, isto é, qualquer fonte com potência igual ou maior que 5 W.


0. ANULAÇÃO DE GARANTIAS

Este programa vem com ABSOLUTAMENTE NENHUMA GARANTIA.
Este é um software livre, e você pode redistribuí-lo sob certas condições; leia o arquivo COPYING para detalhes.

Testei apenas no modelo referido. Se o kernel do seu Android não possuir o arquivo de controle de carga específico (1: veja a variável "Bswitch" no código fonte deste programa), ou o seu dispositivo não está rooteado, o BatService não funcionará.


1. INSTALANDO

Com o arquivo com pacto em mãos, basta instalar pelo Magisk e reiniciar o Android.


2. COMO ENCERRAR O SERVIÇO (PARA DESENVOLVEDORES)

O serviço pode ser encerrado (sem o Magisk) criando um arquivo nomeado "exit.err" no diretório <módulo>/data.

O mais recomendado é simplesmente desativar o módulo no Magisk e reiniciar o Android.


3. PARA DESINSTALAR

Remova o módulo normalmente pelo Magisk e reinicie o Android.


4. ALTERANDO PERCENTUAIS

Os valores padrões são ótimos para a conservação da vida útil da bateria, segundo os estudos disponíveis em Battery University².

Mas você pode definir quaisquer limites entre 15 e 100% alterando o arquivo de configuração "config.txt" no diretório "<módulo>/data". Por exemplo:
  charging-continue 70
  charging-stop 75


5. TESTANDO/ALTERANDO CÓDIGO

Você deve criar uma cópia dos arquivos presentes no endereço "/sys/class/power_supply/battery" em "qualquer/endereço". Para isso, defina a variável de ambiente BWD com esse endereço:
  $ export BWD="qualquer/endereço"

Se estiver no Linux, exporte o endereço para o diretório do serviço:
  $ export MODDIR="qualquer/outro/endereço"

Também exporte a seguinte variável para que o script mostre mensagens/erros na tela em vez de salvar num arquivo de registro:
  $ export NO_SERVICE=1

Desta forma, é possível executar o script em modo de usuário sem causar alterações nos arquivos de sistema.

NOTA: no código fonte disponível no GitHub, há um diretório 'test' com todos os arquivos prontos para uso.


PROBLEMAS?

Você deve entrar em contato comigo pela rede social Mastodon. Recebo muito spam no meu e-mail e possivelmente vou ignorar qualquer mensagem de estranhes que eu tenha recebido por lá.

Mastodon: @cledson_cavalcanti@mastodon.technology


[1] https://github.com/topjohnwu/Magisk
[2] https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries

by cleds.upper
