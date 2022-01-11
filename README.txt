BATSERVICE PARA O GALAXY A20

Isto é um software para o Galaxy A20, que conserva a bateria entre 45 e 50 %, o que possibilita usar um "power bank" como se este fosse a própria bateria do dispositivo, prolongando bastante a vida útil da bateria interna do dispositivo.

Instalável via Termux ou Magisk¹, funciona com praticamente todo carregador capaz de entregar a potência necessária para usar o Galaxy A20, isto é, qualquer fonte com potência superior a 5 W.


0. ANULAÇÃO DE GARANTIAS

Este programa vem com ABSOLUTAMENTE NENHUMA GARANTIA.
Este é um software livre, e você pode redistribuí-lo sob certas condições; leia o arquivo COPYING para detalhes.

Testei apenas no modelo referido. Se o kernel do seu Android não possuir o arquivo de controle de carga específico (veja a variável "Bswitch" no código fonte deste programa), ou o seu dispositivo não está rooteado, o BatService não funcionará.


1. INSTALANDO

  (a) Termux

Com o Termux instalado via F-Droid, e com a permissão de "Memória", abra-o e mova este pacote para ele. Pode ser necessário instalar o comando 'unzip' antes de extrair o pacote. Para isto:
    $ apt install unzip -y

Exemplo:
    $ mkdir tmp && cd tmp
    $ mv /sdcard/Download/BatService-A20-Termux-v2.*.zip ./
    $ unzip BatService-A20-Termux-v2.*.zip
    $ chmod +x install.sh && ./install.sh
    $ su -c "echo Ok" # Faça que o seu gerenciador de root LEMBRE desta permissão

É necessário instalar e executar o app Termux:Boot ao menos uma vez.

Existe um script de desinstalação no pacote, portanto não recomendo apagar.


  (b) Magisk

Use o script "module-create.sh" para criar o pacote de instalação do Magisk. Após isso, basta instalar o pacote zip.


2. COMO ENCERRAR O SERVIÇO (PARA DESENVOLVEDORES)

O serviço pode ser encerrado criando um arquivo nomeado "exit.err" no diretório <módulo>/data.

O mais recomendado é simplesmente desativar o módulo no Magisk e reiniciar o Android.


3. NOTIFICAÇÕES

O BatService suporta notificações através da API do Termux. Basta instalar esta extensão seguindo o guia oficial. Como deve imaginar: use a versão de Termux:API do F-Droid! em seguida, instale o pacote necessário.

Acesse a wiki³ para detalhes.


4. CONFIGURAÇÕES

O formato do arquivo de configuração a ser salvo em "$PREFIX/etc/batservice/config.txt" é simples como este exemplo:
    charging-never-stop false
    charging-stop 50
    charging-continue 45
    service-delay-not-charging 60

Nenhuma configuração é obrigatória*, mas o arquivo deve terminar com uma linha vazia se for manipulado manualmente.

Existem restrições para os valores suportados:
    cn: charging-never-stop       | true, false
    cc: charging-continue         | 15 <= cc < cs
    cs: charging-stop             | cc < cs <= 100
    sd: service-delay-not-charging| 6 <= sd <= 60

(*) cc depende de cs, portanto não é possível inserir apenas um!

NOTE: as abreviações (cc, cs etc.) são apenas para facilitar a leitura. O serviço não interpreta isso!


PROBLEMAS?

Você deve entrar em contato comigo pela rede social Mastodon. Recebo muito spam no meu e-mail e possivelmente vou ignorar qualquer mensagem de estranhes que eu tenha recebido por lá.

Mastodon: @cledson_cavalcanti@mastodon.technology


[1] https://github.com/topjohnwu/Magisk
[2] https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries
[3] https://wiki.termux.com/wiki/Termux:API

by cleds.upper
