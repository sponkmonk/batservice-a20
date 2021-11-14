BATSERVICE

É um simples programa para o Galaxy A20, para aplicativo de terminal (com root!), que conserva a bateria entre 45 e 50 %, o que possibilita usar um "power bank" como se este fosse a própria bateria do dispositivo, prolongando bastante a vida útil da bateria interna do dispositivo.

Isto funciona com praticamente todo carregador capaz de entregar a potência necessária para usar o Galaxy A20, isto é, qualquer fonte com potência igual ou maior que 5 W.


0. ANULAÇÃO DE GARANTIAS

Este programa vem com ABSOLUTAMENTE NENHUMA GARANTIA.
Este é um software livre, e você pode redistribuí-lo sob certas condições; leia o arquivo COPYING para detalhes.

Testei apenas no modelo referido. Se o kernel do seu Android não possuir o arquivo de controle de carga específico (1: veja a variável "Bswitch" no código fonte deste programa), ou o seu dispositivo não está rooteado, o BatService não funcionará.


1. INSTALANDO

No aplicativo de terminal, copie os arquivos para o diretório 'inicial' do aplicativo ("/data/data/URI_DO_TERMINAL/files/").

Por exemplo, se os arquivos estiverem em "/sdcard/Documents/batservice", você pode copiar para o Termux com o seguinte comando:
  $ cp -r /sdcard/Documents/batservice ~/batservice

Dê permissões de execução:
  $ cd ~/batservice
  $ chmod +x install.sh && chmod +x remove.sh

E então instale:
  $ ./install.sh

Uma solicitação de root pode aparecer. Neste caso, faça o gerenciador de super usuário memorizar a permissão ou seja incomodado por ele toda vez que o Android iniciar -- e caso o serviço não funcione, não é problema com o BatService, pois o gerenciador pode negar as solicitações de forma silenciosa durante a inicialização do sistema.

Instale também a extensão Termux:Boot, se ainda não fez isso. Desative a otimização de bateria para ambos os apps (Termux e Termux:Boot) e execute o Termux:Boot para o sistema Android inicializar o BatService. [Use os apps disponíveis via F-Droid!]

Com a bateria acima de 50 %, pode atrasar 1 minuto para o script desativar o carregamento da bateria. Você pode checar isso pela corrente em mA, que pode variar em até |10| mA. Caso ainda esteja carregando, encerre e desinstale o programa com as instruções nas seções abaixo.


2. COMO ENCERRAR O SCRIPT

O ideal é criar um arquivo nomeado "batservice.exit" no diretório padrão "/sdcard". Até 1 minuto, o programa identifica o arquivo, remove e encerra. Este método chato é recomendado pois o script recupera automaticamente a configuração anterior a ele, o que significa que seu smartphone vai carregar acima de 50% novamente.


3. PARA DESINSTALAR

De volta aos arquivos de instalação (você só precisa manter remove.sh após a instalação!)
  $ ./remove.sh

Root pode ser necessário.

Remova também o relatório do BatService, caso não vá usar futuramente:
  $ rm -r ~/.cache/BatService


4. ALTERANDO PERCENTUAIS

Os valores padrões são ótimos para a conservação da vida útil da bateria, segundo os estudos disponíveis em Battery University¹.

Mas você pode definir quaisquer limites entre 15 e 100% passando esses valores como argumentos para o programa:
  # ./batservice.sh [MÍNIMO] [MÁXIMO]

Entretanto, se estiver instalado o serviço conforme a seção (1), você deve adicionar os parâmetros no arquivo em ".termux/boot/batservice-boot.sh".

Reinicie o sistema Android para os novos valores terem efeito.


5. TESTANDO/ALTERANDO CÓDIGO

Você deve criar uma cópia dos arquivos presentes no endereço "/sys/class/power_supply/battery" em "qualquer/endereço". Para isso, defina a variável de ambiente BWD com esse endereço:
  $ export BWD="qualquer/endereço"

Se estiver no Linux, exporte também o endereço para os arquivos de configuração e erro:
  $ export DATA="qualquer/outro/endereço"

Também exporte a seguinte variável para que o script mostre mensagens/erros na tela em vez de salvar num arquivo de registro:
  $ export NO_SERVICE=1

Desta forma, é possível executar o script em modo de usuário sem causar alterações nos arquivos de sistema.

NOTA: no código fonte disponível no GitHub, há um diretório 'test' com todos os arquivos prontos para uso.


PROBLEMAS?

Você deve entrar em contato comigo pela rede social Mastodon. Recebo muito spam no meu e-mail e possivelmente vou ignorar qualquer mensagem de estranhes que eu tenha recebido por lá.

Mastodon: @cledson_cavalcanti@mastodon.technology


[1] https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries

by cleds.upper
