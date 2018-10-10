#include <ESP8266WiFi.h>            // lib do wifi para o ESP8266
#include <ESP8266WiFiMulti.h>       // lib do wifi para o ESP8266
#include <ESP8266HTTPClient.h>      // lib do wifi para o ESP8266

#include <Wire.h>                   // lib para utilizacao do LCD
#include <LiquidCrystal_I2C.h>      // lib do LCDINCLUSAO DE BIBLIOTECA

#define ANALOGPIN A0                // Porta que o sensor esta conectado

const char* ssid = "xxxx";          // nome da rede
const char* password = "xxxx";      // senha da rede
int icont = 0;                      // contador do processo
boolean lExecute = false;           // informa se o sensor esta ligado ou nao
String remoteUrl = "";              // url remota para enviar informacoes
float lumi = 0.0;                   // resultado da leitura do sensor

ESP8266WiFiMulti wifiMulti;         // Carrega o modulo de WIFI

WiFiServer server(80);              // Habilita um server na porta 80
HTTPClient http;                    // habilita o http client

LiquidCrystal_I2C lcd(0x27, 16, 2); // Define o tamanho do LCD (16x2)

void setup() {
  Serial.begin(115200);             // Inicia a serial
  
  lcd.begin(16,2);
  lcd.init();                       // Inicializa o LCD
  lcd.backlight();                  // Habilita a luz de fundo
  lcd.setCursor(0, 0);              // Posiciona o cursor na linha 1
  lcd.print("----NODEMCU----");     // Mostra um texto padrao no LCD

  Serial.println("Booting");
  lcd.setCursor(0, 1);              // Posiciona o cursor na linha 2
  lcd.print("Booting");

  wifiMulti.addAP(ssid, password);  // Ativa a conexao via Wifi

  Serial.println("Connecting...");
  lcd.setCursor(0, 1);
  lcd.print("Connecting...");

  while (wifiMulti.run() != WL_CONNECTED) {    // Realiza a conexao Wifi
    lcd.setCursor(14, 1);
    lcd.print("|");
    delay(100);
    lcd.setCursor(14, 1);
    lcd.print("+");
    delay(100);
    lcd.setCursor(14, 1);
    lcd.print("-");
    delay(100);
    Serial.print('.');
  }

  // Start the server
  server.begin();                   // Inicia o servidor na porta 80
  Serial.println("Server started");
  
  // Mostra o endereco ip do NodeMCU quando pronto
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(WiFi.localIP());

  Serial.println("Ready");
  Serial.print("iP address: ");
  Serial.println(WiFi.localIP());   // mostra o endereco ip da conexao WIFI
}

void loop() {
  Serial.println("Processando " + String(++icont));
  lcd.setCursor(0, 1);
  lcd.print(String(icont));

  // faz a leitura do client
  if (wifiMulti.run() == WL_CONNECTED) {
    verifyClient();
  }

  // se tiver capturado um endereco ip remoto, mostra ele
  if (remoteUrl != "") {
    Serial.println("URL = " + remoteUrl);
  }

  if (lExecute) {
    float leitura_lumi = analogRead(ANALOGPIN);   // realiza a leitura do sensor
    lumi = map(leitura_lumi, 1023, 0, 0, 1000);
    if (lumi > 1000) lumi = 1000;
    Serial.println("Luminosidade = " + String(lumi) + " lux");
    lcd.setCursor(6, 1);
    lcd.print(String(lumi) + " lux     ");
  } else {
    remoteUrl = "";
    lumi = 0.0;
  }

  // envia informacoes para o server
  if (remoteUrl != "" && wifiMulti.run() == WL_CONNECTED) {
    sendInformation();
  }
  
  delay(1000);
}

void verifyClient() {
  String cCmd = "";
  String cRet = "";

  // Verifica se o client foi conectado
  WiFiClient client = server.available();
  if (!client) {
    return;
  }

  // le as informacoes passadas para o client
  String request = client.readStringUntil('\r');
  client.flush();

  String ipRemoto = client.remoteIP().toString();
  Serial.println("IpRemoto = " + ipRemoto);

  if (request.indexOf("/cap") != -1)  {         // captura o endereco ip remoto para enviar as informacoes
    cCmd = "CAP";
    cRet = "IP Capturado " + ipRemoto;
    remoteUrl = "http://" + ipRemoto + ":8181/?lux=";
  }
  if (request.indexOf("/on") != -1)  {          // liga a leitura do sensor
    cCmd = "ON";
    cRet = "Sensor Ligado!";
    lExecute = true;
  }
  if (request.indexOf("/off") != -1)  {         // desliga a leitura do sensor
    cCmd = "OFF";
    cRet = "Sensor Desligado!";
    lExecute = false;
  }
  if (request.indexOf("/get") != -1)  {         // retorna a leitura do sensor para quem solicitou
    cCmd = "GET";
    if  (lExecute) 
      cRet = "Luminosidade: " + String(lumi) + " lux";
    else
      cRet = "O Sensor esta Desligado!";
  }

  String s = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n<!DOCTYPE html><html><body><h1>" + cRet + "</h1></body></html>\n";
  client.print(s);
  delay(1);

  lcd.setCursor(6, 1);
  lcd.print(cCmd + "       ");

  Serial.println("Comando recebido = " + cCmd);
}

void sendInformation() {
  if (remoteUrl != "") {
    http.begin(remoteUrl + String(lumi));    // Envia para a URL remota as informacoes do sensor

    Serial.print("[HTTP] GET...\n");
    // start connection and send HTTP header
    int httpCode = http.GET();

    // httpCode will be negative on error
    if (httpCode > 0) {
      // HTTP header has been send and Server response header has been handled
      Serial.printf("[HTTP] GET... code: %d\n", httpCode);

      // file found at server
      if (httpCode == HTTP_CODE_OK) {
        String payload = http.getString();
        Serial.println(payload);
      }
    } else {
      Serial.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
      remoteUrl = "";
    }

    http.end();
  }
}
