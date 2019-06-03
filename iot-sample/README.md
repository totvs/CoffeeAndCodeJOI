# CoffeeAndCodeJOI
- Ao baixar os fontes, colocar em uma pasta "C:\CoffeeCode";
- Instalar e utilizar a IDE do Arduino ( https://www.arduino.cc/en/Main/Software );
- Utilizado os seguintes Hardwares nos exemplos:
    - NodeMCU (ESP8266) com WIFI;
    - Sensor de Temperatura DHT;
    - Sensor de Luminosidade;
    - Cristal Liquido 16x2 (LCM1602);
    - Cabos Femea-Femea.
- Abrir a IDE do Arduino;
- Baixar os drivers do NodeMCU, de acordo com o seu respectivo modelo: https://www.robocore.net/tutoriais/como-instalar-o-driver-do-nodemcu.html
- Configurar a IDE para reconhecer o NodeMCU em: Menu Arquivo -> Preferencias
    - URLs Adicionais para Gerenciadores de Placas: http://arduino.esp8266.com/stable/package_esp8266com_index.json
- Carregar o programa;
- ajustar o SSID e PASSWORD com a rede WIFI que sera conectada, para isso localize as linhas abaixo nos programas e informe os dados:
    const char* ssid = "xxxx";          // nome da rede
    const char* password = "xxxx"; 
- Connectar o NodeMCU;
- Clicar no botao Carregar para fazer o upload do programa dentro do NodeMCU.
- Para testar:
    - Ligar o NodeMCU na energia;
    - Ligar o Monitor Serial na IDE do Arduino;
    - Conectar o NodeMCU no seu roteador de Wifi, caso necessario;
    - Sera apresentado o endereco IP que o NodeMCU conseguiu obter e um contador de execucao;
    - OBS: por default as leituras do sensor vem desligado e tera que ser ligado atraves do comando " http://<ip_do_nodeMCU>/on ".
    - Em um navegador conectado na mesma rede de WIFI, informar os seguintes comandos (neste exemplo utilizaremos o ip 192.168.43.88 obtido do NodeMCU):
        - http://192.168.43.88/on   -> Liga o monitoramento do sensor
        - http://192.168.43.88/off  -> Desliga o monitoramento do sensor
        - http://192.168.43.88/get  -> Obtem a leitura atual do sensor
        - http://192.168.43.88/cap  -> Captura o endereco IP de quem realizou a requisicao no NodeMCU.
                                       Tentara enviar para o chamador a leitura atual atraves da porta 8181.
                                       Caso nao esteja disponivel a porta 8181 ou falhar em qualquer envio, o envio de informacoes sera desligado e este comando deverá ser feito novamente quando a porta 8181 do chamador estiver funcionando.

Para assistir novamente o video do Coffee&Code de IOT, acesse: https://www.facebook.com/developertotvs/videos/551854925246156/?xts[0]=68.ARBw3rFtsPlA6x_x_tDDImbOnoTTlcmmh0C56Tl_puYvenXhuZvBctETZY40tGZyyK8N3hk3J94UACsu3mUBLuTewP4BY8Y6KDTFE1zJZ6LYDEXL4C_C4jbB7NJG1cpMSi0GkJ8Kx10gnfxrA72n_XjZmWUDLIlTkNJhi25eC1KOCHWv7Rwq&tn=-R 
