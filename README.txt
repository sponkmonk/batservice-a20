BATSERVICE

É um simples programa para o Galaxy A20, para aplicativo de terminal (com root!), que conserva a bateria entre 45 e 50 %, o que possibilita usar um "power bank" como se este fosse a própria bateria do dispositivo, prolongando bastante a vida útil da bateria interna do dispositivo.

Isto funciona com praticamente todo carregador capaz de entregar a potência necessária para usar o Galaxy A20, isto é, qualquer fonte com potência igual ou maior que 5 W.


0. ANULAÇÃO DE GARANTIAS

Use este script por sua própria conta e risco! não me responsabilize se o seu aparelho entrar no modo de avião e sair voando até ir de encontro com a parede de livre e espontânea vontade.

Testei apenas no modelo referido. Se o kernel do seu Android não possuir o arquivo de controle de carga específico (1: veja a variável "Bswitch" no código fonte deste programa), ou o seu dispositivo não está rooteado, o BatService não funcionará.


1. COMO UTILIZAR

No aplicativo Termux, copie o arquivo para o diretório 'inicial' do aplicativo. Por exemplo, se o script estiver em "/sdcard/Documents", mova ele para o Termux com o seguinte comando:
  $ mv /sdcard/Documents/batservice.sh ~/

Dê permissões de execução:
  $ cd ~/ # garante que você está na home do Termux
  $ chmod +x batservice.sh

Reinicie o Termux em uma sessão 'failsafe', já que o serviço deve ser executado fora do espaço de aplicativo, e adquira privilégios root:
  $ su

OBS.: é possível abrir uma sessão failsafe também pelo menu lateral do Termux, segurando o botão "NEW SESSION".

Então basta executar o script:
  # ./batservice.sh

Com a bateria acima de 50 %, pode levar 1 minuto para o script desativar o carregamento da bateria. Você pode checar isso através de qualquer aplicativo capaz de exibir a corrente da bateria (desconsidere a mensagem de status "carregando"). Caso ainda esteja carregando, encerre e desinstale o programa com as instruções nas seções abaixo.


2. COMO ENCERRAR O SCRIPT

Existem várias formas de encerrar este programa.

Para leigos (isto é: pessoas que não entendem nada do código do script), o ideal é criar um arquivo nomeado "bat.exit" no diretório padrão "/sdcard" (MESMO QUE O TERMUX TENHA SIDO ASS@SSINADO PELO GERENCIADOR DE MEMÓRIA!). Até 1 minuto, o programa identifica o arquivo, remove e encerra. Este método chato é recomendado pois o script recupera a configuração anterior a ele.

Para usuários avançados, que sabem o que estão fazendo, basta encerrar o programa com CTRL+C, ou usar o comando kill. Você pode redefinir o valor padrão no arquivo de controle de carga (1).

NOTA: normalmente, reconectar o cabo já é o suficiente para recuperar a configuração padrão.


3. PARA DESINSTALAR

Primeiramente, encerre o script seguindo a seção anterior.

Finalmente, remova o script com o comando 'rm':
  # rm batservice.sh

E saia do terminal:
  # exit
  $ exit


PROBLEMAS?

Você deve entrar em contato comigo pela rede social Mastodon. Recebo muito spam no meu e-mail e possivelmente vou ignorar qualquer mensagem de estranhes que eu tenha recebido por lá.

Mastodon: @cledson_cavalcanti@mastodon.technology

by cleds.upper
